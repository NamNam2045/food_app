package com.foodrush.restaurant.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalTime;

@Data @Builder
public class OperatingHoursResponse {
    private Integer dayOfWeek;
    private LocalTime openTime;
    private LocalTime closeTime;
    private boolean closed;
}
