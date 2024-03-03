//
//  ScheduleCard.swift
//  Grace
//
//  Created by Эвелина Пенькова on 16.02.2024.
//

import SwiftUI

struct ScheduleCard: View {
    var body: some View {
        ZStack{
            Rectangle()
                .frame(width: 77, height: 77)
                .colorMultiply(.white)
                .blur(radius: 57.5)
            
            Rectangle()
                .frame(width: 147, height: 118)
                .colorMultiply(.black)
                .cornerRadius(22)
                
            
            VStack(alignment: .leading){
                    Text("10:00")
                        .font(.system(size: 30, weight: .bold))
                        .colorMultiply(Color("ColorForTime"))
                        
                    Text("Растяжка")
                        .font(.system(size: 18, weight: .bold))
                    Text("9/10")
                        .font(.system(size: 11))
                        .colorMultiply(Color(.systemGray))
            }.padding(.trailing,30)
                .padding(.bottom, 20)
        }.preferredColorScheme(.dark)
    }
}

#Preview {
    ScheduleCard()
}
