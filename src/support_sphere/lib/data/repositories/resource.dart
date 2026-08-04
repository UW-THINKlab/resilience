import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/reservation_extension.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_request.dart';
import 'package:support_sphere/data/models/user_resource.dart';
import 'package:support_sphere/data/models/supplier_candidate.dart';
import 'package:support_sphere/data/services/resource_service.dart';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/data/repositories/user.dart';

class SuggestedResourceRequest {
  final SupplierCandidate supplierCandidate;
  final int availableQty;
  final int requestedQty;

  SuggestedResourceRequest({
    required this.supplierCandidate,
    required this.availableQty,
    required this.requestedQty,
  });
}

/// Thrown when the user declines to continue past the
/// insufficient-total-inventory warning.
class ResourceRequestCancelled implements Exception {}

class ResourceRepository {
  ResourceRepository({
    ResourceService? resourceService,
    AuthService? authService,
    MessagesRepository? messagesRepository,
    ChatRepository? chatRepository,
    UserRepository? userRepository,
  })  : _resourceService = resourceService ?? ResourceService(),
        _authService = authService ?? AuthService(),
        _messagesRepository = messagesRepository ?? MessagesRepository(),
        _chatRepository = chatRepository ?? ChatRepository(),
        _userRepository = userRepository ?? UserRepository();

  final ResourceService _resourceService;
  final AuthService _authService;
  final MessagesRepository _messagesRepository;
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final log = Logger('ResourceRepository');

  Future<dynamic> queryCV(String text) async {
    return await _resourceService.getResourceCVByText(text);
  }

  Future<List<ResourceTypes>> getResourceTypes() async {
    PostgrestList? results = await _resourceService.getResourceTypes();
    return results?.map((data) => ResourceTypes.fromJson(data)).toList() ?? [];
  }

  Future<List<Resource>> getResources() async {
    PostgrestList? results = await _resourceService.getAllResources();
    return results?.map((data) {
          return Resource.fromJson(data);
        }).toList() ??
        [];
  }

  Future<List<UserResource>> getUserResourcesByUserId(String userId) async {
    PostgrestList? results =
        await _resourceService.getUserResourcesByUserId(userId);
    final rows =
        results?.map((data) => UserResource.fromJson(data)).toList() ?? [];
    rows.sort((a, b) {
      final nameComparison =
          a.name.toLowerCase().compareTo(b.name.toLowerCase());
      if (nameComparison != 0) return nameComparison;
      return b.addedDate!.compareTo(a.addedDate!);
    });
    return rows;
  }

  Future<void> addNewResource(Resource resource) async {
    await _resourceService.createResourceCV({
      'id': resource.resourceCv.id,
      'name': resource.resourceCv.name,
      'description': resource.resourceCv.description,
    });
    await _resourceService.createResource({
      'notes': resource.notes,
      'qty_needed': resource.qtyNeeded,
      'qty_available': resource.qtyAvailable,
      'resource_cv_id': resource.resourceCv.id,
      'resource_type_id': resource.resourceType.id,
    });
  }

  Future<void> deleteResource(String id) async {
    await _resourceService.deleteResource(id);
    await _resourceService.deleteResourceCV(id);
  }

  Future<void> addToUserInventory(Map<String, dynamic> data) async {
    final userId = _authService.getSignedInUser()!.id;
    await _resourceService.addUserResource(
      userId: userId,
      resourceId: data['resource_id'] as String,
      quantity: data['quantity'] as int,
      notes: data['notes'] as String?,
      sharingScope: data['sharing_scope'] as String,
      sharingScopeEmergency: data['sharing_scope_emergency'] as String,
    );
  }

  Future<void> deleteUserResource(String id) async {
    await _resourceService.deleteUserResource(id);
  }

  Future<void> updateUserResource({
    required String id,
    required int quantity,
    String? notes,
    required SHARING_SCOPES sharingScope,
    required SHARING_SCOPES sharingScopeEmergency,
  }) async {
    await _resourceService.updateUserResource(
      id: id,
      quantity: quantity,
      notes: notes,
      sharingScope: sharingScope,
      sharingScopeEmergency: sharingScopeEmergency,
    );
  }

