//
//  ActivityReservationView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import Alamofire
import Network
import CoreLocation
import AVFoundation

struct ActivityReservationView: View {
//  let title: String
  let availableDates: [ReservationDate]
  @State private var selectedDateIndex: Int = 0
  @State private var selectedTimeSlot: TimeSlot?
  let onReservationChanged: (ReservationDate, TimeSlot?) -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 타이틀
      Text("액티비티 예약설정")
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(CVCColor.grayScale45)
        .padding(.horizontal, 4)
      
      VStack(alignment: .leading, spacing: 20) {
        // 날짜 선택
        DateSelectorView(
          dates: availableDates,
          selectedIndex: $selectedDateIndex
        )
        
        // 시간 선택
        if !availableDates.isEmpty {
          TimeSlotSelectorView(
            timeSlots: availableDates[selectedDateIndex].timeSlots,
            selectedTimeSlot: $selectedTimeSlot
          )
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 20)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(CVCColor.grayScale15)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(CVCColor.grayScale30, lineWidth: 1)
          )
      )
//      .padding(.horizontal, 16)
    }
    .onChange(of: selectedDateIndex) { newIndex in
      selectedTimeSlot = nil
      if !availableDates.isEmpty {
        onReservationChanged(availableDates[newIndex], nil)
      }
    }
    .onChange(of: selectedTimeSlot) { newTimeSlot in
      if !availableDates.isEmpty {
        onReservationChanged(availableDates[selectedDateIndex], newTimeSlot)
      }
    }
  }
}

// MARK: - Data Models
struct ReservationDate {
  let id: String
  let month: Int
  let day: Int
  let dayOfWeek: String
  let timeSlots: [TimeSlot]
  let isAvailable: Bool
  
  var displayText: String {
    "\(month)월 \(day)일"
  }
}

struct TimeSlot: Equatable {
  let id: String
  let hour: Int
  let minute: Int
  let isAvailable: Bool
  let isSelected: Bool
  
  var displayTime: String {
    String(format: "%d:%02d", hour, minute)
  }
}

// MARK: - DateSelectorView
private struct DateSelectorView: View {
  let dates: [ReservationDate]
  @Binding var selectedIndex: Int
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
          SelectableButton(
            text: date.displayText,
            isAvailable: date.isAvailable,
            isSelected: selectedIndex == index,
            cornerRadius: 20,
            onTap: {
              if date.isAvailable {
                selectedIndex = index
              }
            }
          )
        }
      }
    }
  }
}

// MARK: - TimeSlotSelectorView
private struct TimeSlotSelectorView: View {
  let timeSlots: [TimeSlot]
  @Binding var selectedTimeSlot: TimeSlot?
  
  private var morningSlots: [TimeSlot] {
    timeSlots.filter { $0.hour < 12 }
  }
  
  private var afternoonSlots: [TimeSlot] {
    timeSlots.filter { $0.hour >= 12 }
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 오전 시간대
      if !morningSlots.isEmpty {
        TimeSlotSection(
          title: "오전",
          selectedTimeSlot: $selectedTimeSlot,
          timeSlots: morningSlots
        )
      }
      
      // 오후 시간대
      if !afternoonSlots.isEmpty {
        TimeSlotSection(
          title: "오후",
          selectedTimeSlot: $selectedTimeSlot,
          timeSlots: afternoonSlots
        )
      }
    }
  }
}

// MARK: - TimeSlotSection
private struct TimeSlotSection: View {
  let title: String
  @Binding var selectedTimeSlot: TimeSlot?
  let timeSlots: [TimeSlot]
  
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(CVCColor.grayScale45)
      
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(timeSlots, id: \.id) { timeSlot in
          TimeSlotButton(
            timeSlot: timeSlot,
            isSelected: selectedTimeSlot?.id == timeSlot.id,
            onTap: {
              if timeSlot.isAvailable {
                selectedTimeSlot = timeSlot
              }
            }
          )
        }
      }
    }
  }
}

// MARK: - SelectableButton
private struct SelectableButton: View {
  let text: String
  let isAvailable: Bool
  let isSelected: Bool
  let cornerRadius: CGFloat
  let onTap: () -> Void
  
  var backgroundColor: Color {
    if !isAvailable {
      return CVCColor.grayScale15
    } else if isSelected {
      return CVCColor.primaryBright
    } else {
      return CVCColor.grayScale0
    }
  }
  
