import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
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
    PostgrestList? results = await _resourceService.getResources();
    return results?.map((data) => Resource.fromJson(data)).toList() ?? [];
  }
}