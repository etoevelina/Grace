//
//  AddNewsView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 01.04.2024.
//

import SwiftUI

struct AddNewsView: View {
    @State var description = ""
    @State var name = ""
    @State private var image: UIImage?
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        
        ZStack {
            Color(.black).ignoresSafeArea()
            Image("backSch")
                .resizable()
                .frame(width: 393, height: 892)
                .padding(.top, 38)
            
            Rectangle()
                .colorMultiply(.black)
                .frame(width: 393, height: 892)
                .opacity(0.5)
            VStack {
                
                Button {
                    shouldShowImagePicker.toggle()
                } label: {
                    VStack {
                        if let image = self.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 170)
                                .cornerRadius(170)
                                .overlay(
                                Circle()
                                 .stroke(Color.white, lineWidth: 2)
                            )
                                
                                
                        } else {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 80))
                                .padding()
                                .foregroundColor(.white)
                            
                                
                        }
                    }
                    
                }
                
                ZStack{
                    NamePlaceholder()
                    TextEditor(text: $name)
                        .frame(height: 60)
                    .opacity(name.isEmpty ? 0.5 : 1)
                }
                .background(Color(.systemGray))
                    .cornerRadius(15)
                    .padding(.horizontal)
                
                ZStack {
                           
                            DescriptionPlaceholder()
                            TextEditor(text: $description)

                     .opacity(description.isEmpty ? 0.5 : 1)
                }
                .frame(height: 100)
                .background(Color(.systemGray))
                .cornerRadius(15)
                .padding(.horizontal)
               // Spacer()
                
                
                
                Button {
                    let new = New(uid: "user_id", name: name, description: description, profileImageUrl: "", creationDate: Date())
                    if self.image != nil {
                           persistImageToStorage(uid: new.uid)
                       } else {
                           addNew(new: new)
                       }
                        
                } label: {
                    HStack{
                        Spacer()
                        Text("Добавить")
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
                    .padding(.horizontal)
                }
                Spacer()
            }
            .padding(.top, 200)
            Button {
                
            } label: {
                Text("")
            }
            
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
                .ignoresSafeArea()
        }
    }
    
    func addNew(new: New) {
        let db = FirebaseManager.shared.firestore
        let newsCollection = db.collection("news")
        
        do {
            // Добавление новой новости в коллекцию "news"
            try newsCollection.addDocument(from: new)
        } catch let error {
            print("Error adding document: \(error)")
        }
    }
    @State var loginStatusMessage = ""
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
                
                // Создание экземпляра New
                let new = New(uid: "user_id", name: self.name, description: self.description, profileImageUrl: url.absoluteString, creationDate: Date())
                
                // Добавление новости
                addNew(new: new)
            }
        }
    }

}
private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack{
            VStack(alignment: .leading) { // Изменение здесь
                Text("Описание")
                    .foregroundColor(Color(.white))
                    .font(.system(size: 17))
                    .padding(.top, 10)
                    .padding(.leading, 5)
                    Spacer()
                
            }
            Spacer()
        }
        
    }
}
    private struct NamePlaceholder: View {
        var body: some View {
            HStack {
                VStack (alignment: .leading) {
                    Text("Название")
                        .foregroundColor(Color(.white))
                        .font(.system(size: 17))
                        .padding(.top, -15)
                        .padding(.leading, 5)
                }
                Spacer()
            }
        }
    }

#Preview {
    AddNewsView()
}
