//
//  TranerReg.swift
//  Grace
//
//  Created by Эвелина Пенькова on 16.03.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct TranerReg: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var surname = ""
    @State private var description = ""
    @State private var image: UIImage?
    @State private var loginStatusMessage = ""
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                        TextField("Пароль", text: $password)
                        TextField("Имя", text: $name)
                        TextField("Фамилия", text: $surname)
                        TextField("Описание", text: $description)
                    }
                    .foregroundColor(.black)
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(15)
                    
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
                    Button {
                      createNewAccount()
                    } label: {
                        Text("REGIST")
                            .frame(width: 300, height: 100)
                            .foregroundColor(.white)
                    }
                }
            }.preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
                .ignoresSafeArea()
        }
    }
    
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
            
            
        }
        
        
    }
    
    
    
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Error: Current user UID is nil")
            return
        }
        print("UID: \(uid)")
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {
            print("Error: Image data is nil")
            return
        }
        print("Image data size: \(imageData.count) bytes")
        
        let ref = FirebaseManager.shared.storage.reference(withPath: "profile_images/\(uid)")
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("Failed to push image to Storage:", err)
                self.loginStatusMessage = "Failed to push image to Storage: \(err.localizedDescription)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    print("Failed to retrieve downloadURL:", err)
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err.localizedDescription)"
                    return
                }
                
                guard let url = url else {
                    print("Error: Download URL is nil")
                    self.loginStatusMessage = "Failed to retrieve downloadURL: Unknown error"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url.absoluteString)"
                print("Image URL: \(url.absoluteString)")
                
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }

    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Error: Current user UID is nil")
            return
        }
        print("UID: \(uid)")
        
        let tranerData = [
            FirebaseConstants.email: self.email,
            FirebaseConstants.uid: uid,
            FirebaseConstants.name: name,
            FirebaseConstants.surname: surname,
            FirebaseConstants.description: description,
            FirebaseConstants.profileImageUrl: imageProfileUrl.absoluteString
        ]
        FirebaseManager.shared.firestore.collection(FirebaseConstants.traners)
            .document(uid).setData(tranerData) { err in
                if let err = err {
                    print("Failed to store user information:", err)
                    self.loginStatusMessage = "Failed to store user information: \(err.localizedDescription)"
                    return
                }
                
                print("User information stored successfully")
                self.loginStatusMessage = "User information stored successfully"
            }
    }


}

struct TranerReg_1: PreviewProvider {
    static var previews: some View {
        TranerReg()
    }
}
