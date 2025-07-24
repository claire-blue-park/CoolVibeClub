import Foundation

// MARK: - ActivityDetailAction
enum ActivityDetailAction {
    case setLoading(Bool)
    case setActivityDetail(ActivityDetailResponse?)
    case setError(String?)
    case setNavigationDestination(NavigationDestination?)
}

// MARK: - ActivityDetailReducer (순수 함수)
func activityDetailReducer(state: inout ActivityDetailState, action: ActivityDetailAction) {
    switch action {
    case .setLoading(let isLoading):
        state.isLoading = isLoading
        
    case .setActivityDetail(let detail):
        state.activityDetail = detail
        
    case .setError(let error):
        state.errorMessage = error
        
    case .setNavigationDestination(let destination):
        state.navigationDestination = destination
    }
}