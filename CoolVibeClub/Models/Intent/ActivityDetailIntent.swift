import Foundation

// MARK: - ActivityDetailIntent
enum ActivityDetailIntent {
    case loadActivityDetail(String) // activityId
    case refreshActivityDetail(String)
    case clearError
    case navigateToChat(userId: String, nickname: String)
    case clearNavigation
}