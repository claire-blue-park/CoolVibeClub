//
//  ChatFileUploadResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

// MARK: - Primary Response Structure
struct ChatFileUploadResponse: Decodable {
    let data: ChatFileUploadData?
    let fileUrls: [String]?
    let files: [String]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try nested data structure first
        if let data = try? container.decode(ChatFileUploadData.self, forKey: .data) {
            self.data = data
            self.fileUrls = nil
            self.files = nil
        }
        // Try direct fileUrls array
        else if let fileUrls = try? container.decode([String].self, forKey: .fileUrls) {
            self.data = nil
            self.fileUrls = fileUrls
            self.files = nil
        }
        // Try direct files array
        else if let files = try? container.decode([String].self, forKey: .files) {
            self.data = nil
            self.fileUrls = nil
            self.files = files
        }
        // If none of the above work, try as root level array
        else {
            self.data = nil
            self.fileUrls = try? container.decode([String].self, forKey: .fileUrls)
            self.files = try? container.decode([String].self, forKey: .files)
        }
    }
    
    // Helper to get the actual file URLs regardless of structure
    var actualFileUrls: [String] {
        return data?.fileUrls ?? fileUrls ?? files ?? []
    }
    
    private enum CodingKeys: String, CodingKey {
        case data, fileUrls, files
    }
}

struct ChatFileUploadData: Decodable {
    let fileUrls: [String]
}