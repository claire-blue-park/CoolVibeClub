//
//  NetworkManaging.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
//

import Foundation

protocol NetworkManaging {
  func fetch<T: Decodable, E: ResponseErrorManaging>(from endpoint: Endpoint, responseError: E.Type) async throws -> T
}
