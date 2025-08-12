//
//  PaymentValidationResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct PaymentValidationResponse: Codable {
    let paymentId: String
    let orderItem: OrderItem
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case paymentId = "payment_id"
        case orderItem = "order_item"
        case createdAt, updatedAt
    }
}

struct OrderItem: Codable {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let reservationItemName: String
    let reservationItemTime: String
    let participantCount: Int
    let activity: ValidationActivityDetail
    let paidAt: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case reservationItemName = "reservation_item_name"
        case reservationItemTime = "reservation_item_time"
        case participantCount = "participant_count"
        case activity, paidAt, createdAt, updatedAt
    }
}

struct ValidationActivityDetail: Codable {
    let id: String
    let title: String
    let country: String
    let category: String
    let thumbnails: [String]
    let geolocation: ValidationGeolocation
    let price: ValidationPrice
    let tags: [String]
    let pointReward: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, country, category, thumbnails, geolocation, price, tags
        case pointReward = "point_reward"
    }
}

struct ValidationPrice: Codable {
    let original: Int
    let final: Int
}

struct ValidationGeolocation: Codable {
    let longitude: Double
    let latitude: Double
}