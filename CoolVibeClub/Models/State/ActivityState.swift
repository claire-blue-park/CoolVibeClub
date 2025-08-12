import Foundation

// MARK: - ActivityState
struct ActivityState {
    var selectedCountry: CountryCategories
    var selectedCategory: String
    var activities: [ActivityInfoData]
    var isLoading: Bool
    var errorMessage: String?
    
    // MARK: - Static Data
    static let countries: [CountryCategories] = Country.allCases.map { CountryCategories(country: $0) }
    
    static let activityCategories: [String] = ActivityCategory.allCases.map { $0.rawValue }
    
    // MARK: - Initial State
    static let initial = ActivityState(
        selectedCountry: CountryCategories(country: .all),
        selectedCategory: ActivityCategory.all.rawValue,
        activities: [],
        isLoading: false,
        errorMessage: nil
    )
}