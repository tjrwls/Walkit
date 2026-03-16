//
//  GradientLinearSpinner.swift
//  WalkIt
//
//  Created by 조석진 on 12/17/25.
//

import SwiftUI

struct GradientLinearSpinner: View {
    let progress: CGFloat   // 0.0 ~ 1.0
    let height: CGFloat
    let firstColor: Color
    let lastColor: Color
    let backgroundColor: Color
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {

                // 배경
                Capsule()
                    .fill(backgroundColor)

                // 진행 바
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [firstColor, lastColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.4), value: progress)
    }
}

#Preview {
    GradientLinearSpinner(progress: 0.8, height: 15, firstColor: Color("CustomGreen2"), lastColor: Color("CustomGreen3"), backgroundColor: Color(.white))
}
