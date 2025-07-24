//
//  BaseViewModel.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

protocol BaseViewModel {
  associatedtype Input
  associatedtype Output
  
  func transform()
}
