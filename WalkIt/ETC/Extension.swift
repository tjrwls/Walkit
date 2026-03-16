//
//  Extension.swift
//  WalkIt
//
//  Created by 조석진 on 12/17/25.
//

import SwiftUI

extension Color {
    init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )
        default:
            (r, g, b) = (1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: alpha
        )
    }
}

extension String {
    func loadImage() async -> UIImage? {
        guard let url = URL(string: self) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            debugPrint("loadImage \(error)")
            return UIImage(named: "DefaultImage")
        }
    }
}

extension UIView {
    func snapshot() -> UIImage? {
        debugPrint("snapshot 실행")
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        debugPrint("renderer: \(renderer)")

        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}


extension View {
    func toast<ToastContent: View>(
        isPresented: Binding<Bool>,
        duration: TimeInterval = 2.0,
        @ViewBuilder content: @escaping () -> ToastContent
    ) -> some View {
        modifier(
            ToastModifier(
                isPresented: isPresented,
                duration: duration,
                toastContent: content
            )
        )
    }
}


extension Text {

    func figmaText(
        fontSize: CGFloat,
        weight: Font.Weight,
        lineHeightPercent: CGFloat = 1.5,
        letterSpacingPercent: CGFloat = -0.01
    ) -> some View {

        let lineHeight = fontSize * lineHeightPercent
        let lineSpacing = lineHeight - fontSize
        let tracking = fontSize * letterSpacingPercent

        return self
            .font(.system(size: fontSize, weight: weight))
            .tracking(tracking)
            .lineSpacing(lineSpacing)
    }
}
