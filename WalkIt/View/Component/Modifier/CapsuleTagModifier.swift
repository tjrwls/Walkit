//
//  CapsuleTag.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//
import SwiftUI

struct CapsuleBackground: ViewModifier {
    let backgroundColor: Color
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}

extension View {
    func capsuleTagStyle(backgroundColor: Color) -> some View {
        self.modifier(CapsuleBackground(backgroundColor: backgroundColor))
    }
    
    func snapshotVStack1024() -> UIImage {
        let controller = UIHostingController(rootView: self.fixedSize())
        let view = controller.view!
        view.backgroundColor = .clear
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let targetSize = view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: targetSize)
        
        let scale = 1024 / targetSize.width
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
    
    
    func snapshot() -> UIImage? {
        // 1. ImageRenderer 생성
        // fixedSize()를 추가하여 뷰가 잘리지 않고 원래 크기대로 렌더링되도록 함
        let renderer = ImageRenderer(content: self.fixedSize())
        
        // 2. 물리적 스크린 배율 적용 (선명도 결정)
        renderer.scale = UIScreen.main.scale
        
        return renderer.uiImage
    }
}


// 사용 예시 프리뷰
#Preview {
    VStack(spacing: 16) {
        Text("캡션태그")
            .modifier(CapsuleBackground(backgroundColor: .gray))
        Text("타이틀 태그")
            .modifier(CapsuleBackground(backgroundColor: .gray))
    }
    .padding()
}
