import Foundation

// MARK: - ActivityClient 
struct ChatRoomClient {
    let fetchActivities: (String?, String?) async throws -> [ActivityInfoData]
}

// MARK: - Live Implementation
extension ChatRoomClient {
    static let live = ActivityClient(
        fetchActivities: { country, category in
            let endpoint = ActivityEndpoint(requestType: .newActivity(country: country, category: category))
            
            let response: ActivityResponse = try await NetworkManager.shared.fetch(
                from: endpoint,
                errorMapper: { status, error in
                  // 📍 TODO: - 에러 수정
                  CommonError.map(statusCode: status, message: error.message)
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
extension ChatRoomClient {
    static let mock = ActivityClient(
        fetchActivities: { _, _ in
            // Mock 데이터 반환
            return []
        }
    )
}
