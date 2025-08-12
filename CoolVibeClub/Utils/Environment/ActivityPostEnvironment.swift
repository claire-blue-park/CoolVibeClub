//
//  ActivityPostEnvironment.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

// MARK: - ActivityPostClient Environment Key
private struct ActivityPostClientKey: EnvironmentKey {
    static let defaultValue = ActivityPostClient.live
}

extension EnvironmentValues {
    var activityPostClient: ActivityPostClient {
        get { self[ActivityPostClientKey.self] }
        set { self[ActivityPostClientKey.self] = newValue }
    }
}