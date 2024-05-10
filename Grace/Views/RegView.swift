//
//  RegView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 07.02.2024.
//

import SwiftUI

enum UserTypes: String, CaseIterable, Identifiable {
    case trainer
    case client
    case administrator
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .trainer:
            return "Тренер"
        case .client:
            return "Клиент"
        case .administrator:
            return "Администратор"
        }
    }
}

struct RegView: View {
    
    @State private var userType: UserTypes = .client
    @State private var shouldShowImagePicker = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var surname = ""
    @State private var image: UIImage?
    @State private var description = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
//        NavigationView {
            ScrollView{
                ZStack {
                    VStack (spacing: 70) {
                    HStack {
                        Picker("Название:", selection: $userType) {
                            ForEach(UserTypes.allCases) { userType in
                                Text(userType.title).tag(userType)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                    }
                    
                        VStack {
                            Group {
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                
                                TextField("Пароль", text: $password)
                                
                                TextField("Имя", text: $name)
                                
                                TextField("Фамилия", text: $surname)
                          }
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .shadow(color: Color(red: 0, green: 0, blue: 0).opacity(0.25), radius: 2, x: 10, y: 11)
                            .padding(.bottom, 20)
                            
                            if userType == .trainer {
                                TextField("Описание", text: $description)
                                    .foregroundColor(.white)
                                    .padding(20)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(15)
                                    .shadow(color: Color(red: 0, green: 0, blue: 0).opacity(0.25), radius: 2, x: 10, y: 11)
                                    .padding(.bottom, 20)
                                
                                Button {
                                    shouldShowImagePicker.toggle()
                                } label: {
                                    VStack {
                                        if let image = self.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .cornerRadius(150)
                                        } else {
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 80))
                                                .padding()
                                                .foregroundColor(Color(.label))
                                        }
                                    }
                                    .overlay(RoundedRectangle(cornerRadius: 150)
                                        .stroke(Color.black, lineWidth: 2)
                                    )
                                }
                            }
                            
                            Button {
                                createNewAccount()
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("Зарегистрировать")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 20)
                                        .font(.system(size: 20, weight: .bold))
                                    Spacer()
                                }
                                .background(Color(red: 0.43, green: 0.3, blue: 0.46))
                                .clipShape( // 1
                                    RoundedCornerShape( // 2
                                        radius: 20,
                                        corners: [.bottomLeft, .bottomRight, .topRight]
                                                      )
                                )
                                .shadow(color: Color(red: 0, green: 0, blue: 0).opacity(0.25), radius: 2, x: 10, y: 11)
                            }
                            
                        }
                        .padding()
                    }
                    .padding()
                }
            }
        
//        } 
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
                    .ignoresSafeArea()
            }
                .alert(isPresented: $showAlert) {
                Alert(title: Text("Сообщение"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        
    }
    
    @State private var loginStatusMessage = ""
    
    private func createNewAccount() {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !surname.isEmpty else {
            loginStatusMessage = "Please fill in all fields"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { authResult, err in
                if let err = err {
                    loginStatusMessage = "Failed to create user: \(err.localizedDescription)"
                    alertMessage = "Ошибка создания пользователя \(err)"
                    showAlert = true
                    return
                }
            
            guard let uid = authResult?.user.uid else {
                        loginStatusMessage = "Failed to retrieve user ID"
                        return
                    }
            
            loginStatusMessage = "Successfully created user: \(uid)"
            
            if userType.title == "Тренер"{
                persistImageToStorage(uid: uid)
            } else {
                storeUserInformation(uid: uid, imageUrl: "")
            }
            
        }
    }
    
    private func persistImageToStorage(uid: String) {
        guard let image = self.image,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            loginStatusMessage = "Image is missing or invalid"
            return
        }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                loginStatusMessage = "Failed to push image to Storage: \(err.localizedDescription)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    loginStatusMessage = "Failed to retrieve download URL: \(err.localizedDescription)"
                    return
                }
                
                guard let url = url else {
                    loginStatusMessage = "Download URL is nil"
                    return
                }
                
                loginStatusMessage = "Successfully stored image with URL: \(url.absoluteString)"
                storeUserInformation(uid: uid, imageUrl: url.absoluteString)
            }
        }
    }
    
    private func storeUserInformation(uid: String, imageUrl: String) {
        let userData: [String: Any] = [
            FirebaseConstants.email: email,
            FirebaseConstants.uid: uid,
            FirebaseConstants.name: name,
            FirebaseConstants.surname: surname,
            FirebaseConstants.role: userType.title,
            FirebaseConstants.description: description,
            FirebaseConstants.profileImageUrl: imageUrl
        ]
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .document(uid).setData(userData) { err in
                if let err = err {
                    loginStatusMessage = "Failed to store user information: \(err.localizedDescription)"
                    alertMessage = "Польвотель не был добавлен. Ошибка \(err)"
                    showAlert = true
                    return
                } else {
                    alertMessage = "Пользователь с ролью \"\(userType.title)\" был успешно добавлен"
                    showAlert = true
                }
                
                loginStatusMessage = "User information stored successfully"
            }
    }
}
#Preview {
    RegView()
}
