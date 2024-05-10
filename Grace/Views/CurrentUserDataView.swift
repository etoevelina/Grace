//
//  CurrentUserDataView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 12.02.2024.
//

import SwiftUI

struct CurrentUserDataView: View {
    
    @ObservedObject var vm = MainPageViewViewModel()
    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    
    var body: some View {
        
        
        NavigationView{
           
            ZStack{
                
               
                Image("bigGirl")
                    .resizable()
                    .frame(width: 261, height: 402)
                    .padding(.top, 300)
                
                VStack{
                    
                    VStack{
                        Group {
                            TextField("Name", text: $name)
                            TextField("Surname", text: $surname)
                            TextField("Email", text: $email)
                            
                            
                            
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
                        
                    }label: {
                        Text("Save edit data")
                    }
                    .padding()
                    
                    
                    Spacer()
                }
            }
        }
    }
    
}

#Preview {
    CurrentUserDataView()
}
