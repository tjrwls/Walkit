//
//  RoundedCorners.swift
//  WalkIt
//
//  Created by 조석진 on 1/2/26.
//

import SwiftUI


struct RoundedCorners: Shape {
    var radius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radii = RectangleCornerRadii(
            topLeading: 0,
            bottomLeading: radius,
            bottomTrailing: radius,
            topTrailing: radius
        )
        
        path.addRoundedRect(in: rect, cornerRadii: radii)
        
        return path
    }
}
