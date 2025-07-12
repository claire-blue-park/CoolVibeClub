//
//  Endpoint.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
//

import Foundation
import Alamofire

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters { get }
}


extension Endpoint {
    var fullURL: String {
        return baseURL + path
    }
}

