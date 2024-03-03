//
//  SwiftUIView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 18.03.2024.
//

import SwiftUI
import FirebaseFirestoreSwift

struct SwiftUIView: View {
    
    @StateObject private var viewModel = SwiftUIViewModel()
        @State private var selectedTrainerIndex = 0 // Выбранный индекс тренера в Picker
        
        var body: some View {
            VStack {
                Picker("Выберите тренера", selection: $selectedTrainerIndex) {
                    ForEach(0..<viewModel.trainerUsers.count, id: \.self) { index in
                        Text(viewModel.trainerUsers[index].surname)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            .onAppear {
                viewModel.getUsersWithRoleTrainer() // Загрузка данных о тренерах при появлении представления
            }
        }
    }

    class SwiftUIViewModel: ObservableObject {
        @Published var trainerUsers: [User] = [] // Массив для хранения пользователей с ролью "Тренер"
        
        func getUsersWithRoleTrainer() {
            FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
                .whereField(FirebaseConstants.role, isEqualTo: "Тренер")
                .getDocuments { [weak self] (querySnapshot, error) in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            // Пытаемся создать объект User из данных о тренере
                            if let user = try? document.data(as: User.self) {
                                DispatchQueue.main.async {
                                    self.trainerUsers.append(user)
                                }
                            } else {
                                print("Error decoding user")
                            }
                        }
                    }
            }
        }
    }


#Preview {
    SwiftUIView()
}
