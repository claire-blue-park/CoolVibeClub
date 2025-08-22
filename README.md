
⏺ CoolVibeClub iOS App

  📱 프로젝트 개요

  Cool Vibe Club은 여러 나라의 액티비티를 탐색하고 예약할 수 있는 여행 플랫폼입니다. 
  실시간 채팅, 결제 시스템, 위치 기반 커뮤니티를 통해 사용자에게 다양한 편의를 제공합니다.

  🎯 주요 기능

  - 🔐 OAuth 인증: 카카오/애플 소셜 로그인
  - 🌍 위치 기반 액티비티 탐색: GPS 기반 주변 액티비티 검색
  - 💬 실시간 채팅: Socket.IO를 활용한 양방향 통신
  - 📸 멀티미디어 공유: 이미지/비디오 업로드 및 스트리밍
  - 🌐 웹뷰 브릿지: 네이티브-웹 하이브리드 기능
  
  ---
  🔧 개발 환경

  - Xcode: 16.0+
  - iOS: 16.0+
  - Swift: 5.0+
  
  ---
  🏗️ 아키텍처

  전체 구조

  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
  │   Presentation  │    │    Business     │    │      Data       │
  │    (SwiftUI)    │◄──►│   (TCA Store)   │◄──►│   (Network)     │
  └─────────────────┘    └─────────────────┘    └─────────────────┘

  핵심 패턴

  - **TCA-Style Architecture**: 사용자 정의 MVI 패턴 구현
  - **단방향 데이터 플로우**: Action → State → View
  - **Repository Pattern**: 데이터 소스 추상화
  - **Observer Pattern**: 이벤트 기반 통신

  🎯 커스텀 MVI 아키텍처 패턴

  TCA 스타일의 사용자 정의 **MVI 아키텍처**를 기반으로 구성되었습니다.

  **State**: 애플리케이션의 모든 상태를 나타냅니다.
  - 불변 데이터 구조
  - UI 상태, 비즈니스 데이터, 로딩 상태 등을 포함

  **View**: SwiftUI 뷰가 상태를 선언적으로 렌더링합니다.
  - 상태에 따른 반응형 UI
  - 사용자 액션을 Store로 전달

  **Action**: 사용자 의도와 시스템 이벤트를 표현합니다.
  - 사용자 인터랙션 (버튼 클릭, 텍스트 입력)
  - 외부 이벤트 (네트워크 응답, 타이머 등)

  **Store**: ObservableObject로 구현된 상태 관리자
  - Action을 받아 State를 업데이트
  - 비즈니스 로직 처리
  - 비동기 작업 관리

  ---
  🛠️ 기술 스택

  UI Framework

  - SwiftUI: 선언적 UI 프레임워크

  Networking

  - Alamofire: HTTP 클라이언트
  - Socket.IO: 실시간 양방향 통신
  - Kingfisher: 이미지 캐싱 및 로딩

  Storage & Security

  - Keychain: 토큰 보안 저장
  - UserDefaults: 설정 데이터 저장
  - Core Location: 위치 서비스

  Third-party

  - KakaoSDK: 카카오 로그인
  - Lottie: 애니메이션

  ---
  📂 프로젝트 구조

  CoolVibeClub/
  ├── 📱 App/                         # 앱 진입점
  ├── 🎨 DesignSystems/              # 디자인 시스템
  │   ├── Components/                # 재사용 컴포넌트
  │   │   ├── Button/               # 버튼 컴포넌트
  │   │   ├── Input/                # 입력 컴포넌트
  │   │   ├── Media/                # 미디어 컴포넌트
  │   │   └── Web/                  # 웹뷰 컴포넌트
  │   ├── Extensions/               # UI 확장
  │   └── Resources/                # 색상, 폰트, 이미지
  ├── 🏛️ Core/                       # 핵심 비즈니스 로직
  │   ├── Client/                   # API 클라이언트
  │   ├── DTO/                      # 데이터 전송 객체
  │   ├── Domain/                   # 도메인 모델
  │   └── Endpoint/                 # API 엔드포인트
  ├── 🎭 Features/                   # 기능별 모듈
  │   ├── Activity/                 # 액티비티 관련
  │   ├── Auth/                     # 인증 관련
  │   ├── Chat/                     # 채팅 관련
  │   ├── NearBy/                   # 위치 기반 커뮤니티
  │   └── Tab/                      # 탭 네비게이션
  ├── 🧰 Services/                   # 서비스 레이어
  │   ├── Network/                  # 네트워크 서비스
  │   ├── Location/                 # 위치 서비스
  │   └── Socket/                   # 소켓 서비스
  ├── 📊 Models/                     # 데이터 모델
  └── 🔧 Utils/                      # 유틸리티

  
  ---
  📊 성능 최적화

  이미지 처리

  - Kingfisher 캐싱: 메모리 100MB, 디스크 500MB
  - JPEG 압축: 0.8 품질로 업로드 최적화
  - 지연 로딩: 필요시에만 이미지 로드

  네트워크

  - 토큰 자동 갱신: TokenRefreshInterceptor
  - 요청 중복 방지: 로딩 상태 기반 가드
  - 타임아웃 설정: 60초 요청/응답 타임아웃

  메모리 관리

  - 약한 참조: 순환 참조 방지
  - 백그라운드 처리: 이미지 로딩 및 네트워크 요청
  - 상태 정리: 화면 이동 시 리소스 해제

  ---
  📈 추후 개선 사항

  기술적 개선

  - GraphQL: REST API에서 GraphQL로 마이그레이션
  - SwiftData: 로컬 데이터 저장이 필요한 경우 SwiftData 도입
  - Async/Await: Combine에서 완전한 async/await 전환

  기능 개선

  - 오프라인 모드: 네트워크 끊김 시 캐시 데이터 활용
  - 다국어 지원: Localizable.strings 적용
  - 다크 모드: 완전한 다크 테마 지원

  성능 개선

  - 메모리 최적화: 대용량 미디어 처리 개선
  - 배터리 최적화: 백그라운드 작업 최소화
