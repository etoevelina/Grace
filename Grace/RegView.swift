//
//  RegView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 07.02.2024.
//

import SwiftUI

struct RegView: View {
    
  
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var surname = ""
    
    var body: some View {
        VStack {
            
            VStack{
                
                Group {
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Password", text: $password)
                    TextField("Name", text: $name)
                    TextField("Surname", text: $surname)
                } .padding()
                
                Button {
                    createNewAccount()
                    
                } label: {
                    Text("Зарегистрировать")
                }
            }
            
        }
        .padding()
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            
            self.storeUserInformation()
            
        }
        
        
    }
    
    private func storeUserInformation() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.email: self.email,
                        FirebaseConstants.uid: uid,
                        FirebaseConstants.name: self.name,
                        FirebaseConstants.surname: self.surname
                        ]
                       
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                print("Success")
                
                
            }
    }
}
    





#Preview {
    RegView()
}
