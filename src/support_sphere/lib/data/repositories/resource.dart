import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/data/models/user_resource.dart';
import 'package:support_sphere/data/services/resource_service.dart';

class ResourceRepository {
  final ResourceService _resourceService = ResourceService();

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
    PostgrestList? results = await _resourceService.getUserResourcesByUserId(userId);
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
    await _resourceService.addUserResource(data);
  }

  Future<void> deleteUserResource(String id) async {
    await _resourceService.deleteUserResource(id);
  }

  Future<void> markUpToDate(String id, DateTime updatedAt) async {
    await _resourceService.markUpToDate(id, updatedAt);
  }
}