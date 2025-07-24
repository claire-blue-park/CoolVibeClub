//
//  OrderResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 8/7/25.
//

import Foundation

struct OrderResponse: Codable {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}
