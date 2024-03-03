//
//  TrainView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 27.02.2024.
//

import SwiftUI


struct TrainView: View {
    let training: Training
    let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    var body: some View {
        ZStack{
            Image("backSch")
                .resizable()
                .frame(width: 393, height: 892)
                .padding(.top, 38)
            
            Rectangle()
                .colorMultiply(.black)
                .frame(width: 393, height: 892)
                .opacity(0.5)
                .clipShape( // 1
                    RoundedCornerShape( // 2
                        radius: 20,
                        corners: [.bottomLeft, .bottomRight, .topRight]
                                      )
                )
            
            
            VStack{
                HStack{
                    ZStack{
                        Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 202.63, height: 84)
                        .background(Color(red: 1, green: 0, blue: 0.52))
                        .cornerRadius(22)
                        .blur(radius: 57.5)
                        .rotationEffect(Angle(degrees: 180))
                        Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 202.63, height: 84)
                        .background(Color(red: 1, green: 0, blue: 0.52))
                        .cornerRadius(22)
                        .blur(radius: 57.5)
                        .rotationEffect(Angle(degrees: 180))
                        Rectangle()
                            .frame(width: 202.63, height: 90)
                            .foregroundColor(.black)
                            .clipShape( // 1
                                RoundedCornerShape( // 2
                                    radius: 63,
                                    corners: [.bottomLeft, .topLeft]
                                                  )
                            )
                        
                        Text(timeFormatter.string(from: training.time))
                        
                    }
                }
            }
        }.preferredColorScheme(.dark)
    }
}

struct TrainView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleTraining = Training(id: "1", name: "Example Training", date: Date(), time: Date(), amountOfPeople: 10, description: "Тренировка по растяжке включает в себя общую растяжку всех основных групп мышц, таких как ноги, спина, плечи и шея. Упражнения выполняются плавно и удерживаются в течение 15-30 секунд для каждой группы мышц. Важно сосредоточиться на правильном дыхании и расслаблении во время растяжки.")
        return TrainView(training: exampleTraining)
    }
}
