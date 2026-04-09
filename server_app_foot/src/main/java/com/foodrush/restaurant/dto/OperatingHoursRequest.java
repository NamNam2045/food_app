package com.foodrush.restaurant.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalTime;

@Data
public class OperatingHoursRequest {
    @NotNull private Integer dayOfWeek;
    @NotNull private LocalTime openTime;
    @NotNull private LocalTime closeTime;
    private boolean closed = false;
}
