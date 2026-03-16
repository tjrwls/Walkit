//
//  TabBarButton.swift
//  WalkIt
//
//  Created by 조석진 on 1/2/26.
//

import SwiftUI

struct TabBarButton: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var imageName: String {
        if(isSelected) {
            iconName + "Enable"
        } else {
            iconName + "disable"
        }
    }
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
                
                Text(title)
                    .figmaText(fontSize: 10, weight: .regular, lineHeightPercent: 130)
                    .foregroundColor(isSelected ? Color("CustomGreen2") : Color("CustomLightGray5"))
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color("CustomMint") : Color(.white))
        }
        .padding(.bottom, 1)
    }
}
