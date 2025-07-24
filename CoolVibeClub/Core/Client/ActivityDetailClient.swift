import Foundation

// MARK: - ActivityDetailClient
struct ActivityDetailClient {
    let fetchActivityDetail: (String) async throws -> ActivityDetailResponse
}

// MARK: - Live Implementation
extension ActivityDetailClient {
    static let live = ActivityDetailClient(
        fetchActivityDetail: { activityId in
            let endpoint = ActivityEndpoint(requestType: .activityDetail(activityId: activityId))
            
            let response: ActivityDetailResponse = try await NetworkManager.shared.fetch(
                from: endpoint,
                errorMapper: { status, error in
                    ActivityDetailError.map(statusCode: status, message: error.message)
                }
            )
            
            return response
        }
    )
}

// MARK: - Mock Implementation (테스트용)
extension ActivityDetailClient {
    static let mock = ActivityDetailClient(
        fetchActivityDetail: { activityId in
            print("🧪 Mock ActivityDetail 데이터 반환: \(activityId)")
            
            // Mock 지연 시뮬레이션
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5초
            
            let mockResponse = ActivityDetailResponse(
                activityId: activityId,
                title: "제주도 한라산 등반 체험",
                country: "대한민국",
                category: "등반",
                thumbnails: [
                    "https://picsum.photos/400/300?random=10",
                    "https://picsum.photos/400/300?random=11", 
                    "https://picsum.photos/400/300?random=12"
                ],
                geolocation: DetailGeolocation(longitude: 126.9780, latitude: 37.5665),
                startDate: "2025-08-01",
                endDate: "2025-08-01",
                price: DetailPrice(original: 100000, final: 89000),
                tags: ["등반", "제주도", "한라산", "가이드동행"],
                pointReward: 1000,
                restrictions: DetailRestrictions(minHeight: 140, minAge: 12, maxParticipants: 20),
                description: "아름다운 제주도 한라산에서 즐기는 등반 체험입니다. 전문 가이드와 함께 안전하게 산행을 즐기실 수 있으며, 정상에서 바라보는 제주도의 전경은 잊을 수 없는 추억이 될 것입니다.",
                isAdvertisement: false,
                isKeep: false,
                keepCount: 15,
                totalOrderCount: 234,
                schedule: [
                    DetailSchedule(duration: "08:00-09:00", description: "집결 및 장비 점검"),
                    DetailSchedule(duration: "09:00-12:00", description: "한라산 등반"),
                    DetailSchedule(duration: "12:00-13:00", description: "정상에서 점심"),
                    DetailSchedule(duration: "13:00-16:00", description: "하산")
                ],
                reservationList: nil,
                creator: DetailCreator(userId: "guide123", nick: "제주가이드", profileImage: nil, introduction: "제주도 전문 가이드입니다."),
                createdAt: "2025-01-01T00:00:00Z",
                updatedAt: "2025-01-28T00:00:00Z"
            )
            
            return mockResponse
        }
    )
}