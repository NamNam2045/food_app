package com.foodrush.restaurant.service;

import com.foodrush.common.dto.PageResponse;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.restaurant.dto.*;
import com.foodrush.restaurant.entity.OperatingHours;
import com.foodrush.restaurant.entity.Restaurant;
import com.foodrush.restaurant.repository.OperatingHoursRepository;
import com.foodrush.restaurant.repository.RestaurantRepository;
import com.foodrush.user.entity.User;
import com.foodrush.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class RestaurantServiceImpl implements RestaurantService {

    private final RestaurantRepository restaurantRepository;
    private final OperatingHoursRepository operatingHoursRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public PageResponse<RestaurantSummaryResponse> getRestaurants(String city, String cuisineType,
            String search, Boolean isOpen, Double lat, Double lng, Double maxDistanceKm,
            int page, int size, String sortBy) {

        Sort sort = switch (sortBy != null ? sortBy : "") {
            case "rating"       -> Sort.by(Sort.Direction.DESC, "ratingAvg");
            case "deliveryTime" -> Sort.by(Sort.Direction.ASC, "estimatedDeliveryMinutes");
            case "distance"     -> Sort.by(Sort.Direction.ASC, "id"); // fallback; real distance sort done by DB
            default             -> Sort.by(Sort.Direction.DESC, "ratingAvg");
        };
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Restaurant> restaurants;
        // Nếu có toạ độ thì tìm theo khoảng cách
        if (lat != null && lng != null) {
            double km = maxDistanceKm != null ? maxDistanceKm : 10.0;
            restaurants = restaurantRepository.findNearby(lat, lng, km, isOpen, pageable);
        } else {
            restaurants = restaurantRepository.findWithFilters(city, cuisineType, search, isOpen, pageable);
        }

        return PageResponse.from(restaurants.map(this::toSummaryResponse));
    }

    @Override
    @Transactional(readOnly = true)
    public RestaurantResponse getById(Long id) {
        return toFullResponse(findById(id));
    }

    @Override
    @Transactional(readOnly = true)
    public RestaurantResponse getBySlug(String slug) {
        Restaurant r = restaurantRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Nhà hàng không tồn tại"));
        return toFullResponse(r);
    }

    @Override
    public RestaurantResponse create(CreateRestaurantRequest request, Long ownerId) {
        String slug = generateSlug(request.getName());
        if (restaurantRepository.existsBySlug(slug)) {
            slug = slug + "-" + System.currentTimeMillis();
        }
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new ResourceNotFoundException("Người dùng không tồn tại"));

        Restaurant restaurant = Restaurant.builder()
                .owner(owner).name(request.getName()).slug(slug)
                .description(request.getDescription()).cuisineType(request.getCuisineType())
                .logoUrl(request.getLogoUrl()).bannerUrl(request.getBannerUrl())
                .phone(request.getPhone()).email(request.getEmail())
                .streetAddress(request.getStreetAddress()).city(request.getCity())
                .latitude(request.getLatitude()).longitude(request.getLongitude())
                .minOrderAmount(request.getMinOrderAmount() != null ? request.getMinOrderAmount() : BigDecimal.ZERO)
                .deliveryFee(request.getDeliveryFee() != null ? request.getDeliveryFee() : BigDecimal.ZERO)
                .estimatedDeliveryMinutes(request.getEstimatedDeliveryMinutes() != null ? request.getEstimatedDeliveryMinutes() : 30)
                .build();

        restaurant = restaurantRepository.save(restaurant);
        if (request.getOperatingHours() != null) {
            saveOperatingHours(restaurant, request.getOperatingHours());
        }
        return toFullResponse(restaurant);
    }

    @Override
    public RestaurantResponse update(Long id, UpdateRestaurantRequest request, Long ownerId) {
        Restaurant restaurant = findById(id);
        if (!restaurant.getOwner().getId().equals(ownerId)) {
            throw new BusinessRuleException("FORBIDDEN", "Bạn không có quyền chỉnh sửa nhà hàng này");
        }
        if (StringUtils.hasText(request.getName())) restaurant.setName(request.getName());
        if (StringUtils.hasText(request.getDescription())) restaurant.setDescription(request.getDescription());
        if (StringUtils.hasText(request.getCuisineType())) restaurant.setCuisineType(request.getCuisineType());
        if (StringUtils.hasText(request.getLogoUrl())) restaurant.setLogoUrl(request.getLogoUrl());
        if (StringUtils.hasText(request.getBannerUrl())) restaurant.setBannerUrl(request.getBannerUrl());
        if (StringUtils.hasText(request.getPhone())) restaurant.setPhone(request.getPhone());
        if (StringUtils.hasText(request.getStreetAddress())) restaurant.setStreetAddress(request.getStreetAddress());
        if (StringUtils.hasText(request.getCity())) restaurant.setCity(request.getCity());
        if (request.getLatitude() != null) restaurant.setLatitude(request.getLatitude());
        if (request.getLongitude() != null) restaurant.setLongitude(request.getLongitude());
        if (request.getMinOrderAmount() != null) restaurant.setMinOrderAmount(request.getMinOrderAmount());
        if (request.getDeliveryFee() != null) restaurant.setDeliveryFee(request.getDeliveryFee());
        if (request.getEstimatedDeliveryMinutes() != null) restaurant.setEstimatedDeliveryMinutes(request.getEstimatedDeliveryMinutes());
        if (request.getActive() != null) restaurant.setActive(request.getActive());
        if (request.getOpen() != null) restaurant.setOpen(request.getOpen());
        if (request.getOperatingHours() != null) {
            operatingHoursRepository.deleteByRestaurantId(id);
            saveOperatingHours(restaurant, request.getOperatingHours());
        }
        return toFullResponse(restaurantRepository.save(restaurant));
    }

    @Override
    public RestaurantResponse updateLogo(Long id, String logoUrl, Long actorId, boolean systemAdmin) {
        Restaurant restaurant = findById(id);
        ensureCanManageRestaurant(restaurant, actorId, systemAdmin);
        restaurant.setLogoUrl(logoUrl);
        return toFullResponse(restaurantRepository.save(restaurant));
    }

    @Override
    public RestaurantResponse updateBanner(Long id, String bannerUrl, Long actorId, boolean systemAdmin) {
        Restaurant restaurant = findById(id);
        ensureCanManageRestaurant(restaurant, actorId, systemAdmin);
        restaurant.setBannerUrl(bannerUrl);
        return toFullResponse(restaurantRepository.save(restaurant));
    }

    @Override
    public void delete(Long id) {
        Restaurant restaurant = findById(id);
        restaurant.setActive(false);
        restaurantRepository.save(restaurant);
    }

    private Restaurant findById(Long id) {
        return restaurantRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Nhà hàng không tồn tại"));
    }

    private void ensureCanManageRestaurant(Restaurant restaurant, Long actorId, boolean systemAdmin) {
        if (systemAdmin) {
            return;
        }
        if (!restaurant.getOwner().getId().equals(actorId)) {
            throw new BusinessRuleException("FORBIDDEN", "Bạn không có quyền chỉnh sửa nhà hàng này");
        }
    }

    private void saveOperatingHours(Restaurant restaurant, List<OperatingHoursRequest> hours) {
        hours.forEach(h -> {
            OperatingHours oh = OperatingHours.builder()
                    .restaurant(restaurant).dayOfWeek(h.getDayOfWeek())
                    .openTime(h.getOpenTime()).closeTime(h.getCloseTime())
                    .closed(h.isClosed()).build();
            operatingHoursRepository.save(oh);
        });
    }

    private RestaurantSummaryResponse toSummaryResponse(Restaurant r) {
        return RestaurantSummaryResponse.builder()
                .id(r.getId()).name(r.getName()).slug(r.getSlug())
                .cuisineType(r.getCuisineType()).logoUrl(r.getLogoUrl()).bannerUrl(r.getBannerUrl())
                .ratingAvg(r.getRatingAvg()).ratingCount(r.getRatingCount())
                .deliveryFee(r.getDeliveryFee()).estimatedDeliveryMinutes(r.getEstimatedDeliveryMinutes())
                .open(r.isOpen()).city(r.getCity()).build();
    }

    private RestaurantResponse toFullResponse(Restaurant r) {
        List<OperatingHoursResponse> hours = r.getOperatingHours().stream()
                .map(oh -> OperatingHoursResponse.builder()
                        .dayOfWeek(oh.getDayOfWeek()).openTime(oh.getOpenTime())
                        .closeTime(oh.getCloseTime()).closed(oh.isClosed()).build())
                .collect(Collectors.toList());
        return RestaurantResponse.builder()
                .id(r.getId()).name(r.getName()).slug(r.getSlug()).description(r.getDescription())
                .cuisineType(r.getCuisineType()).logoUrl(r.getLogoUrl()).bannerUrl(r.getBannerUrl())
                .phone(r.getPhone()).streetAddress(r.getStreetAddress()).city(r.getCity())
                .latitude(r.getLatitude()).longitude(r.getLongitude())
                .ratingAvg(r.getRatingAvg()).ratingCount(r.getRatingCount())
                .minOrderAmount(r.getMinOrderAmount()).deliveryFee(r.getDeliveryFee())
                .estimatedDeliveryMinutes(r.getEstimatedDeliveryMinutes())
                .active(r.isActive()).open(r.isOpen()).createdAt(r.getCreatedAt())
                .operatingHours(hours).build();
    }

    private String generateSlug(String name) {
        String normalized = Normalizer.normalize(name, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        return pattern.matcher(normalized).replaceAll("")
                .toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-").replaceAll("-+", "-").trim();
    }
}
