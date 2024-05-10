//
//  AddNewsView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 01.04.2024.
//

import SwiftUI

struct AddNewsView: View {
    @State private var description = ""
    @State private var name = ""
    @State private var image: UIImage?
    @State private var shouldShowImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    var body: some View {
        
        ZStack {
            Color(.black).ignoresSafeArea()
            Image("backSch")
                .resizable()
                .frame(width: 413, height: 902)
                .ignoresSafeArea()
            
            Rectangle()
                .colorMultiply(.black)
                .frame(width: 413, height: 902)
                .ignoresSafeArea()
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
                Button {
                    addNew()
                        
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Сообщение"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }  
    func addNew() {
        let db = FirebaseManager.shared.firestore
        let newsCollection = db.collection("news")
        
        // Создаем новый документ в коллекции "news" и получаем его ID
        let newDocRef = newsCollection.document()
        let uid = newDocRef.documentID
        
        if let image = self.image {
            persistImageToStorage(uid: uid) { imageUrl in
                let new = New(uid: uid, name: self.name, description: self.description, profileImageUrl: imageUrl, creationDate: Date())
                saveNewToFirestore(new: new)
            }
        } else {
            let new = New(uid: uid, name: self.name, description: self.description, profileImageUrl: "", creationDate: Date())
            saveNewToFirestore(new: new)
        }
    }
    
    private func persistImageToStorage(uid: String, completion: @escaping (String) -> Void) {
        guard let image = self.image,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Image is missing or invalid")
            return
        }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("Failed to push image to Storage: \(err.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    print("Failed to retrieve download URL: \(err.localizedDescription)")
                    return
                }
                
                guard let url = url else {
                    print("Download URL is nil")
                    return
                }
                
                print("Successfully stored image with URL: \(url.absoluteString)")
                completion(url.absoluteString)
            }
        }
    }
    
    private func saveNewToFirestore(new: New) {
        let db = FirebaseManager.shared.firestore
        let newsCollection = db.collection("news")
        
        do {
            try newsCollection.document(new.uid).setData(from: new) { err in
            if let err = err {
                alertMessage = "Ошибка при добавлении новости: \(err.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Новость успешно добавлена!"
                showAlert = true
            }
        }
        } catch let error {
            print("Error adding document: \(error)")
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
