//
//  DateHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 8/13/25.
//

import Foundation

struct DateHelper {
  static func formatToKorean(from isoString: String) -> String {
    print("🕐 DateHelper 입력 문자열: \(isoString)")
    
    let date = parseDate(from: isoString)
    guard let date = date else {
      print("❌ DateHelper 파싱 실패, 원본 반환: \(isoString)")
      return isoString
    }
    
    print("🕐 DateHelper 파싱된 Date: \(date)")
    
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "yyyy년 M월 d일 a h시 m분"
    
    let result = formatter.string(from: date)
    print("🕐 DateHelper 최종 결과: \(result)")
    return result
  }
  
  private static func parseDate(from dateString: String) -> Date? {
    let formatters = [
      // ISO8601 형식들
      createFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"),
      createFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ"),
      createFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
      createFormatter(format: "yyyy-MM-dd'T'HH:mm:ss'Z'"),
      // 기본 ISO8601
      createFormatter(format: nil) // ISO8601DateFormatter
    ]
    
    for formatter in formatters {
      if let formatter = formatter as? DateFormatter,
         let date = formatter.date(from: dateString) {
        return date
      } else if let formatter = formatter as? ISO8601DateFormatter,
                let date = formatter.date(from: dateString) {
        return date
      }
    }
    
    return nil
  }
  
  private static func createFormatter(format: String?) -> Any {
    if let format = format {
      let formatter = DateFormatter()
      formatter.dateFormat = format
      formatter.timeZone = TimeZone(abbreviation: "UTC")
      return formatter
    } else {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      return formatter
    }
  }
  
  static func formatRelative(from isoString: String) -> String {
    let date = parseDate(from: isoString)
    guard let date = date else {
      return isoString
    }
    
    let now = Date()
    let timeInterval = now.timeIntervalSince(date)
    
    if timeInterval < 60 {
      return "방금 전"
    } else if timeInterval < 3600 {
      let minutes = Int(timeInterval / 60)
      return "\(minutes)분 전"
    } else if timeInterval < 86400 {
      let hours = Int(timeInterval / 3600)
      return "\(hours)시간 전"
    } else if timeInterval < 604800 { // 7일
      let days = Int(timeInterval / 86400)
      return "\(days)일 전"
    } else {
      // 7일 이상이면 전체 날짜 표시
      return formatToKorean(from: isoString)
    }
  }
}