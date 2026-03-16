//
//  EmotionSlider.swift
//  WalkIt
//
//  Created by 조석진 on 12/28/25.
//

import SwiftUI

struct EmotionSlider: View {
    @Binding var emotion: String
    @Binding var value: Int
    let maxValue: Int = 6   // 0 ~ 5
    private let indicatorHeight: CGFloat = 70
    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let usableHeight = height - (indicatorHeight / 2)
            let step = usableHeight / CGFloat(maxValue - 1)
            let offsetY = usableHeight - CGFloat(value) * step
            
        ZStack(alignment: .top) {
                Capsule()
                    .fill(Color("CustomLightGray5"))
                    .frame(width: 17)
                    .padding(.horizontal, 20)
                
                Image("EmotionIndicator")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: indicatorHeight)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                    .offset(y: (emotion.isEmpty ? offsetY + (step / 2) : offsetY - (indicatorHeight / 4)))
                    .gesture(
                        DragGesture()
                            .onChanged { g in
                                if emotion.isEmpty { emotion = getEmotion(valeu: value) }
                                let clampedY = min(max(g.location.y - (indicatorHeight / 2), 0), usableHeight)
                                
                                let progress = 1 - (clampedY / usableHeight)
                                let newValue = Int((progress * CGFloat(maxValue - 1)).rounded())
                                
                                if newValue != value { value = newValue }
                            }
                    )
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: value)
            }
        }
        .frame(width: 35)
        .padding(.vertical, 5)
    }
    
    func getEmotion(valeu: Int) -> String {
        switch(valeu) {
        case 5: return "DELIGHTED"
        case 4: return "JOYFUL"
        case 3: return "HAPPY"
        case 2: return "DEPRESSED"
        case 1: return "TIRED"
        case 0: return "IRRITATED"
        default: return ""
        }
    }
}



