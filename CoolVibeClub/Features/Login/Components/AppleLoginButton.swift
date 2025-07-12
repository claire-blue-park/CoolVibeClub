//
//  AppleLoginButton.swift
//  CoolVibeClub
//
//  Created by Claire on 7/11/25.
//

import AuthenticationServices
import SwiftUI
import ComposableArchitecture

struct AppleLoginButton: View {
  @Dependency(\.appStore) var appStore
  
    var body: some View {
        ZStack {
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        print("애플 로그인 완료")
                        switch authResults.credential {
                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                            let fullName = appleIDCredential.fullName
                            let name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
                            
                            guard let identityTokenData = appleIDCredential.identityToken,
                                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                                return
                            }
                            
                            Task {
                                print("서버 ㄱㄱ")
                                if let deviceToken = UserDefaultsHelper.shared.getDeviceToken() {
                                    await fetchAppleLogin(idToken: identityToken, deviceToken: deviceToken, nick: name)
                                }
                            }
                        default:
                            break
                        }
                    case .failure(let error):
                        print("Apple Login Error: \(error.localizedDescription)")
                    }
                }
            )
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            // 커스텀 디자인
            Circle()
                .fill(Color.black)
                .frame(width: 60, height: 60)
                .allowsHitTesting(false) // 터치 이벤트 -> SignInWithAppleButton
            
            // Apple 로고
            Image(systemName: "applelogo")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .padding(.bottom, 2)
                .foregroundColor(.white)
                .allowsHitTesting(false)  // 터치 이벤트 -> SignInWithAppleButton
        }
    }
    
    private func fetchAppleLogin(idToken: String, deviceToken: String, nick: String) async {
        do {
            let response: AppleLoginResponse = try await NetworkManager.shared.fetch(
                from: LoginEndpoint(
                    requestType: .appleLogin(idToken: idToken, deviceToken: deviceToken, nick: nick)
                ), responseError: LoginResponseError.self
            )
          
          appStore.send(.setLoggedIn(true, accessToken: response.accessToken, refreshToken: response.refreshToken))
          
            print("\(response)")
        } catch let error as NetworkError {
            print("네트워크 에러: \(error)")
        } catch {
            print("?: \(error)")
        }
    }
}
