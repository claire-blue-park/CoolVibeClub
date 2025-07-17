//
//  WorldView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import Alamofire
import SwiftUI

struct WorldView: View {
    @State private var selectedCountry: Country? = countries[0]
    @State private var activities: [ActivityInfoData] = []
    @State private var selectedCategory: String = activityCategories[0]
    @State private var isLoading: Bool = false
    static let countries: [Country] = [
        Country(name: "전체", imageName: "img_globe"),
        Country(name: "대한민국", imageName: "img_korea"),
        Country(name: "일본", imageName: "img_japan"),
        Country(name: "호주", imageName: "img_australia"),
        Country(name: "필리핀", imageName: "img_philippines"),
        Country(name: "태국", imageName: "img_thailand"),
    ]
    static let activityCategories: [String] = ["전체", "투어", "관광", "패키지", "익사이팅", "체험"]
    var body: some View {
        VStack(spacing: 12) {
            NavBarView(title: "Cool Vibe Club", rightItems: nil)
                .frame(maxWidth: .infinity)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Self.countries) { country in
                        CountryIconView(
                            country: country,
                            isSelected: country == selectedCountry
                        )
                        .onTapGesture {
                            selectedCountry = country
                            Task { await fetchActivities() }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // 액티비티 카테고리 선택 뷰
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Self.activityCategories, id: \.self) { category in
                        ActivityCategoryView(
                            category: category,
                            isSelected: category == selectedCategory
                        )
                        .onTapGesture {
                            selectedCategory = category
                            Task { await fetchActivities() }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(activities) { activity in
                            ActivityInfoView(
                                activityData: activity,
                                onLikeTapped: {},
                                onNavigateTapped: {}
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .task {
            await fetchActivities()
        }
    }

    // 네트워크에서 액티비티 목록 조회
    private func fetchActivities() async {
        // print("fetchActivities() 호출됨")  // 👈 함수 진입 print
        isLoading = true
        defer { isLoading = false }
        let countryParam = (selectedCountry?.name == "전체") ? nil : selectedCountry?.name
        let categoryParam = (selectedCategory == "전체") ? nil : selectedCategory
        let endpoint = ActivityEndpoint(
            requestType: .activityList(
                country: countryParam, category: categoryParam))
        do {
            let response: ActivityResponse = try await NetworkManager.shared.fetch(
                from: endpoint, responseError: ActivityResponseError.self)
            // print("네트워크 응답 데이터:", response)
            // print("response.data:", response.data)

            self.activities = response.data.map { item in
                ActivityInfoData(
                    imageName: item.thumbnails.first ?? "sample_activity",
                    price: "\(item.price.final)원",
                    isLiked: item.isKeep,
                    title: item.title,
                    country: item.country,
                    category: item.category
                )
            }
        } catch {
            print("네트워크 에러:", error)  // 👈 이 부분 추가
            // 실패 시 기존 데이터 유지, 필요시 에러 핸들링
        }
    }
}

#Preview {
    WorldView()
}
