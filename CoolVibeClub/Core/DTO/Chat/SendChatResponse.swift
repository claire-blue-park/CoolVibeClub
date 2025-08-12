//
//  SendChatResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct SendChatResponse: Decodable {
    let content: String
    let files: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(String.self, forKey: .content)
        files = try container.decodeIfPresent([String].self, forKey: .files) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case content, files
    }
}