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
    
    
   // @Published var isUserCurrentlyLoggedOut = false
   
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            self.user = try? snapshot?.data(as: User.self)
            FirebaseManager.shared.currentUser = self.user
            
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
    func deleteUser() {
        
        let user = Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
              print("An error happened: \(error.localizedDescription)")
          } else {
              print("Account deleted.")
          }
        }
    }
    
}
