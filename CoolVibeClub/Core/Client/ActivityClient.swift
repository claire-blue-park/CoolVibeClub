import Foundation

// MARK: - ActivityClient 
struct ActivityClient {
    let fetchActivities: (String?, String?) async throws -> [ActivityInfoData]
}

// MARK: - Live Implementation
extension ActivityClient {
    static let live = ActivityClient(
        fetchActivities: { country, category in
            print("🌍 ActivityClient - 요청 파라미터: country=\(country ?? "nil"), category=\(category ?? "nil")")
            
            let endpoint = ActivityEndpoint(requestType: .activityList(country: country, category: category))
            
            let response: ActivityResponse = try await NetworkManager.shared.fetch(
                from: endpoint,
                errorMapper: { status, error in
                    ActivityListError.map(statusCode: status, message: error.message)
                }
            )
            
            return response.data.map { item in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                
                let finalPriceFormatted = formatter.string(from: NSNumber(value: item.price.final)) ?? "\(item.price.final)"
                let originalPriceFormatted = formatter.string(from: NSNumber(value: item.price.original)) ?? "\(item.price.original)"
                
                return ActivityInfoData(
                    activityId: item.activityId,
                    imageName: item.thumbnails.first ?? "sample_activity",
                    price: "\(finalPriceFormatted)원",
                    isLiked: item.isKeep,
                    title: item.title,
                    country: item.country,
                    category: item.category,
                    tags: item.tags,
                    originalPrice: "\(originalPriceFormatted)원",
                    discountRate: item.price.discountRate
                )
            }
        }
    )
}

// MARK: - Mock Implementation (테스트용)
extension ActivityClient {
    static let mock = ActivityClient(
        fetchActivities: { _, _ in
            // Mock 데이터 반환
            return []
        }
    )
}
