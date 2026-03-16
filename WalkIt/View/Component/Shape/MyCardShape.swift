//
//  MyCardShape.swift
//  WalkIt
//
//  Created by 조석진 on 1/5/26.
//

import SwiftUI

struct MyCardShape: Shape {
    let radius: CGFloat = 28

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radii = RectangleCornerRadii(
            topLeading: 12,
            bottomLeading: 0,
            bottomTrailing: 99,
            topTrailing: 0
        )
        
        path.addRoundedRect(in: rect, cornerRadii: radii)
        
        return path
    }
}