  var textColor: Color {
    if !isAvailable {
      return CVCColor.grayScale45
    } else if isSelected {
      return CVCColor.primary
    } else {
      return CVCColor.grayScale75
    }
  }
  
  var strokeColor: Color {
    if !isAvailable {
      return CVCColor.grayScale30
    } else if isSelected {
      return CVCColor.primary
    } else {
      return CVCColor.grayScale45
    }
  }
  
  var body: some View {
    Button(action: onTap) {
      Text(text)
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(textColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, cornerRadius > 15 ? 8 : 10)
        .padding(.horizontal, cornerRadius > 15 ? 16 : 0)
        .background(
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .overlay(
              RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(strokeColor, lineWidth: 1)
            )
        )
    }
    .padding(1)
    .disabled(!isAvailable)
  }
}

// MARK: - TimeSlotButton
private struct TimeSlotButton: View {
  let timeSlot: TimeSlot
  let isSelected: Bool
  let onTap: () -> Void
  
  var body: some View {
    SelectableButton(
      text: timeSlot.displayTime,
      isAvailable: timeSlot.isAvailable,
      isSelected: isSelected,
      cornerRadius: 8,
      onTap: onTap
    )
  }
}

// MARK: - Preview
//#Preview {
//  VStack(spacing: 24) {
//    ActivityReservationView(
////      title: "액티비티 예약설정",
//      availableDates: [
//        ReservationDate(
//          id: "1",
//          month: 5,
//          day: 4,
//          dayOfWeek: "토",
//          isAvailable: true,
//          timeSlots: [
//            TimeSlot(id: "1", hour: 8, minute: 0, isAvailable: true, isSelected: false),
//            TimeSlot(id: "2", hour: 8, minute: 30, isAvailable: true, isSelected: false),
//            TimeSlot(id: "3", hour: 9, minute: 0, isAvailable: true, isSelected: false),
//            TimeSlot(id: "4", hour: 9, minute: 30, isAvailable: false, isSelected: false),
//            TimeSlot(id: "5", hour: 10, minute: 0, isAvailable: true, isSelected: false),
//            TimeSlot(id: "6", hour: 10, minute: 30, isAvailable: true, isSelected: false),
//            TimeSlot(id: "7", hour: 11, minute: 0, isAvailable: false, isSelected: false),
//            TimeSlot(id: "8", hour: 11, minute: 30, isAvailable: false, isSelected: false),
//            TimeSlot(id: "9", hour: 13, minute: 0, isAvailable: true, isSelected: false),
//            TimeSlot(id: "10", hour: 13, minute: 30, isAvailable: true, isSelected: false),
//            TimeSlot(id: "11", hour: 14, minute: 0, isAvailable: false, isSelected: true),
//            TimeSlot(id: "12", hour: 14, minute: 30, isAvailable: true, isSelected: false),
//            TimeSlot(id: "13", hour: 15, minute: 0, isAvailable: true, isSelected: false),
//            TimeSlot(id: "14", hour: 15, minute: 30, isAvailable: false, isSelected: false),
//            TimeSlot(id: "15", hour: 16, minute: 0, isAvailable: false, isSelected: false),
//            TimeSlot(id: "16", hour: 16, minute: 30, isAvailable: false, isSelected: false)
//          ]
//        ),
//        ReservationDate(
//          id: "2",
//          month: 5,
//          day: 5,
//          dayOfWeek: "일",
//          isAvailable: true,
//          timeSlots: [
//            TimeSlot(id: "17", hour: 9, minute: 0, isAvailable: true, isSelected: false),
//            TimeSlot(id: "18", hour: 10, minute: 0, isAvailable: true, isSelected: false),
//            TimeSlot(id: "19", hour: 14, minute: 0, isAvailable: true, isSelected: false)
//          ]
//        ),
//        ReservationDate(
//          id: "3",
//          month: 5,
//          day: 6,
//          dayOfWeek: "월",
//          isAvailable: false,
//          timeSlots: [
//            TimeSlot(id: "20", hour: 8, minute: 0, isAvailable: true, isSelected: false),
//            TimeSlot(id: "21", hour: 9, minute: 0, isAvailable: false, isSelected: false)
//          ]
//        )
//      ],
//      onReservationChanged: { date, timeSlot in
//        print("Selected: \(date.displayText), \(timeSlot?.displayTime ?? "No time")")
//      }
//    )
//  }
//  .padding()
//  .background(Color.white)
//}
