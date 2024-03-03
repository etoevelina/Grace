//
//  ActivityCard.swift
//  Grace
//
//  Created by Эвелина Пенькова on 13.02.2024.
//

import SwiftUI



struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let amount: String
    let background: String
    let fieldForText: String
    let ramka: String
    let shade: String
    
}

struct RoundedCornerShape1: Shape { // 1
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

struct ActivityCard: View {
    
    @State var activity: Activity
    
    
    
    var body: some View {
        ZStack{
            
            //Color(.black)
            Image(activity.ramka)
                .resizable()
                .frame(width: 168, height: 119)
            
            VStack (spacing: 7){
                HStack(alignment: .top){
                    VStack (alignment: .leading, spacing: 1){
                        Group(){
                            Text (activity.title)
                                .font(.system(size: 15, weight: .bold))
                            Text(activity.subtitle)
                                .font(.system(size: 12))
                                //.foregroundColor(.gray)
                        }.foregroundColor(.white)
                        
                    }.padding(.top, 33)
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundColor(.orange)
                        .padding(.top, 33)
                        .padding(.trailing, 1)
                    
                }
                
                
                Text(activity.amount)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .shadow(color: Color(activity.shade).opacity(0.25), radius: 2, x: 3, y: 2)
                    .frame(width: 122, height: 34)
                    .background(Color(activity.fieldForText))
                    .clipShape( // 1
                        RoundedCornerShape( // 2
                            radius: 30,
                            corners: [ .bottomRight, .topRight]
                        )
                    )
                    .clipShape( // 1
                        RoundedCornerShape( // 2
                            radius: 30,
                            corners: [ .bottomLeft]
                        )
                    )
            
                    .padding(.bottom, 22)
                    
            }
        
            .padding()
            
            
        }
        .frame(width: 168, height: 110)
    }
}

#Preview {
    ActivityCard(activity: Activity(id: 0, title: "Шаги сегодня", subtitle: "Цель: 10 000", image: "figure.walk", amount: "6 543", background: "", fieldForText: "ColorCalories", ramka: "BlueRam", shade: "ColorShadeSteps"))
}