  Future<List<String>> getUserResourceIdsWithReservations(
      List<String> ids) async {
    final rows = await _resourceService.getReservationsForUserResources(ids);
    return (rows ?? [])
        .map((r) => r['user_resource_id'] as String)
        .toSet()
        .toList();
  }

  Future<void> notifyReservationsRemoved(List<String> userResourceIds) async {
    if (userResourceIds.isEmpty) return;
    final rows =
        await _resourceService.getReservationsForUserResources(userResourceIds);
    final fromProfileId = _authService.getSignedInUser()!.id;
    final notifiedGroupIds = <String>{};
    for (final row in rows ?? []) {
      final requestId = row['request_id'] as String;
      final groupId = await _resourceService.getGroupIdForRequest(requestId);
      if (groupId == null || !notifiedGroupIds.add(groupId)) continue;
      await _messagesRepository.sendMessage(
        fromProfileId: fromProfileId,
        groupId: groupId,
        text: ResourceStrings.resourceRemovedMessage,
        messageType: 'resource_removed',
        urgency: MESSAGEURGENCY.normal,
      );
    }
  }

  Future<ResourceReservations?> getPendingReservationForChat({
    required String groupId,
  }) async {
    final results = await _resourceService.getPendingReservationForChat(
      groupId: groupId,
    );
    if (results.isEmpty) return null;
    ResourceReservations reservation =
        ResourceReservations.fromJson(results.first);
    if (reservation.isExpired()) {
      reservation = reservation.copyWith(status: RESERVATION_STATUS.expired);
    }
    return reservation;
  }

  Future<void> updateReservation({
    required String reservationId,
    required RESERVATION_STATUS status,
    int? quantity,
  }) async {
    await _resourceService.updateReservation(
      reservationId: reservationId,
      status: status.name,
      quantity: quantity,
    );
  }

