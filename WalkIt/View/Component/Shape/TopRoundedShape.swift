//
//  TopRoundedShape.swift
//  WalkIt
//
//  Created by 조석진 on 1/14/26.
//
import SwiftUI


struct TopRoundedShape: Shape {
    var radius: CGFloat = 24

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
