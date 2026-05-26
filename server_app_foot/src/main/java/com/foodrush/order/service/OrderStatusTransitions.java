package com.foodrush.order.service;

import com.foodrush.common.enums.OrderStatus;
import com.foodrush.common.exceptions.BusinessRuleException;

import java.util.EnumSet;
import java.util.Map;

/**
 * Single source of truth cho luồng chuyển trạng thái đơn hàng và phân quyền
 * theo từng role (owner/shipper). API layer và web layer (admin/owner/shipper)
 * đều phải đi qua các hàm ở đây để đảm bảo nhất quán.
 *
 * Luồng chuẩn:
 *   PENDING → CONFIRMED → PREPARING → READY_FOR_PICKUP
 *                                            ↓
 *                                        PICKED_UP → ON_THE_WAY → DELIVERED
 *   PENDING / CONFIRMED → CANCELLED (khách hoặc owner huỷ)
 */
public final class OrderStatusTransitions {

    private OrderStatusTransitions() {}

    /** Toàn bộ transition hợp lệ (không phân quyền). */
    private static final Map<OrderStatus, EnumSet<OrderStatus>> ALL_TRANSITIONS = Map.of(
            OrderStatus.PENDING,          EnumSet.of(OrderStatus.CONFIRMED, OrderStatus.CANCELLED),
            OrderStatus.CONFIRMED,        EnumSet.of(OrderStatus.PREPARING, OrderStatus.CANCELLED),
            OrderStatus.PREPARING,        EnumSet.of(OrderStatus.READY_FOR_PICKUP),
            OrderStatus.READY_FOR_PICKUP, EnumSet.of(OrderStatus.PICKED_UP),
            OrderStatus.PICKED_UP,        EnumSet.of(OrderStatus.ON_THE_WAY),
            OrderStatus.ON_THE_WAY,       EnumSet.of(OrderStatus.DELIVERED)
    );

    /** Transition mà owner (nhà hàng) được phép thực hiện. */
    private static final Map<OrderStatus, EnumSet<OrderStatus>> OWNER_TRANSITIONS = Map.of(
            OrderStatus.PENDING,    EnumSet.of(OrderStatus.CONFIRMED, OrderStatus.CANCELLED),
            OrderStatus.CONFIRMED,  EnumSet.of(OrderStatus.PREPARING, OrderStatus.CANCELLED),
            OrderStatus.PREPARING,  EnumSet.of(OrderStatus.READY_FOR_PICKUP)
    );

    /** Transition mà shipper được phép thực hiện. */
    private static final Map<OrderStatus, EnumSet<OrderStatus>> SHIPPER_TRANSITIONS = Map.of(
            OrderStatus.READY_FOR_PICKUP, EnumSet.of(OrderStatus.PICKED_UP),
            OrderStatus.PICKED_UP,        EnumSet.of(OrderStatus.ON_THE_WAY),
            OrderStatus.ON_THE_WAY,       EnumSet.of(OrderStatus.DELIVERED)
    );

    public static EnumSet<OrderStatus> nextStatesFor(OrderStatus current) {
        return ALL_TRANSITIONS.getOrDefault(current, EnumSet.noneOf(OrderStatus.class));
    }

    public static void ensureAllowed(OrderStatus current, OrderStatus next) {
        if (!ALL_TRANSITIONS.getOrDefault(current, EnumSet.noneOf(OrderStatus.class)).contains(next)) {
            throw new BusinessRuleException("ORDER_003",
                    "Không thể chuyển từ trạng thái " + current + " sang " + next);
        }
    }

    public static void ensureOwnerAllowed(OrderStatus current, OrderStatus next) {
        if (!OWNER_TRANSITIONS.getOrDefault(current, EnumSet.noneOf(OrderStatus.class)).contains(next)) {
            throw new BusinessRuleException("ORDER_003",
                    "Nhà hàng không được phép chuyển từ " + current + " sang " + next);
        }
    }

    public static void ensureShipperAllowed(OrderStatus current, OrderStatus next) {
        if (!SHIPPER_TRANSITIONS.getOrDefault(current, EnumSet.noneOf(OrderStatus.class)).contains(next)) {
            throw new BusinessRuleException("ORDER_003",
                    "Shipper không được phép chuyển từ " + current + " sang " + next);
        }
    }
}
