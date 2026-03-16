//
//  OutlineActionButton.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//

import SwiftUI


struct FilledActionButton: View {
    let title: String
    @Binding var isEnable: Bool
    let isRightChevron: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isEnable ? Color(.white) : Color("CustomGray"))
                
                if(isRightChevron) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(isEnable ? Color(.white) : Color("CustomGray"))
                }   
            }
            .buttonStyle(.plain)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isEnable ? Color("CustomGreen2") : Color("CustomLightGray4"))
            )
        }
        
        .disabled(!isEnable)
    }
}

#Preview {
    FilledActionButton(title: "테스트", isEnable: .constant(true), isRightChevron: true) {}
}
