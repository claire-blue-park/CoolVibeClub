import SwiftUI

// MARK: - ActivityClient Environment Key
internal struct ActivityClientKey: EnvironmentKey {
    static let defaultValue = ActivityClient.live
}

// MARK: - ActivityDetailClient Environment Key
private struct ActivityDetailClientKey: EnvironmentKey {
    static let defaultValue = ActivityDetailClient.live
}

extension EnvironmentValues {
    var activityClient: ActivityClient {
        get { self[ActivityClientKey.self] }
        set { self[ActivityClientKey.self] = newValue }
    }
    
    var activityDetailClient: ActivityDetailClient {
        get { self[ActivityDetailClientKey.self] }
        set { self[ActivityDetailClientKey.self] = newValue }
    }
}