import Foundation

// MARK: - NavigationDestination
enum NavigationDestination: Equatable {
    case chat(userId: String, nickname: String)
}

// MARK: - ActivityDetailState
struct ActivityDetailState {
    var activityDetail: ActivityDetailResponse?
    var isLoading: Bool
    var errorMessage: String?
    var navigationDestination: NavigationDestination?
    
    // MARK: - Initial State
    static let initial = ActivityDetailState(
        activityDetail: nil,
        isLoading: false,
        errorMessage: nil,
        navigationDestination: nil
    )
}