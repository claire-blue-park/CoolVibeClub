//
//  Intent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/12/25.
//

import Foundation
import Combine

// MARK: - 각 화면 액션 전송 규약
protocol Intent: ObservableObject {
    associatedtype State: StateMarker
    associatedtype ActionType: ActionMarker
    
    var state: State { get }
    func send(_ action: ActionType)
}

// MARK: - 화면 상태 마커
protocol StateMarker {
    var isLoading: Bool { get set }
    var error: String? { get set }
}

// MARK: - 화면 액션 마커
protocol ActionMarker { }

// MARK: - ViewState 확장
extension StateMarker {
    var hasError: Bool {
        return error != nil
    }
}
