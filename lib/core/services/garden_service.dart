import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pakebun_app/core/config/supabase_config.dart';

/// Garden Service for Supabase Operations
/// Handles CRUD operations for greenhouses (kebun)
class GardenService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all greenhouses for a specific organization
  Future<List<Map<String, dynamic>>> getGreenhouses(String orgId) async {
    try {
      final response = await _supabase
          .from('greenhouses')
          .select('''
            *,
            zones (
              id,
              name,
              plant_id,
              plants (
                name,
                image_url
              )
            )
          ''')
          .eq('org_id', orgId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a single greenhouse by ID
  Future<Map<String, dynamic>?> getGreenhouse(String greenhouseId) async {
    try {
      final response = await _supabase
          .from('greenhouses')
          .select('''
            *,
            zones (
              id,
              name,
              plant_id,
              plants (
                name,
                image_url
              )
            )
          ''')
          .eq('id', greenhouseId)
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new greenhouse
  /// Returns the created greenhouse ID
  Future<String> createGreenhouse({
    required String orgId,
    required String name,
    required String address,
    required String ownerName,
    required String ownerPhone,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageFileName,
    required List<String> plantIds, // List of plant IDs for zones
  }) async {
    try {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null || imageBytes != null) {
        imageUrl = await _uploadGreenhouseImage(
          imageFile: imageFile,
          imageBytes: imageBytes,
          fileName:
              imageFileName ??
              'greenhouse_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Insert greenhouse
      final greenhouse = await _supabase
          .from('greenhouses')
          .insert({
            'org_id': orgId,
            'name': name,
            'location_name': address,
            'owner_name': ownerName,
            'owner_phone': ownerPhone,
            'image_url': imageUrl,
            'status': 'active',
          })
          .select()
          .single();

      final greenhouseId = greenhouse['id'] as String;

      // Create zones for each plant
      if (plantIds.isNotEmpty) {
        final zones = plantIds.asMap().entries.map((entry) {
          return {
            'greenhouse_id': greenhouseId,
            'name': 'Zona ${entry.key + 1}',
            'plant_id': entry.value,
          };
        }).toList();

        await _supabase.from('zones').insert(zones);
      }

      return greenhouseId;
    } catch (e) {
      rethrow;
    }
  }

  /// Update greenhouse
  Future<void> updateGreenhouse({
    required String greenhouseId,
    String? name,
    String? address,
    String? ownerName,
    String? ownerPhone,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageFileName,
    String? status,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (address != null) updates['location_name'] = address;
      if (ownerName != null) updates['owner_name'] = ownerName;
      if (ownerPhone != null) updates['owner_phone'] = ownerPhone;
      if (status != null) updates['status'] = status;

      // Upload new image if provided
      if (imageFile != null || imageBytes != null) {
        final imageUrl = await _uploadGreenhouseImage(
          imageFile: imageFile,
          imageBytes: imageBytes,
          fileName:
              imageFileName ??
              'greenhouse_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        updates['image_url'] = imageUrl;
      }

      await _supabase
          .from('greenhouses')
          .update(updates)
          .eq('id', greenhouseId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete greenhouse
  Future<void> deleteGreenhouse(String greenhouseId) async {
    try {
      await _supabase.from('greenhouses').delete().eq('id', greenhouseId);
    } catch (e) {
      rethrow;
    }
  }

  /// Update zones for a greenhouse
  Future<void> updateZones({
    required String greenhouseId,
    required List<String> plantIds,
  }) async {
    try {
      // Delete existing zones
      await _supabase.from('zones').delete().eq('greenhouse_id', greenhouseId);

      // Create new zones
      if (plantIds.isNotEmpty) {
        final zones = plantIds.asMap().entries.map((entry) {
          return {
            'greenhouse_id': greenhouseId,
            'name': 'Zona ${entry.key + 1}',
            'plant_id': entry.value,
          };
        }).toList();

        await _supabase.from('zones').insert(zones);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Upload greenhouse image to Supabase Storage
  Future<String> _uploadGreenhouseImage({
    File? imageFile,
    Uint8List? imageBytes,
    required String fileName,
  }) async {
    try {
      final bucket = SupabaseConfig.greenhouseImagesBucket;
      final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      if (imageFile != null) {
        // Upload from File (mobile)
        await _supabase.storage
            .from(bucket)
            .uploadBinary(path, await imageFile.readAsBytes());
      } else if (imageBytes != null) {
        // Upload from bytes (web)
        await _supabase.storage.from(bucket).uploadBinary(path, imageBytes);
      } else {
        throw Exception('No image provided');
      }

      // Get public URL
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all plants (master data)
  Future<List<Map<String, dynamic>>> getPlants() async {
    try {
      final response = await _supabase
          .from('plants')
          .select()
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get plant by name (for compatibility with existing code)
  Future<Map<String, dynamic>?> getPlantByName(String plantName) async {
    try {
      final response = await _supabase
          .from('plants')
          .select()
          .eq('name', plantName)
          .maybeSingle();

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
