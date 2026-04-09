package com.foodrush.user.service;

import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.user.dto.*;
import com.foodrush.user.entity.Address;
import com.foodrush.user.entity.User;
import com.foodrush.user.repository.AddressRepository;
import com.foodrush.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final AddressRepository addressRepository;

    @Override
    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(Long userId) {
        User user = findUserById(userId);
        return toProfileResponse(user);
    }

    @Override
    public UserProfileResponse updateProfile(Long userId, UpdateProfileRequest request) {
        User user = findUserById(userId);
        if (StringUtils.hasText(request.getFirstName())) user.setFirstName(request.getFirstName());
        if (StringUtils.hasText(request.getLastName())) user.setLastName(request.getLastName());
        if (StringUtils.hasText(request.getPhoneNumber())) user.setPhoneNumber(request.getPhoneNumber());
        if (StringUtils.hasText(request.getProfilePictureUrl())) user.setProfilePictureUrl(request.getProfilePictureUrl());
        return toProfileResponse(userRepository.save(user));
    }

    @Override
    @Transactional(readOnly = true)
    public List<AddressResponse> getAddresses(Long userId) {
        return addressRepository.findByUserIdOrderByDefaultAddressDesc(userId)
                .stream().map(this::toAddressResponse).collect(Collectors.toList());
    }

    @Override
    public AddressResponse addAddress(Long userId, AddressRequest request) {
        User user = findUserById(userId);
        if (request.isDefaultAddress()) {
            addressRepository.clearDefaultForUser(userId);
        }
        Address address = Address.builder()
                .user(user)
                .label(request.getLabel())
                .streetLine1(request.getStreetLine1())
                .streetLine2(request.getStreetLine2())
                .city(request.getCity())
                .state(request.getState())
                .postalCode(request.getPostalCode())
                .countryCode(request.getCountryCode() != null ? request.getCountryCode() : "VN")
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .defaultAddress(request.isDefaultAddress())
                .build();
        return toAddressResponse(addressRepository.save(address));
    }

    @Override
    public AddressResponse updateAddress(Long userId, Long addressId, AddressRequest request) {
        Address address = addressRepository.findById(addressId)
                .filter(a -> a.getUser().getId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Địa chỉ không tồn tại"));

        if (request.isDefaultAddress()) {
            addressRepository.clearDefaultForUser(userId);
        }
        address.setLabel(request.getLabel());
        address.setStreetLine1(request.getStreetLine1());
        address.setStreetLine2(request.getStreetLine2());
        address.setCity(request.getCity());
        address.setState(request.getState());
        address.setPostalCode(request.getPostalCode());
        address.setLatitude(request.getLatitude());
        address.setLongitude(request.getLongitude());
        address.setDefaultAddress(request.isDefaultAddress());
        return toAddressResponse(addressRepository.save(address));
    }

    @Override
    public void deleteAddress(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId)
                .filter(a -> a.getUser().getId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Địa chỉ không tồn tại"));
        addressRepository.delete(address);
    }

    @Override
    public void updateFcmToken(Long userId, String fcmToken) {
        User user = findUserById(userId);
        user.setFcmToken(fcmToken);
        userRepository.save(user);
    }

    private User findUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Người dùng không tồn tại"));
    }

    private UserProfileResponse toProfileResponse(User u) {
        return UserProfileResponse.builder()
                .id(u.getId()).email(u.getEmail()).firstName(u.getFirstName())
                .lastName(u.getLastName()).phoneNumber(u.getPhoneNumber())
                .role(u.getRole().name()).profilePictureUrl(u.getProfilePictureUrl())
                .emailVerified(u.isEmailVerified()).lastLoginAt(u.getLastLoginAt())
                .createdAt(u.getCreatedAt()).build();
    }

    private AddressResponse toAddressResponse(Address a) {
        return AddressResponse.builder()
                .id(a.getId()).label(a.getLabel()).streetLine1(a.getStreetLine1())
                .streetLine2(a.getStreetLine2()).city(a.getCity()).state(a.getState())
                .postalCode(a.getPostalCode()).countryCode(a.getCountryCode())
                .latitude(a.getLatitude()).longitude(a.getLongitude())
                .defaultAddress(a.isDefaultAddress()).build();
    }
}
