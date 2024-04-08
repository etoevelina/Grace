//
//  ContentView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 07.02.2024.
//

import SwiftUI

struct RoundedCornerShape: Shape { // 1
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path { // 2
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


struct AuthView: View {
    let didCompleteLoginProcess: () -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var alertMessage = ""
    @State var shouldShowAler = false
    
    var body: some View {
        
        NavigationView{
            
            ZStack{
                
                
                
                Color.black.edgesIgnoringSafeArea(.all)
                
                Image("background")
                    .resizable()
                    .frame(width: 393, height: 852)
                    .edgesIgnoringSafeArea(.all)
                
               
                
                
                VStack {
                    Text("GRACE")
                        .font(.system(size: 65, weight: .bold))
                        .foregroundColor(Color(red: 1, green: 1, blue: 1))
                    VStack{
                        
                        Group() {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            
                            
                            SecureField("Password", text: $password)
                            
                            
                        }
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .shadow(color: Color(red: 0, green: 0, blue: 0).opacity(0.25), radius: 2, x: 10, y: 11)
                        .padding(.bottom, 20)
                        
                        
                        Button {
                            loginUser()
                        } label: {
                            HStack{
                                Spacer()
                                Text("Войти")
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
                    
                }
                .padding()
            }
        }.alert(isPresented: $shouldShowAler) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
            
            @State var loginStatusMessage = ""
            
            private func loginUser() {
                FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
                    if let err = err {
                        print("Failed to login user:", err)
                        self.loginStatusMessage = "Failed to login user: \(err)"
                        alertMessage = "Не удалось войти в систему: \(err)"
                        shouldShowAler = true
                        return
                        
                    }
                    
                    print("Successfully logged in as user: \(result?.user.uid ?? "")")
                    
                    self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
                    
                    self.didCompleteLoginProcess()
                    
                    //MenuView()
                }
            }
        
    
}

//#Preview {
//    AuthView(didCompleteLoginProcess: {
//        
//    })
//}

struct AuthView_Previews1: PreviewProvider {
    static var previews: some View {
        AuthView(didCompleteLoginProcess: {
            
        })
    }
}
