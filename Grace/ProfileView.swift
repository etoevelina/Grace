//
//  ProfileView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 08.02.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ProfileView: View {
    @ObservedObject var vm: MainPageViewViewModel
    
    @State var name = ""
    @State var surname = ""
    @State var email = ""
    @State var shouldShowDeleteAccount = false
    @State var shouldShowLogOutOptions = false
    
    var body: some View {
        
        NavigationView{
            
            
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack{
                    Form{
                        Section("Профиль"){
                            NavigationLink("Изменить личные данные"){
                                //CurrentUserDataView()
                                NavigationView{
                                    
                                    ZStack{
                                        Image("backSch")
                                            .resizable()
                                            .frame(width: 393, height: 912)
                                            .padding(.top, 38)
                                        
                                        Rectangle()
                                            .colorMultiply(.black)
                                            .frame(width: 393, height: 892)
                                            .opacity(0.5)
                                        
                                        
                                        
                                        VStack{
                                            
                                            VStack{
                                                Group {
                                                    TextField("Name", text: $name)
                                                    TextField("Surname", text: $surname)
                                                    TextField("Email", text: $email)
                                                        .disabled(true)
                                                    
                                                    
                                                    
                                                }.foregroundColor(.black)
                                                    .onAppear {
                                                        name =  vm.user?.name ?? ""
                                                        surname =  vm.user?.surname ?? ""
                                                        email =  vm.user?.email ?? ""
                                                    }
                                                
                                                    .padding(20)
                                                    .background(Color(.white))
                                                    .cornerRadius(15)
                                                    .frame(width: 300)
                                                
                                            }
                                            Button{
                                                updateProfile()
                                            }label: {
                                                Text("Сохранить данные")
                                            }
                                            .padding()
                                            
                                            
                                            //Spacer()
                                            
                                            Image("bigGirl")
                                                .resizable()
                                                .frame(width: 261, height: 402)
                                               // .padding(.top, 250)
                                        }
                                       // .padding(.bottom,300)
                                        
                                       
                                    }
                                }
                            }
                            NavigationLink("Абонемент"){
                                
                            }
                            NavigationLink("История покупок"){
                                
                            }
                            NavigationLink("Статистика посещений"){
                                
                            }
                        }
                        
                        
                        Section("Управление"){
                            Button {
                                shouldShowDeleteAccount.toggle()
                            } label: {
                                HStack{
                                    Image(systemName: "trash")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 1, green: 0.45, blue: 0.45))
                                    Text("Удалить аккаунт")
                                        .foregroundColor(Color(.label))
                                }
                            } .padding()
                                .actionSheet(isPresented: $shouldShowDeleteAccount) {
                                    .init(title: Text("Профиль"), message: Text("Что вы хотите сделать?"), buttons: [
                                        .destructive(Text("Удалить аккаунт"), action: {
                                            print("user delete")
                                            vm.deleteUser()
                                        }),
                                        .cancel()
                                    ])
                                }
                                             .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: {
                                                  self.vm.fetchCurrentUser()
                                              }) {
                                                  AuthView(didCompleteLoginProcess: {
                                                      self.vm.isUserCurrentlyLoggedOut = false
                                                  })
                                              }
                            
                            
                            Button {
                                shouldShowLogOutOptions.toggle()
                            } label: {
                                HStack{
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 1, green: 0.45, blue: 0.45))
                                    Text("Выйти")
                                        .foregroundColor(Color(.label))
                                }
                            }
                            
                            .padding()
                            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                                .init(title: Text("Профиль"), message: Text("Что вы хотите сделать?"), buttons: [
                                    .destructive(Text("Выйти"), action: {
                                        print("handle log out")
                                        vm.handleSignOut()
                                    }),
                                    .cancel()
                                ])
                            }
                                                                       .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: {
                                                                            self.vm.fetchCurrentUser()
                                                                        }) {
                                                                            AuthView(didCompleteLoginProcess: {
                                                                                self.vm.isUserCurrentlyLoggedOut = false
                                                                            })
                                                                        }
                        }
                    }.preferredColorScheme(.dark)
                    
                }.navigationBarTitle("Личный кабинет") // Заголовок навигационной панели
            }
        }.onAppear {
            vm.fetchCurrentUser()
        }
        
    }
    func updateProfile() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Current user ID is nil")
            return
        }
        
        // Обновление данных в Firestore
        FirebaseManager.shared.firestore.collection("users").document(userId).setData([
            "name": name,
            "surname": surname
        ], merge: true) { error in
            if let error = error {
                print("Error updating Firestore document: \(error)")
            } else {
                print("Firestore document successfully updated")
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(vm: MainPageViewViewModel())
    }
}
