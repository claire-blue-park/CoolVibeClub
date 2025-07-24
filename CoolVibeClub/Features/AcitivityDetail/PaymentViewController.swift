//
//  PaymentViewController.swift
//  CoolVibeClub
//
//  Created by Claire on 8/7/25.
//

import SwiftUI
import UIKit
import WebKit
import iamport_ios

struct IamportPaymentView: UIViewControllerRepresentable {
  let orderResponse: OrderResponse
  let activityTitle: String
  let onPaymentResult: (IamportResponse?) -> Void
  
  func makeUIViewController(context: Context) -> UIViewController {
    let paymentVC = IamportPaymentViewController()
    paymentVC.configure(
      orderResponse: orderResponse,
      activityTitle: activityTitle,
      onPaymentResult: onPaymentResult
    )
    return paymentVC
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

final class IamportPaymentViewController: UIViewController {
  private var orderResponse: OrderResponse?
  private var activityTitle: String = ""
  private var onPaymentResult: ((IamportResponse?) -> Void)?
  private var hasStartedPayment = false
  
  func configure(
    orderResponse: OrderResponse,
    activityTitle: String,
    onPaymentResult: @escaping (IamportResponse?) -> Void
  ) {
    self.orderResponse = orderResponse
    self.activityTitle = activityTitle
    self.onPaymentResult = onPaymentResult
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // 중복 실행 방지
    guard !hasStartedPayment else { return }
    hasStartedPayment = true
    
    requestIamportPayment()
  }

  // 아임포트 SDK 결제 요청
  func requestIamportPayment() {
    guard let orderResponse = orderResponse else {
      print("❌ 주문 정보가 없습니다")
      onPaymentResult?(nil)
      return
    }
    
    let userCode = "imp14511373" // 실제 가맹점 식별코드
    let payment = createPaymentData(orderResponse: orderResponse)
    
    print("🚀 Iamport 결제 시작")
    print("  👤 userCode: \(userCode)")
    print("  💳 payment: \(payment.merchant_uid)")
    print("  💰 price: \(orderResponse.totalPrice)원")
    
    Iamport.shared.payment(
      viewController: self,
      userCode: userCode, 
      payment: payment
    ) { [weak self] response in
      print("🔥 =========================")
      print("🔥 결제 콜백 함수 호출됨!")
      print("🔥 응답 데이터: \(response?.description ?? "nil")")
      
      if let response = response {
        print("🔥 결제 결과:")
        print("   - success: \(response.success ?? false)")
        print("   - imp_uid: \(response.imp_uid ?? "없음")")
        print("   - merchant_uid: \(response.merchant_uid ?? "없음")")
        print("   - error_msg: \(response.error_msg ?? "없음")")
        print("   - error_code: \(response.error_code ?? "없음")")
      } else {
        print("🔥 응답이 nil입니다!")
      }
      print("🔥 =========================")
      
      DispatchQueue.main.async {
        print("🔥 MainActor에서 콜백 실행 중...")
        self?.onPaymentResult?(response)
        self?.dismiss(animated: true)
        print("🔥 dismiss 완료")
      }
    }
  }

  // 아임포트 결제 데이터 생성
  func createPaymentData(orderResponse: OrderResponse) -> IamportPayment {
    return IamportPayment(
      pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
      merchant_uid: orderResponse.orderCode,
      amount: "\(orderResponse.totalPrice)"
    ).then {
      $0.pay_method = PayMethod.card.rawValue
      $0.name = activityTitle
      $0.buyer_name = "박채현"
      $0.app_scheme = "cvc"
    }
  }
}
