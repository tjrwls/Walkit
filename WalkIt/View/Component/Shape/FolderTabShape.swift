//
//  FolderTabShape.swift
//  WalkIt
//
//  Created by 조석진 on 1/2/26.
//

import SwiftUI

import SwiftUI

struct FolderTabShape: Shape {
    var cornerRadius: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radii = RectangleCornerRadii(
            topLeading: 4,
            bottomLeading: 0,
            bottomTrailing: 0,
            topTrailing: cornerRadius
        )
    
        path.addRoundedRect(in: rect, cornerRadii: radii)
        
        return path
    }
}

