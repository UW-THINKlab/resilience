import 'package:flutter/widgets.dart'; // for debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/data/models/user_resource.dart';
// import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/models/supplier_candidate.dart';
import 'package:support_sphere/data/services/resource_service.dart';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:support_sphere/data/repositories/message.dart';
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

  Future<dynamic> queryCV(String text) async {
    return await _resourceService.getResourceCVByText(text);
  }

  Future<List<ResourceTypes>> getResourceTypes() async {
    PostgrestList? results = await _resourceService.getResourceTypes();
    return results?.map((data) => ResourceTypes.fromJson(data)).toList() ?? [];
  }

  Future<List<Resource>> getResources() async {
    PostgrestList? results = await _resourceService.getAllResources();
    return results?.map((data) => Resource.fromJson(data)).toList() ?? [];
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

  // Future<void> requestResource(Map<String, dynamic> data) async {
  //   await _resourceService.createResourceRequest(data);
  // }

  Future<void> submitResourceRequestAndNotify({
    required Map<String, dynamic> requestData,
    required String requesterProfileId,
  }) async {
    final resourceId = requestData['resource_id'] as String;
    final requestedQuantity = (requestData['quantity'] as num).toInt();
    final requestScope = requestData['request_scope'] as String;
    final notes = requestData['notes'] as String?;
    final currentLatitude =
        (requestData['current_latitude'] as num?)?.toDouble();
    final currentLongitude =
        (requestData['current_longitude'] as num?)?.toDouble();
    final resourceName = requestData['resource_name'] as String;

    final candidates = await _getCandidates(
      requesterProfileId: requesterProfileId,
      resourceId: resourceId,
      requestScope: requestScope,
      currentLatitude: currentLatitude,
      currentLongitude: currentLongitude,
    );

    var remaining = requestedQuantity;

    debugPrint('requestData in repository: $requestData');
    debugPrint('candidates in repository: $candidates');

    for (final candidate in candidates) {
      if (remaining <= 0) break;
      if (candidate.availableQuantity <= 0) continue;

      final allocated = candidate.availableQuantity >= remaining
          ? remaining
          : candidate.availableQuantity;

      final person = await _userRepository.getMyProfile();
      final requesterName = person?.givenName ?? 'Unk Neighbor';

      final groupName =
          'Request from $requesterName to ${candidate.givenName} for $allocated $resourceName';

      final groupId = await _chatRepository.createDirectRequestGroup(
        createdByProfileId: requesterProfileId,
        description: 'DM for resource request',
        otherProfileId: candidate.profileId,
        name: groupName,
      );

      // final requestRow = await _resourceService.createResourceRequest(
      //   {
      //     'resource_id': resourceId,
      //     'quantity': allocated,
      //     'notes': notes,
      //     'request_scope': requestScope,
      //     'requester_profile_id': requesterProfileId,
      //     'supplier_profile_id': candidate.profileId,
      //     'distance_meters': candidate.distanceMeters,
      //     //TODO urgency
      //   },
      // );
      final requestRow = await _resourceService.reserveRequestCandidate(
        resourceId: resourceId,
        quantity: allocated,
        notes: notes,
        requestScope: requestScope,
        requesterProfileId: requesterProfileId,
        supplierProfileId: candidate.profileId,
        userResourceId: candidate.userResourceId,
        distanceMeters: candidate.distanceMeters,
      );

      await _messagesRepository.sendMessage(
        fromProfileId: requesterProfileId,
        groupId: groupId,
        text:
            'New resource request for $allocated unit(s) of  $resourceName. Notes: $notes',
        messageType: 'resource_request',
        requestId: requestRow['id'] as String,
        metadata: {
          'resource_id': resourceId,
          'quantity': allocated,
          'request_scope': requestScope,
          'requester_profile_id': requesterProfileId,
          'supplier_profile_id': candidate.profileId,
          'distance_meters': candidate.distanceMeters,
          //TODO urgency
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
    debugPrint(
        'Getting Candidates with requesterProfileId=$requesterProfileId, resourceId=$resourceId, requestScope=$requestScope, currentLatitude=$currentLatitude, currentLongitude=$currentLongitude');
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
}
