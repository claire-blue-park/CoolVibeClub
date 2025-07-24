import Foundation

// MARK: - ActivityAction (Intent의 결과)
enum ActivityAction {
    case setLoading(Bool)
    case setSelectedCountry(CountryCategories)
    case setSelectedCategory(String)
    case setActivities([ActivityInfoData])
    case setError(String?)
}

// MARK: - ActivityReducer (순수 함수)
func activityReducer(state: inout ActivityState, action: ActivityAction) {
    switch action {
    case .setLoading(let isLoading):
        state.isLoading = isLoading
        
    case .setSelectedCountry(let country):
        state.selectedCountry = country
        
    case .setSelectedCategory(let category):
        state.selectedCategory = category
        
    case .setActivities(let activities):
        state.activities = activities
        
    case .setError(let error):
        state.errorMessage = error
    }
}