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
    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var shouldShowDeleteAccount = false
    @State private var shouldShowLogOutOptions = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Личный кабинет")
                        .font(.bold(.largeTitle)())
                    Spacer()
                }
                .padding()
                Form {
                    Section("Профиль") {
                        NavigationLink("Просмотр и изменение личных данных") {
                            NavigationView {
                                ZStack {
                                    Image("backSch")
                                        .resizable()
                                        .frame(width: 413, height: 902)
                                        .ignoresSafeArea()
                                    Rectangle()
                                        .colorMultiply(.black)
                                        .frame(width: 413, height: 902)
                                        .opacity(0.5)
                                    VStack {
                                        VStack {
                                            Group {
                                                TextField("Name", text: $name)
                                                TextField("Surname", text: $surname)
                                                TextField("Email", text: $email)
                                                    .disabled(true)
                                            }
                                            .foregroundColor(.black)
                                            .onAppear {
                                                name = vm.user?.name ?? ""
                                                surname = vm.user?.surname ?? ""
                                                email = vm.user?.email ?? ""
                                            }
                                            .padding(20)
                                            .background(Color(.white))
                                            .cornerRadius(15)
                                            .frame(width: 300)
                                        }
                                        Button {
                                            updateProfile()
                                        } label: {
                                            Text("Сохранить данные")
                                        }
                                        .padding()
                                        .alert(isPresented: $showAlert) {
                                            Alert(title: Text("Сохранение данных"), message: Text(alertMessage), dismissButton: .default(Text("ОК")))
                                        }
                                    }
                                }
                            }
                        }
                        if vm.user?.role == "Администратор" {
                            NavigationLink("Добавить пользователя") {
                                RegView()
                            }
                            NavigationLink("Добавить новость") {
                                AddNewsView()
                            }
                            NavigationLink("Посмотреть статистику") {
                                StatisticView()
                            }
                        }
                    }
                    Section("Управление") {
                        Button {
                            shouldShowDeleteAccount.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(Color(red: 1, green: 0.45, blue: 0.45))
                                Text("Удалить аккаунт")
                                    .foregroundColor(Color(.label))
                            }
                        }
                        .padding()
                        .actionSheet(isPresented: $shouldShowDeleteAccount) {
                            .init(title: Text("Профиль"), message: Text("Что вы хотите сделать?"), buttons: [
                                .destructive(Text("Удалить аккаунт"), action: {
                                    print("user delete")
                                    vm.deleteUser()
                                }),
                                .cancel()
                            ])
                        }

                        Button {
                            shouldShowLogOutOptions.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
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
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
            AuthView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
            })
        }
        .overlay(
            Group {
                if vm.isLoading {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Logging out...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        )
        .onAppear {
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
                showAlert = true
                alertMessage = "Ошибка сохранения данных \(error)"
            } else {
                print("Firestore document successfully updated")
                showAlert = true
                alertMessage = "Данные успешно сохранены"
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(vm: MainPageViewViewModel())
    }
}
