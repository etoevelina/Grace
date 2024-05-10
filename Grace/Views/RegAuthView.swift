//
//  RegAuthView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 09.03.2024.
//

//import Foundation
//import SwiftUI
//import Firebase
//import FirebaseAuth
//
//
//
//struct RegAuthView: View {
//    
//    let didCompleteLoginProcess: () -> ()
//    
//    @State private var isLoginMode = true
//    @State private var email = ""
//    @State private var password = ""
//    @State private var name = ""
//    @State private var surname = ""
//    @State private var userType: UserTypes = .client
//    @State private var description = ""
//   
//     
//    
//    var body: some View {
//        
//     
//        
//            NavigationView {
//                ZStack{
//                    
//                    Color.black.edgesIgnoringSafeArea(.all)
//                    
//                    Image("background")
//                        .resizable()
//                        .frame(width: 393, height: 852)
//                        .edgesIgnoringSafeArea(.all)
//                    
//                    
//             
//                        
//                        VStack(spacing: 16) {
//                            
//                            Text("GRACE")
//                                .font(.system(size: 65, weight: .bold))
//                                .foregroundColor(Color(red: 1, green: 1, blue: 1))
//                            
//                            Picker(selection: $isLoginMode, label: Text("Picker here")) {
//                                
//                                
//                                Text("Войти")
//                                .tag(true)
//                                Text("Создать аккаунт")
//                                    .tag(false)
//                            }.pickerStyle(SegmentedPickerStyle())
//                                .opacity(0)
//                            
//                            
//                            if !isLoginMode {
//                             
//                                
//                                TextField("Имя", text: $name)
//                                    .padding(20)
//                                    .background(Color.white)
//                                    .cornerRadius(15)
//                                
//                                TextField("Фамилия", text: $surname)
//                                    .padding(20)
//                                    .background(Color.white)
//                                    .cornerRadius(15)
//                                    
//                            }
//                            
//                            
//                            
//                            Group {
//                                TextField("Email", text: $email)
//                                    .keyboardType(.emailAddress)
//                                    .autocapitalization(.none)
//                                SecureField("Пароль", text: $password)
//                            }
//                            .padding(20)
//                            .background(Color.white)
//                            .cornerRadius(15)
//                            
//                          
//                            
//                            
//                            Button {
//                                handleAction()
//                                
//                            } label: {
//                                HStack {
//                                    Spacer()
//                                    Text(isLoginMode ? "Войти" : "Создать аккаунт")
//                                        
//                                        .foregroundColor(.white)
//                                        .padding(.vertical, 20)
//                                        .font(.system(size: 20, weight: .semibold))
//                                    Spacer()
//                                }.background(Color(red: 0.43, green: 0.3, blue: 0.46))
//                                    .clipShape( // 1
//                                        RoundedCornerShape( // 2
//                                            radius: 20,
//                                            corners: [.bottomLeft, .bottomRight, .topRight]
//                                        )
//                                    )
//                                //    .cornerRadius(20, corners: [.topRight])
//                                
//                            }
//                            
//                            Text("Или")
//                            
//                            Button {
//                                      isLoginMode.toggle()
//                            } label: {
//                                Text(isLoginMode ? "Создать аккаунт" : "Войти")
//                                          .foregroundColor(Color(.darkGray))
//                                          .padding(.vertical, 20)
//                                          .font(.system(size: 20, weight: .semibold))
//                                          .padding(.horizontal)
//                                  }
//                                  .background(Color(.white)
//                                    .opacity(0.7)
//                                    .cornerRadius(20)
//                                    .padding(.top, 10))
//                            
//                            
//                            Text(self.loginStatusMessage)
//                                .foregroundColor(.red)
//                        }
//                        //.padding()
//                    .padding()
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                
//                
//            }
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        
//    
//    }
//    
//    private func handleAction() {
//        if isLoginMode {
////            print("Should log into Firebase with existing credentials")
//            loginUser()
//            
//        } else {
//            createNewAccount()
//            
////            print("Register a new account inside of Firebase Auth and then store image in Storage somehow....")
//        }
//    }
//    
//    private func loginUser() {
//        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
//            if let err = err {
//                print("Failed to login user:", err)
//                self.loginStatusMessage = "Failed to login user: \(err)"
//                return
//            }
//            
//            print("Successfully logged in as user: \(result?.user.uid ?? "")")
//            
//            self.didCompleteLoginProcess()
//        }
//    }
//    
//    @State var loginStatusMessage = ""
//    
//    private func createNewAccount() {
//        
//        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
//            if let err = err {
//                print("Failed to create user:", err)
//                self.loginStatusMessage = "Failed to create user: \(err)"
//                return
//            }
//            
//            guard let uid = result?.user.uid else {
//                loginStatusMessage = "Failed to retrieve user ID"
//                return
//            }
//            
//            
//            print("Successfully created user: \(result?.user.uid ?? "")")
//            
//            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
//            
//            self.storeUserInformation(uid: uid, imageUrl: "")
//            
//            
//        }
//        
//        
//    }
//    
//    
//    
//    
//   
//    
//    private func storeUserInformation(uid: String, imageUrl: String) {
//        let userData: [String: Any] = [
//            FirebaseConstants.email: email,
//            FirebaseConstants.uid: uid,
//            FirebaseConstants.name: name,
//            FirebaseConstants.surname: surname,
//            FirebaseConstants.role: userType.title,
//            FirebaseConstants.description: description,
//            FirebaseConstants.profileImageUrl: imageUrl
//        ]
//        
//        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
//            .document(uid).setData(userData) { err in
//                if let err = err {
//                    loginStatusMessage = "Failed to store user information: \(err.localizedDescription)"
//                    return
//                }
//                
//                loginStatusMessage = "User information stored successfully"
//            }
//    }
//
//}
//
//struct ContentView_Previews1: PreviewProvider {
//    static var previews: some View {
//        RegAuthView(didCompleteLoginProcess: {
//            
//        })
//    }
//}
