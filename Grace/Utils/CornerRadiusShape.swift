//
//  CornerRadiusShape.swift
//  Grace
//
//  Created by Эвелина Пенькова on 23.05.2024.
//

import Foundation
import SwiftUI

struct RoundedCornerShape: Shape { // 1
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path { // 2
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
