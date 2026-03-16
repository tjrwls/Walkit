//
//  Circle.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//

import SwiftUI

struct CircleView: View {
    var body: some View {
        Circle()
            .foregroundColor(Color(.systemGray4))
            .overlay {
                Circle().stroke(Color(.systemGray3), lineWidth: 1)
            }
    }
}

#Preview {
    CircleView()
}
