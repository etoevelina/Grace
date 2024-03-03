//
//  TrainerViewCarouselView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 27.03.
import SwiftUI
import SDWebImageSwiftUI

struct TrainerViewCarouselView: View {
    var body: some View {
        ZStack {
            Image("backSch")
                .resizable()
                .frame(width: 393, height: 892)
                
            VStack{
                GeometryReader { reader in
                    CarouselView(size: reader.size)
                }.background(Color(white: 0.15, opacity: 0.7).ignoresSafeArea())
            }
        }
        
    }
}

struct CarouselView: View {
    let size: CGSize
    let damping: Double = 5
    let padding: CGFloat = 20
    let colors = [Color("ColorViolet")]
    @State private var trainers: [Trainer] = [] // Updated to hold Trainer objects
    
    init(size: CGSize) {
        self.size = size
        getTrainerData() // Call to fetch trainer data when CarouselView is initialized
    }
    
    var body: some View {
        ScrollView(.horizontal){
            LazyHStack{
                ForEach(trainers.indices, id: \.self) { i in
                    let trainer = trainers[i]
                    let color = colors[i % colors.count]
                    item(trainer: trainer, color: color)
                    
                }
            }
            .padding(.horizontal, padding)
        }.onAppear{
            getTrainerData()
        }
    }
    
    func item(trainer: Trainer, color: Color) -> some View {
        let itemWidth: CGFloat = size.width - padding * 2
        return GeometryReader { reader in
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(color)
                VStack {
                    
                    ZStack {
                        Group{
                            Image("whiteElip")
                            Image("whiteElip")
                        }
                            //.resizable()
                            .frame(width: 264, height: 264)
                            
                        
                        WebImage(url: URL(string: trainer.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 249, height: 249)
                            .clipped()
                        .cornerRadius(150)
                        .overlay(RoundedRectangle(cornerRadius: 150)
                            .stroke(Color(.label), lineWidth: 1)
                        )
                        
                       
                            Text("\(trainer.name)\n\(trainer.surname)")
                                .padding()
                                .foregroundColor(.white)
                                .font(.system(size: 50, weight: .bold))
                                .italic()
                                .background(Color.black)
                                .cornerRadius(43)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil) // Отмена ограничения количества строк
                                .minimumScaleFactor(0.5)
                        
                        .padding(.top, 185)
                        .padding(.trailing, 150)
                        
                        
                    }
                    .padding(.top, -50)
                    .padding()
                    
                    
                   
                    Text(trainer.description)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
            .rotation3DEffect(
                getRotationAngel(reader: reader),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .frame(width: itemWidth, height: itemWidth * 1.4)
    }
    
    func getRotationAngel(reader: GeometryProxy) -> Angle {
        let midX = reader.frame(in: .global).midX
        let degrees = Double(midX - size.width / 2) / damping
        return Angle(degrees: -degrees)
    }
    
    func getTrainerData() {
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .whereField(FirebaseConstants.role, isEqualTo: "Тренер")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting trainer document: \(error)")
                } else {
                    var trainersData: [Trainer] = []
                    for document in querySnapshot?.documents ?? [] {
                        if let trainerData = document.data() as? [String: Any] {
                            let uid = document.documentID
                            let email = trainerData["email"] as? String ?? ""
                            let name = trainerData["name"] as? String ?? ""
                            let surname = trainerData["surname"] as? String ?? ""
                            let description = trainerData["description"] as? String ?? ""
                            let profileImageUrl = trainerData["profileImageUrl"] as? String ?? ""
                            
                            let trainer = Trainer(uid: uid, email: email, name: name, surname: surname, description: description, profileImageUrl: profileImageUrl)
                            trainersData.append(trainer)
                        }
                    }
                    self.trainers = trainersData
                }
            }
    }
}



#Preview {
    TrainerViewCarouselView()
}
