//
//  ReviewSheetView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 26.04.2024.
//

import SwiftUI
import Firebase

struct ReviewSheetView: View {
    @Binding var isPresented: Bool
     var trainingName: String
     var trainerName: String
     var trainerSurname: String
    @Binding var rating: Int
    @Binding var reviewText: String
     var maxRating: Int = 5
     var currentUserFirstName: String
     var currentUserLastName: String
    @State private var isAnonymous = false
    @State private var showAlert = false
    @State private var alertMessage = ""

     var currentUserFullName: String {
         "\(currentUserFirstName) \(currentUserLastName)"
     }
    var body: some View {
        ZStack{
            Color(.black)
        VStack(spacing: 20) {
            Text("Ваши слова ценны для нас!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.top)
            
            HStack {
                ForEach(1...maxRating, id: \.self) { number in
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(number <= rating ? Color.yellow : Color.gray)
                        .onTapGesture {
                            rating = number
                        }
                }
            }
            .frame(height: 40)
            
            // Текстовое поле для ввода отзыва
            ZStack {
                Image("elips18")
                    .resizable()
                    .frame(width: 316, height: 90)
              TextEditor(text: $reviewText)
                    .padding(10)
                    .cornerRadius(10)
            }
            .frame(height: 100)
            .foregroundColor(.white)
            
            Toggle("Отправить анонимно", isOn: $isAnonymous)
                               .padding()
                               .foregroundColor(.white)

            Button(action: {
                saveReview()
            }) {
                Text("Сохранить")
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
        .padding()
    }
        .preferredColorScheme(.dark)
        .alert(isPresented: $showAlert) {
        Alert(title: Text("Сообщение"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
    }
        
    }
    func saveReview() {
        let userFullName = isAnonymous ? "Анонимно" : currentUserFullName
        // Данные для сохранения
        let reviewData: [String: Any] = [
            "trainingName": trainingName,
            "trainerName": trainerName,
            "trainerSurame": trainerSurname,
            "rating": rating,
            "reviewText": reviewText,
            "timestamp": Timestamp(date: Date()), // добавляем метку времени для отзыва
            "userFullName": userFullName,
            "isAnonymous": isAnonymous
        ]
        
        // Отправляем данные в коллекцию "Отзывы" в Firestore
        Firestore.firestore().collection("reviews").addDocument(data: reviewData) { error in
            if let error = error {
                print(error.localizedDescription)
                alertMessage = "Ошибка добавления отзыва \(error)"
                showAlert = true
            } else {
                print("Отзыв успешно сохранён.")
                DispatchQueue.main.async {
                    isPresented = false
                    rating = 0
                    reviewText = ""
                }
                alertMessage = "Отзыв успешно добавлен"
                showAlert = true
            }
        }
    }
   
}


//#Preview {
//    ReviewSheetView()
//}
