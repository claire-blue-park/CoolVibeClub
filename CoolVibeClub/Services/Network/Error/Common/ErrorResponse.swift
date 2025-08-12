//
//  ErrorResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable {
    let message: String?
    let code: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        code = try container.decodeIfPresent(String.self, forKey: .code)
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case code
    }
}
