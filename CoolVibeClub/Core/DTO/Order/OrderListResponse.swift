//
//  OrderListResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 8/7/25.
//

import Foundation

struct OrderListResponse: Decodable {
    let data: [Order]
}

struct Order: Decodable {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let review: Review
    let reservationItemName: String
    let reservationItemTime: String
    let participantCount: Int
    let activity: Activity
    let paidAt: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case review
        case reservationItemName = "reservation_item_name"
        case reservationItemTime = "reservation_item_time"
        case participantCount = "participant_count"
        case activity
        case paidAt
        case createdAt
        case updatedAt
    }
}

struct Review: Decodable {
    let id: String
    let rating: Int
}

//struct Activity: Decodable {
//    let id: String
//    let title: String
//    let country: String
//    let category: String
//    let thumbnails: [String]
//    let geolocation: Geolocation
//    let price: Price
//    let tags: [String]
//    let pointReward: Int
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case country
//        case category
//        case thumbnails
//        case geolocation
//        case price
//        case tags
//        case pointReward = "point_reward"
//    }
//}
//
//struct Geolocation: Codable {
//    let longitude: Double
//    let latitude: Double
//}
//
//struct Price: Codable {
//    let original: Int
//    let final: Int
//}
