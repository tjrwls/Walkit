//
//  EmotionSlelectView.swift
//  WalkIt
//
//  Created by 조석진 on 12/28/25.
//
import SwiftUI

struct EmotionSlelectView: View {
    @Binding var emotion: String
    @Binding var value: Int
    @Binding var isEnableNext: Bool
    let emosionsBadge: [EmotionBadge]
    
    var body: some View {
        GeometryReader { geo in
            let badgeHeight = CGFloat(emosionsBadge.count) * 52 + CGFloat(20 * (emosionsBadge.count - 1))
            
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                HStack(alignment: .center, spacing: 0) {
                    EmotionSlider(emotion: $emotion, value: $value)
                        .padding(.trailing, 46)
                        .frame(height: badgeHeight)
                        .onChange(of: value) { _, newValue in
                            emotion = getEmotion(valeu: newValue)
                        }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(emosionsBadge) { emotionbadge in
                            HStack(spacing: 20) {
                                Image("\(emotionbadge.emotion)Circle")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(emotion == emotionbadge.emotion ? 1.1 : 1.0)
                                    .frame(width: 52)
                                
                                Text(getEmotionKOR(emotion: emotionbadge.emotion))
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal, getEmotionKOR(emotion: emotionbadge.emotion).count == 3 ? 5.5 : 0)
                                    .foregroundStyle(Color(hex: emotionbadge.textColor))
                                    .modifier(CapsuleBackground(backgroundColor: Color(hex: emotionbadge.backgroundColor)))
                                    .scaleEffect(emotion == emotionbadge.emotion ? 1.1 : 1.0)
                            }
                            .opacity((emotion == emotionbadge.emotion || emotion == "") ? 1.0 : 0.6)
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: emotion)
                            .onTapGesture {
                                value = getValue(emotion: emotionbadge.emotion)
                                emotion = emotionbadge.emotion
                                isEnableNext = true
                            }
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func getEmotionKOR(emotion: String) -> String {
        switch(emotion) {
        case "DELIGHTED": return "기쁘다"
        case "JOYFUL": return "즐겁다"
        case "HAPPY": return "행복하다"
        case "DEPRESSED": return "우울하다"
        case "TIRED": return "지친다"
        case "IRRITATED": return "짜증난다"
        default: return ""
        }
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
    
    func getValue(emotion: String) -> Int {
        switch emotion {
        case "DELIGHTED": return 5
        case "JOYFUL": return 4
        case "HAPPY": return 3
        case "DEPRESSED": return 2
        case "TIRED": return 1
        case "IRRITATED": return 0
        default: return 0
        }
    }
}
