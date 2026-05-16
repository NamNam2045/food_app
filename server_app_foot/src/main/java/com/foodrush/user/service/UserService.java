package com.foodrush.user.service;

import com.foodrush.user.dto.*;
import java.util.List;

public interface UserService {
    UserProfileResponse getProfile(Long userId);
    UserProfileResponse updateProfile(Long userId, UpdateProfileRequest request);
    UserProfileResponse updateProfileAvatar(Long userId, String profilePictureUrl);
    UserProfileResponse removeProfileAvatar(Long userId);
    List<AddressResponse> getAddresses(Long userId);
    AddressResponse addAddress(Long userId, AddressRequest request);
    AddressResponse updateAddress(Long userId, Long addressId, AddressRequest request);
    void deleteAddress(Long userId, Long addressId);
    void updateFcmToken(Long userId, String fcmToken);
}
