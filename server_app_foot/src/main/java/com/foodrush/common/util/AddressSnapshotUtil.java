package com.foodrush.common.util;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.StringJoiner;

@Component("addressUtil")
@RequiredArgsConstructor
public class AddressSnapshotUtil {

    private final ObjectMapper objectMapper;

    /**
     * Parse a JSON address snapshot and return a human-readable string.
     * Input: {"label":"Nhà","streetLine1":"12 Nguyễn Trãi","streetLine2":"","city":"TP HCM",...}
     * Output: Nhà · 12 Nguyễn Trãi, TP Hồ Chí Minh 70000
     */
    public String format(String json) {
        if (json == null || json.isBlank()) return "";
        try {
            Map<String, String> map = objectMapper.readValue(json, new TypeReference<>() {});

            String label     = nullToEmpty(map.get("label"));
            String street1   = nullToEmpty(map.get("streetLine1"));
            String street2   = nullToEmpty(map.get("streetLine2"));
            String city      = nullToEmpty(map.get("city"));
            String state     = nullToEmpty(map.get("state"));
            String postal    = nullToEmpty(map.get("postalCode"));

            // Build street part
            StringJoiner street = new StringJoiner(", ");
            if (!street1.isEmpty()) street.add(street1);
            if (!street2.isEmpty()) street.add(street2);

            // Build locality: city (skip state if identical to city)
            StringJoiner locality = new StringJoiner(", ");
            if (!city.isEmpty()) locality.add(city);
            if (!state.isEmpty() && !state.equalsIgnoreCase(city)) locality.add(state);
            if (!postal.isEmpty()) locality.add(postal);

            // Combine
            StringJoiner result = new StringJoiner(" · ");
            if (!label.isEmpty())           result.add(label);
            if (street.length() > 0)        result.add(street.toString());
            if (locality.length() > 0)      result.add(locality.toString());

            return result.toString();
        } catch (Exception e) {
            // If parsing fails, return raw string (better than nothing)
            return json;
        }
    }

    private String nullToEmpty(String s) {
        return s == null ? "" : s.trim();
    }
}