  Future<void> submitResourceRequestAndNotify({
    required ResourceRequest resourceRequest,
    required String requesterProfileId,
    required Future<bool> Function(SuggestedResourceRequest) confirmation,
    required bool isEmergency,
    required Future<bool> Function(int totalAvailable, int requested)
        onInsufficientInventory,
  }) async {
    final candidates = await _getCandidates(
      requesterProfileId: requesterProfileId,
      resourceId: resourceRequest.resourceId,
      requestScope: resourceRequest.requestScope,
      currentLatitude: resourceRequest.lat,
      currentLongitude: resourceRequest.lon,
      isEmergency: isEmergency,
    );

    final totalAvailable = candidates.fold<int>(
      0,
      (sum, candidate) => sum + candidate.availableQuantity,
    );
    if (totalAvailable < resourceRequest.quantity) {
      final proceed = await onInsufficientInventory(
        totalAvailable,
        resourceRequest.quantity,
      );
      if (!proceed) {
        throw ResourceRequestCancelled();
      }
    }

    var remaining = resourceRequest.quantity;
    log.fine('requestData in repository: $resourceRequest');
    log.fine('candidates in repository: $candidates');

    for (final candidate in candidates) {
      if (remaining <= 0) break;
      if (candidate.availableQuantity <= 0) continue;
      if (await _userRepository.isEitherUserBlocked(
        user1Id: requesterProfileId,
        user2Id: candidate.profileId,
      )) {
        continue;
      }
      final requestedQuantity = candidate.availableQuantity >= remaining
          ? remaining
          : candidate.availableQuantity;
      final suggestion = SuggestedResourceRequest(
        availableQty: candidate.availableQuantity,
        requestedQty: requestedQuantity,
        supplierCandidate: candidate,
      );
      if (!await confirmation(suggestion)) {
        continue;
      }

      late final Map<String, dynamic> requestRow;
      try {
        requestRow = await _resourceService.reserveRequestCandidate(
          resourceId: resourceRequest.resourceId,
          quantity: requestedQuantity,
          notes: resourceRequest.notes,
          requestScope: resourceRequest.requestScope,
          requesterProfileId: requesterProfileId,
          supplierProfileId: candidate.profileId,
          userResourceId: candidate.userResourceId,
          distanceMeters: candidate.distanceMeters,
          expiresAt: resourceRequest.expiresAt,
        );
      } catch (e) {
        log.fine(
          'reserveRequestCandidate failed for candidate ${candidate.profileId}, skipping: $e',
        );
        continue;
      }
      final grantedQuantity = (requestRow['quantity'] as num).toInt();

      final groupType = switch (resourceRequest.resourceTypeName) {
        'Consumable' => GROUP_CHAT_TYPE.request_consumable,
        'Durable' => GROUP_CHAT_TYPE.request_durable,
        'Skill' => GROUP_CHAT_TYPE.request_skill,
        _ => GROUP_CHAT_TYPE.request_consumable,
      };
      final groupChat = await _chatRepository.createDirectRequestGroup(
        name: await _groupNameForRequest(
          candidate,
          grantedQuantity,
          resourceRequest.resourceName,
        ),
        createdByProfileId: requesterProfileId,
        description: 'DM for resource request',
        otherProfileId: candidate.profileId,
        type: groupType,
      );

      if (groupChat == null) {
        throw Exception(
          'failed to create a chat with the person to request from',
        );
      }

      final buf = StringBuffer();
      buf.writeln(
        'Request for $grantedQuantity unit(s) of  ${resourceRequest.resourceName}.',
      );
      buf.writeln('Urgency: ${resourceRequest.urgency.name}.');
      buf.writeln(
        'Notes: ${resourceRequest.notes?.isEmpty ?? true ? 'NA' : resourceRequest.notes}.',
      );

      await _messagesRepository.sendMessage(
        fromProfileId: requesterProfileId,
        groupId: groupChat.id,
        text: buf.toString(),
        messageType: 'resource_request',
        requestId: requestRow['id'] as String,
        metadata: {
          'resource_id': resourceRequest.resourceId,
          'quantity': grantedQuantity,
          'request_scope': resourceRequest.requestScope,
          'requester_profile_id': requesterProfileId,
          'supplier_profile_id': candidate.profileId,
          'distance_meters': candidate.distanceMeters,
          'urgency': resourceRequest.urgency.name,
        },
        urgency: MESSAGEURGENCY.normal,
      );

      remaining -= grantedQuantity;
    }

    if (remaining > 0) {
      throw Exception(
        'Not enough available inventory to fulfill request. Remaining: $remaining',
      );
    }
  }

  Future<List<SupplierCandidate>> _getCandidates({
    required String requesterProfileId,
    required String resourceId,
    required String requestScope,
    required double? currentLatitude,
    required double? currentLongitude,
    required bool isEmergency,
  }) async {
    log.fine(
      'Getting Candidates with requesterProfileId=$requesterProfileId, resourceId=$resourceId, requestScope=$requestScope, currentLatitude=$currentLatitude, currentLongitude=$currentLongitude',
    );
    switch (requestScope) {
      case 'neighbors':
        return _resourceService.getNearestSuppliersByHousehold(
          requesterProfileId: requesterProfileId,
          resourceId: resourceId,
          isEmergency: isEmergency,
        );
      case 'nearby':
        if (currentLatitude == null || currentLongitude == null) {
          throw Exception(
            'Current latitude/longitude is required for request_scope=nearby',
          );
        }
        return _resourceService.getNearestSuppliersByCurrentLocation(
          requesterProfileId: requesterProfileId,
          resourceId: resourceId,
          currentLatitude: currentLatitude,
          currentLongitude: currentLongitude,
          isEmergency: isEmergency,
        );
      default:
        throw Exception('Invalid request_scope: $requestScope');
    }
  }

  Future<String> _groupNameForRequest(
    SupplierCandidate candidate,
    int quantity,
    String resourceName,
  ) async {
    final requesterPerson = await _userRepository.getMyProfile();
    final requesterName = requesterPerson?.name() ?? 'Unk Neighbor 1';
    final candidatePerson = await _userRepository.getPersonProfileByUserId(
        userId: candidate.profileId);
    final candidateName = candidatePerson?.name() ?? 'Unk Neighbor 2';
    return 'Request from $requesterName to $candidateName for $quantity $resourceName';
  }
}
