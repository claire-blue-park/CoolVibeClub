import Foundation

// MARK: - ActivityDetailIntentEnum (renamed to avoid conflict)
enum ActivityDetailIntentEnum {
    case loadActivityDetail(String) // activityId
    case refreshActivityDetail(String)
    case clearError
    case navigateToChat(userId: String, nickname: String)
    case clearNavigation
}