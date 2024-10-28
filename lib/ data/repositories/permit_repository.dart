import '../api/permit_api.dart';
import '../models/permit_model.dart';



class PermitRepository {
  /*final PermitAPI _permitAPI;

  PermitRepository(this._permitAPI);

  /// Fetch all permits from the API
  Future<List<Permit>> fetchPermits() async {
    try {
      // Call API to get permits
      final permitsData = await _permitAPI.fetchPermits();

      // Convert response to List of Permit objects
      return permitsData.map((data) => Permit.fromJson(data as Map<String, dynamic>)).toList();
    } catch (error) {
      throw Exception('Failed to fetch permits: $error');
    }
  }

  /// Fetch a single permit by ID
  Future<Permit?> fetchPermitById(String permitId) async {
    try {
      final permitData = await _permitAPI.getPermitById(permitId);
      return Permit.fromJson(permitData);
    } catch (error) {
      throw Exception('Failed to fetch permit by ID: $error');
    }
  }

  /// Create a new permit
  Future<bool> createPermit(Permit permit) async {
    try {
      final response = await _permitAPI.createPermit(permit.toJson());
      return response['success'] == true;
    } catch (error) {
      throw Exception('Failed to create permit: $error');
    }
  }

  /// Update an existing permit
  Future<bool> updatePermit(Permit permit) async {
    try {
      final response = await _permitAPI.updatePermit(permit.id, permit.toJson());
      return response['success'] == true;
    } catch (error) {
      throw Exception('Failed to update permit: $error');
    }
  }

  /// Delete a permit by ID
  Future<bool> deletePermit(String permitId) async {
    try {
      final response = await _permitAPI.deletePermit(permitId);
      return response['success'] == true;
    } catch (error) {
      throw Exception('Failed to delete permit: $error');
    }
  }

  getPermits() {}
  */

}


