import Foundation

// MARK: - ActivityIntent
enum ActivityIntent {
    // 필터링 Intent
    case selectCountry(CountryCategories)
    case selectCategory(String)
    
    // 데이터 로딩 Intent  
    case loadActivities
    case refreshActivities
    
    // 네비게이션 Intent
    case navigateToAllActivities
    case navigateToActivityDetail(ActivityInfoData)
    
    // 에러 처리 Intent
    case clearError
}