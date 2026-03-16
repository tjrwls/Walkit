//
//  checkBoxTextView.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//
import SwiftUI

struct CheckBoxTextButton: View {
    @Binding var ischeck: Bool
    let text: String
    var body: some View {
        HStack {
            ZStack(alignment: .center, content: {
                Rectangle()
                    .stroke(lineWidth: 1)
                    .frame(width: 20, height: 20)
                if(ischeck) {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.black)
                        .font(.system(size: 12.5))
                        .frame(width: 20, height: 20)
                }

            })
            Text(text)
        }
        .onTapGesture {
            ischeck.toggle()
        }
    }
}


#Preview {
    CheckBoxTextButton(ischeck: .constant(true), text: "체크박스 텍스트")
}
