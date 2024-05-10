//
//  MainManager.swift
//  Grace
//
//  Created by Эвелина Пенькова on 13.02.2024.
//

import Foundation
import Firebase


class MainPageViewViewModel: ObservableObject{
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var isUserCurrentlyLoggedOut = false
    @Published var trainerLastNames: [String] = []
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    init() {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser == nil
            fetchCurrentUser()
        }

        func fetchCurrentUser() {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                self.isUserCurrentlyLoggedOut = true
                return
            }

            FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch current user:", error)
                    self.isUserCurrentlyLoggedOut = true
                    return
                }

                guard let data = snapshot?.data() else {
                    self.isUserCurrentlyLoggedOut = true
                    return
                }

                self.user = try? snapshot?.data(as: User.self)
                self.isUserCurrentlyLoggedOut = false
            }
        }

        func handleSignOut() {
            isLoading = true // Начало процесса выхода

            do {
                try FirebaseManager.shared.auth.signOut()
                print("Successfully signed out.")
                DispatchQueue.main.async {
                    self.isUserCurrentlyLoggedOut = true
                    self.isLoading = false // Конец процесса выхода
                }
            } catch let signOutError {
                print("Error signing out: \(signOutError.localizedDescription)")
                isLoading = false // Если произошла ошибка, обновляем состояние загрузки
            }
        }

        func deleteUser() {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                return
            }

            FirebaseManager.shared.firestore.collection("users").document(uid).delete { error in
                if let error = error {
                    print("Error deleting user: \(error)")
                    return
                }

                FirebaseManager.shared.auth.currentUser?.delete { error in
                    if let error = error {
                        print("Error deleting auth user: \(error)")
                        return
                    }

                    DispatchQueue.main.async {
                        self.isUserCurrentlyLoggedOut = true
                    }
                }
            }
        }
    
    func getUsersWithRoleTrainer() {
           FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
               .whereField(FirebaseConstants.role, isEqualTo: "Тренер")
               .getDocuments { [weak self] (querySnapshot, error) in
                   guard let self = self else { return }
                   if let error = error {
                       print("Error getting documents: \(error)")
                   } else {
                       var lastNames: [String] = []
                       for document in querySnapshot!.documents {
                           let userData = document.data()
                           if let surname = userData["surname"] as? String {
                               lastNames.append(surname)
                           }
                       }
                       // Обновляем список фамилий тренеров
                       DispatchQueue.main.async {
                           self.trainerLastNames = lastNames
                       }
                   }
               }
       }
}
  

