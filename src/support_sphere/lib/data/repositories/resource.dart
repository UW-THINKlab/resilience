import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_request.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/data/models/user_resource.dart';
// import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/models/supplier_candidate.dart';
import 'package:support_sphere/data/services/resource_service.dart';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/data/repositories/user.dart';

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
    return results?.map((data) => UserResource.fromJson(data)).toList() ?? [];
  }

  Future<void> addNewResource(Resource resource) async {
    // TODO: Add error handling
    await _resourceService.createResourceCV({
      'id': resource.id,
      'name': resource.name,
      'description': resource.description,
    });
    await _resourceService.createResource({
      'notes': resource.notes,
      'qty_needed': resource.qtyNeeded,
      'qty_available': resource.qtyAvailable,
      'resource_cv_id': resource.id,
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

  Future<void> markUpToDate(String id, DateTime updatedAt) async {
    await _resourceService.markUpToDate(id, updatedAt);
  }

  Future<void> submitResourceRequestAndNotify({
    required ResourceRequest resourceRequest,
    required String requesterProfileId,
  }) async {
    final candidates = await _getCandidates(
      requesterProfileId: requesterProfileId,
      resourceId: resourceRequest.resourceId,
      requestScope: resourceRequest.requestScope,
      currentLatitude: resourceRequest.lat,
      currentLongitude: resourceRequest.lon,
    );

    var remaining = resourceRequest.quantity;
    log.fine('requestData in repository: $resourceRequest');
    log.fine('candidates in repository: $candidates');

    for (final candidate in candidates) {
      if (remaining <= 0) break;
      if (candidate.availableQuantity <= 0) continue;

      final allocated = candidate.availableQuantity >= remaining
          ? remaining
          : candidate.availableQuantity;

      final groupType = switch (resourceRequest.resourceTypeName) {
        'Consumable' => GROUP_CHAT_TYPE.request_consumable,
        'Durable'    => GROUP_CHAT_TYPE.request_durable,
        'Skill'      => GROUP_CHAT_TYPE.request_skill,
        _            => GROUP_CHAT_TYPE.request_consumable,
      };
      final groupId = await _chatRepository.createDirectRequestGroup(
        name: await _groupNameForRequest(
          candidate,
          allocated,
          resourceRequest.resourceName,
        ),
        createdByProfileId: requesterProfileId,
        description: 'DM for resource request',
        otherProfileId: candidate.profileId,
        type: groupType,
      );

      final requestRow = await _resourceService.reserveRequestCandidate(
        resourceId: resourceRequest.resourceId,
        quantity: allocated,
        notes: resourceRequest.notes,
        requestScope: resourceRequest.requestScope,
        requesterProfileId: requesterProfileId,
        supplierProfileId: candidate.profileId,
        userResourceId: candidate.userResourceId,
        distanceMeters: candidate.distanceMeters,
      );
      final buf = StringBuffer();
      buf.writeln(
        'Request for $allocated unit(s) of  ${resourceRequest.resourceName}.',
      );
      buf.writeln('Urgency: ${resourceRequest.urgency.name}.');
      buf.writeln(
        'Notes: ${resourceRequest.notes?.isEmpty ?? true ? 'NA' : resourceRequest.notes}.',
      );

      await _messagesRepository.sendMessage(
        fromProfileId: requesterProfileId,
        groupId: groupId,
        text: buf.toString(),
        messageType: 'resource_request',
        requestId: requestRow['id'] as String,
        metadata: {
          'resource_id': resourceRequest.resourceId,
          'quantity': allocated,
          'request_scope': resourceRequest.requestScope,
          'requester_profile_id': requesterProfileId,
          'supplier_profile_id': candidate.profileId,
          'distance_meters': candidate.distanceMeters,
          'urgency': resourceRequest.urgency.name,
        },
      );

      remaining -= allocated;
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
  }) async {
    log.fine(
      'Getting Candidates with requesterProfileId=$requesterProfileId, resourceId=$resourceId, requestScope=$requestScope, currentLatitude=$currentLatitude, currentLongitude=$currentLongitude',
    );
    switch (requestScope) {
      case 'neighbors':
        return _resourceService.getNearestSuppliersByHousehold(
          requesterProfileId: requesterProfileId,
          resourceId: resourceId,
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
