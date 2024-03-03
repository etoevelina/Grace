//
//  RingView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 14.02.2024.
//

import SwiftUI

struct Ring {
    let id: Int
    let wh: CGFloat
    let target: CGFloat
    let done: CGFloat
    let progress: CGFloat
    let c1: String
    let c2: String

}

struct RingView: View {
    
    @State var ring: Ring
    @Binding var show: Bool
    
    var body: some View {
       //let progress = 1 - (percent/100)
        let progress = 1 - (ring.done/ring.target)
        ZStack {
            Circle()
                .stroke(Color(ring.c1).opacity(0.3), lineWidth: 20)
                .rotationEffect(Angle(degrees: 180))
                .rotation3DEffect( Angle(degrees: 180), axis: (x: 1, y: 1, z: 0))
            .frame(width: ring.wh, height: ring.wh)
            
            Circle()
                .trim(from: show ?  progress : 1, to: 1)
                .stroke(LinearGradient(gradient: Gradient(colors:  [Color(ring.c1), Color(ring.c2)]), startPoint: UnitPoint(x: 0.5, y: 0.07), endPoint: UnitPoint(x: 0.4, y: 1)),  style: StrokeStyle(lineWidth: 20,lineCap: .round))
           
                .rotationEffect(Angle(degrees: 180))
                .rotation3DEffect( Angle(degrees: 180), axis: (x: 1, y: 1, z: 0))
                .frame(width: ring.wh, height: ring.wh)
        }.preferredColorScheme(.dark)
    }
}

#Preview {
    RingView(ring: Ring(id: 0, wh: 176, target: 10000, done: 8000, progress: 5, c1: "ColorCalories", c2: "ColorDarkBlue"), show: .constant(true))
}
