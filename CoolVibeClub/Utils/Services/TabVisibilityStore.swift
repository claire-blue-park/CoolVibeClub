import SwiftUI

class TabVisibilityStore: ObservableObject {
    @Published var isVisible: Bool = true {
        didSet {
            // 값이 변경될 때만 애니메이션 실행
            if oldValue != isVisible {
                withAnimation(.easeInOut(duration: 0.3)) {
                    // 애니메이션 트리거
                }
            }
        }
    }
    
    func setVisibility(_ visible: Bool) {
        // 현재 값과 같으면 아무 변화 없음
        if isVisible != visible {
            isVisible = visible
        }
    }
}