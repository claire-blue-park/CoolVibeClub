//
//  CVCImage.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

enum CVCImage {
  // MARK: - Tab Icons
  enum Tab {
    case globe
    case post
    case ticket
    case chat
    case profile
    
    var value: Image {
      let name = switch self {
      case .globe: "ic_globe"
      case .post: "ic_post"
      case .ticket: "ic_ticket"
      case .chat: "ic_chat"
      case .profile: "ic_profile"
      }
      return Image(name)
    }
    
    var template: some View {
      value.renderingMode(.template).resizable()
    }
  }
  
  // MARK: - Navigation Icons
  enum Navigation {
    case search
    case bell
    case bellNoti
    case noTailArrow
    case arrowLeft
    case arrowRight
    case menu
    case setting
    
    var value: Image {
      let name = switch self {
      case .search: "ic_search"
      case .bell: "ic_bell"
      case .bellNoti: "ic_bell_noti"
      case .noTailArrow: "ic_chevron"
      case .arrowLeft: "ic_arrow_left"
      case .arrowRight: "ic_arrow_right"
      case .menu: "ic_menu"
      case .setting: "ic_setting"
      }
      return Image(name)
    }
    
    var template: some View {
      value.renderingMode(.template).resizable()
    }
  }
  
  // MARK: - Action Icons
  enum Action {
    case heart
    case heartFill
    case star
    case starFill
    case sort
    case location
    case mapPin
    case flame
    case ref
    case won
    case point
    case buy
    case keep
    case distance
    case message
    case sparkle
    case info
    
    var value: Image {
      let name = switch self {
      case .heart: "ic_heart"
      case .heartFill: "ic_heart_fill"
      case .star: "ic_star"
      case .starFill: "ic_star_fill"
      case .sort: "ic_sort"
      case .location: "ic_location"
      case .mapPin: "ic_map_pin"
      case .flame: "ic_flame"
      case .ref: "ic_ref"
      case .won: "ic_won"
      case .point: "ic_point"
      case .buy: "ic_buy"
      case .keep: "ic_keep"
      case .distance: "ic_distance"
      case .message: "ic_message"
      case .sparkle: "ic_sparkle"
      case .info: "ic_info"
      }
      return Image(name)
    }
    
    var template: some View {
      value.renderingMode(.template).resizable()
    }
  }
  
  // MARK: - Brand & Logo
  enum Brand {
    case kakao
    case imagePlaceholder
    
    var value: Image {
      let name = switch self {
      case .kakao: "ic_kakao"
      case .imagePlaceholder: "ic_image_placeholder"
      }
      return Image(name)
    }
    
    var template: some View {
      value.renderingMode(.template).resizable()
    }
  }
  
  // MARK: - Country Flags
  enum Country {
    case korea
    case japan
    case australia
    case philippines
    case thailand
    case taiwan
    case argentina
    
    var value: Image {
      let name = switch self {
      case .korea: "country_korea"
      case .japan: "country_japan"
      case .australia: "country__australia"
      case .philippines: "country_philippines"
      case .thailand: "country_thailand"
      case .taiwan: "country_taiwan"
      case .argentina: "country_argentina"
      }
      return Image(name)
    }
    
    var template: some View {
      value.renderingMode(.template).resizable()
    }
  }
  
  // MARK: - Limit Icons
  enum Limit {
    case age
    case height
    case max
    
    var value: Image {
      let name = switch self {
      case .age: "ic_limit_age"
      case .height: "ic_limit_height"
      case .max: "ic_limit_max"
      }
      return Image(name)
    }
    
    var template: some View {
      value.renderingMode(.template).resizable()
    }
  }
  
  // MARK: - Legacy Support (기존 방식 유지)
  case globe
  case post
  case ticket
  case chat
  case profile
  case search
  case arrowRight
  case arrowLeft
  case bellNoti
  case bell
  case heartFill
  case heart
  case starFill
  case star
  case menu
  case setting
  case mapPin
  case sort
  case location
  case flame
  case ref
  case won
  case point
  case kakao
  case imagePlaceholder
  case countryKorea
  case countryJapan
  case countryAustralia
  case countryPhilippines
  case countryThailand
  case limitAge
  case limitHeight
  case limitMax
  case buy
  case keep
  case distance
  case message
  case sparkle
  case info
  
  var value: Image {
    let name = switch self {
    case .globe: "ic_globe"
    case .post: "ic_post"
    case .ticket: "ic_ticket"
    case .chat: "ic_chat"
    case .profile: "ic_profile"
    case .search: "ic_search"
    case .arrowRight: "ic_arrow_right"
    case .arrowLeft: "ic_arrow_left"
    case .bellNoti: "ic_bell_noti"
    case .bell: "ic_bell"
    case .heartFill: "ic_heart_fill"
    case .heart: "ic_heart"
    case .starFill: "ic_star_fill"
    case .star: "ic_star"
    case .menu: "ic_menu"
    case .setting: "ic_setting"
    case .mapPin: "ic_map_pin"
    case .sort: "ic_sort"
    case .location: "ic_location"
    case .flame: "ic_flame"
    case .ref: "ic_ref"
    case .won: "ic_won"
    case .point: "ic_point"
    case .kakao: "ic_kakao"
    case .imagePlaceholder: "ic_image_placeholder"
    case .countryKorea: "country_korea"
    case .countryJapan: "country_japan"
    case .countryAustralia: "country__australia"
    case .countryPhilippines: "country_philippines"
    case .countryThailand: "country_thailand"
    case .limitAge: "ic_limit_age"
    case .limitHeight: "ic_limit_height"
    case .limitMax: "ic_limit_max"
    case .buy: "ic_buy"
    case .keep: "ic_keep"
    case .distance: "ic_distance"
    case .message: "ic_message"
    case .sparkle: "ic_sparkle"
    case .info: "ic_info"
    }
    return Image(name)
  }
  
  var template: some View {
    value
      .renderingMode(.template)
      .resizable()
  }
}

// MARK: - 사용 예시
/*
 새로운 카테고리별 사용법:
 CVCImage.Tab.globe.value          // 탭 아이콘 (globe, post, ticket, chat, profile)
 CVCImage.Navigation.search.value  // 네비게이션 아이콘 (search, bell, bellNoti, arrowLeft, arrowRight, menu)
 CVCImage.Action.heart.value       // 액션 아이콘 (heart, heartFill, sort, location, mapPin, flame, ref, won)
 CVCImage.Brand.kakao.value        // 브랜드 로고 (kakao, imagePlaceholder)
 CVCImage.Country.korea.value      // 국가 플래그 (korea, japan, australia, philippines, thailand, taiwan, argentina)
 CVCImage.Limit.age.value          // 제한 아이콘 (age, height, max)
 
 템플릿 모드:
 CVCImage.Tab.globe.template
 CVCImage.Limit.age.template
 
 기존 방식도 계속 지원:
 CVCImage.globe.value
 CVCImage.limitAge.template
 */
