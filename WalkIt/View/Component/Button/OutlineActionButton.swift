//  checkBoxTextView.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//
import SwiftUI

struct OutlineActionButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .figmaText(fontSize: 16, weight: .semibold)
                .foregroundStyle(Color("CustomGreen2"))
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("CustomGreen2"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(.white))
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OutlineActionButton(title: "테스트", action: {})
}
