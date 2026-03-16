//
//  CapsuleTag.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//
import SwiftUI

struct WeeklyEmotionView: View {
    let text: String
    var body: some View {
        ZStack {
            Image("EmotionCard")
                .resizable()
                .scaledToFill()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("이번주 나의 주요 감정은?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("즐거움")
                            .font(.title2).bold()
                        Text("즐거운 감정을 7일동안 4회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    WeeklyEmotionView(text: "즐거움")
}
