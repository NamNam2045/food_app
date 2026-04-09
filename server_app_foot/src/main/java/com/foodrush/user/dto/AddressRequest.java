package com.foodrush.user.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class AddressRequest {
    @NotBlank private String label;
    @NotBlank private String streetLine1;
    private String streetLine2;
    @NotBlank private String city;
    @NotBlank private String state;
    @NotBlank private String postalCode;
    private String countryCode = "VN";
    private BigDecimal latitude;
    private BigDecimal longitude;
    private boolean defaultAddress;
}
