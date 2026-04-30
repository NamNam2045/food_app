import '../../../core/network/api_client.dart';
import 'models/address_model.dart';
import 'models/user_profile_model.dart';

class UserRepository {
  UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserProfileModel> getProfile() async {
    final data = await _apiClient.get('/users/me');
    return UserProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    final data = await _apiClient.put(
      '/users/me',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'profilePictureUrl': profilePictureUrl,
      }..removeWhere((_, value) => value == null || value.toString().isEmpty),
    );
    return UserProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AddressModel>> getAddresses() async {
    final data = await _apiClient.get('/users/me/addresses');
    final items = data as List?;
    return items
            ?.whereType<Map<String, dynamic>>()
            .map(AddressModel.fromJson)
            .toList(growable: false) ??
        const <AddressModel>[];
  }

  Future<AddressModel> addAddress({
    required String label,
    required String streetLine1,
    String? streetLine2,
    required String city,
    required String state,
    required String postalCode,
    String countryCode = 'VN',
    double? latitude,
    double? longitude,
    bool defaultAddress = false,
  }) async {
    final data = await _apiClient.post(
      '/users/me/addresses',
      body: {
        'label': label,
        'streetLine1': streetLine1,
        'streetLine2': streetLine2,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'countryCode': countryCode,
        'latitude': latitude,
        'longitude': longitude,
        'defaultAddress': defaultAddress,
      }..removeWhere((_, value) => value == null || value.toString().isEmpty),
    );
    return AddressModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AddressModel> updateAddress({
    required int addressId,
    required String label,
    required String streetLine1,
    String? streetLine2,
    required String city,
    required String state,
    required String postalCode,
    String countryCode = 'VN',
    double? latitude,
    double? longitude,
    bool defaultAddress = false,
  }) async {
    final data = await _apiClient.put(
      '/users/me/addresses/$addressId',
      body: {
        'label': label,
        'streetLine1': streetLine1,
        'streetLine2': streetLine2,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'countryCode': countryCode,
        'latitude': latitude,
        'longitude': longitude,
        'defaultAddress': defaultAddress,
      }..removeWhere((_, value) => value == null || value.toString().isEmpty),
    );
    return AddressModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteAddress(int addressId) async {
    await _apiClient.delete('/users/me/addresses/$addressId');
  }
}
