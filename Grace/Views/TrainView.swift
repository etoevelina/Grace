//
//  TrainView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 27.02.2024.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore


struct TrainView: View {
    @State  var showReviewSheet = false
        @State  var rating = 0
        @State  var reviewText = ""
    @ObservedObject var vm = MainPageViewViewModel()
    let training: Training
    @State  var trainerData: Trainer? = nil
    let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    
    func getTrainerData() {
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .whereField("surname", isEqualTo: training.trainerSurname)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting trainer document: \(error)")
                } else {
                    if let document = querySnapshot?.documents.first {
                        if let trainerData = document.data() as? [String: Any] {
                            let uid = document.documentID
                            let email = trainerData["email"] as? String ?? ""
                            let name = trainerData["name"] as? String ?? ""
                            let surname = trainerData["surname"] as? String ?? ""
                            let description = trainerData["description"] as? String ?? ""
                            let profileImageUrl = trainerData["profileImageUrl"] as? String ?? ""
                            
                            self.trainerData = Trainer(uid: uid, email: email, name: name, surname: surname, description: description, profileImageUrl: profileImageUrl)
                        }
                    }
                }
            }
    }

    
    var body: some View {
       
        
        ZStack{
            Image("backSch")
                .resizable()
                .frame(width: 413, height: 902)
                .ignoresSafeArea()
            
            ZStack {
                Rectangle()
                    .colorMultiply(.black)
                    .frame(width: 413, height: 902)
                    .opacity(0.5)
                    .clipShape( // 1
                        RoundedCornerShape( // 2
                            radius: 20,
                            corners: [.bottomLeft, .bottomRight, .topRight]
                                          )
                )
            }
            
        
            
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
                        HStack(spacing: 10){
                            Text(timeFormatter.string(from: training.time))
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color(red: 1, green: 1, blue: 1))
                            
                            VStack(alignment: .leading){
                                Text(training.name)
                                    .font(.system(size: 18, weight: .bold))
                                   
                                
                                Text("\(training.amountOfPeople)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.54, green: 0.54, blue: 0.54))
                                    .padding(.trailing, 55)
                            }
                            //.padding()
                        }
                        
                    }
                  
                }.padding(.leading,220)
                
                if !training.description.isEmpty {
                    Text("\(training.description)")
                        .font(.system(size: 19, weight: .bold))
                        .frame(width: 337, height: 238)
                } else {
                    Text("No description available")
                        .font(.system(size: 19, weight: .bold))
                }
                
                if let trainerData = trainerData
                        
                {
                                HStack {
                                    ZStack{
                                        
                                       Image("Elipp")
                                            .frame(width: 135, height: 135)
                                        
                                        WebImage(url: URL(string: trainerData.profileImageUrl))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 154, height: 154)
                                            .clipped()
                                            .cornerRadius(154)
                                           
                                    }
                                    .padding()
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Тренер")
                                            .font(.system(size: 33, weight: .bold))
                                        Text("\(trainerData.name)")
                                            .font(.system(size: 28, weight: .bold))
                                        
                                           
                                    }
                                   Spacer()
                                }
                                .padding()
                                //.padding(.bottom, 20)
                }
                if vm.user?.role == "Клиент" {
                    Button {
                        showReviewSheet = true
                           }
                            label: {
                        HStack{
                            Spacer()
                            Text("Добавить отзыв")
                                .foregroundColor(.black)
                                .padding(.vertical, 20)
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                        }
                        .background(Color(red: 0.92, green: 0.6, blue: 1))
                        .clipShape( // 1
                            RoundedCornerShape( // 2
                                radius: 20,
                                corners: [.bottomLeft, .bottomRight, .topRight]
                                              )
                        )
                        .shadow(color: Color(red: 0, green: 0, blue: 0).opacity(0.25), radius: 2, x: 10, y: 11)
                    }.padding()
                        .sheet(isPresented: $showReviewSheet) {
                            ReviewSheetView(isPresented: $showReviewSheet, trainingName: training.name, trainerName: trainerData?.name ?? "", trainerSurname: trainerData?.surname ?? "", rating: $rating, reviewText: $reviewText, currentUserFirstName: vm.user?.name ?? "", currentUserLastName: vm.user?.surname ?? "")
                                .presentationDetents([.medium])
                        }
                }
                
            }
            
        }.preferredColorScheme(.dark)
            .onAppear {
                        // Получаем данные о тренере при загрузке представления
                        getTrainerData()
                            vm.fetchCurrentUser()
                    }
    }
   
}

struct TrainView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleTraining = Training(id: "1", name: "Растяжка", date: Date(), time: Date(), amountOfPeople: 10, description: "Тренировка по растяжке включает в себя общую растяжку всех основных групп мышц, таких как ноги, спина, плечи и шея. Упражнения выполняются плавно и удерживаются в течение 15-30 секунд для каждой группы мышц. Важно сосредоточиться на правильном дыхании и расслаблении во время растяжки.", trainerSurname: "Клювина", imageName: "")
        return TrainView(training: exampleTraining)
        
    }
}
