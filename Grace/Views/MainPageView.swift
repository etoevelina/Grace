//
//  MainPageView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 07.02.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct MainPageView: View {
    @ObservedObject private var vm = MainPageViewViewModel()
    @ObservedObject var manager = HealthManager()
    @State var show = false
    
    var body: some View {
        
        //        NavigationView {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: -3){
                HStack{
                    Text("Привет, \(vm.user?.name ?? "")!")
                        .font(.system(size: 37, weight: .bold))
                        .foregroundColor(Color(.white))
                        .frame(width: 168)
                    
                    Image("gitlTop")
                        .resizable()
                        .frame(width: 121, height: 164)
                }
                
                VStack{
                    Button {
                        
                        self.show.toggle()
                        
                    } label: {
                        
                        ZStack{
                            Image("ButtonTop")
                                .resizable()
                                .frame(width: 325, height: 192)
                            
                            Text("Активность за день")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color(red: 0, green: 0, blue: 0))
                                .frame(width: 208, height: 74)
                                .multilineTextAlignment(.leading)
                                .padding(.trailing, 127)
                        }
                        
                    }.sheet(isPresented: $show) {
                        ActivityView(manager: manager, show: $show) // Передача экземпляра HealthManager в ActivityView
                            .onAppear {
                                manager.fetchAllData()
                                print("activity view appeared")
                            }
                    }
                    NavigationLink(destination: TrainingsCarousel()) {
                        ZStack{
                            Image("ButtonBottom")
                                .resizable()
                                .frame(width: 325, height: 192)
                            
                            Text("Тренировки")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color(red: 0, green: 0, blue: 0))
                                .frame(width: 208, height: 74)
                                .multilineTextAlignment(.leading)
                                .padding(.trailing, 127)
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        
                    }
                    
                    
                    HStack(){
                        
                        VStack{
                            NavigationLink(destination: TrainerViewCarouselView()) {
                                ZStack {
                                    Image("ButtonLeft")
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                    Text("Тренеры")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(Color(.white))
                                        .padding(.bottom, 95)
                                    Image("girlBlonde")
                                        .resizable()
                                        .frame(width: 120, height: 118)
                                        .padding(.top, 28)
                                }
                            }
                            
                        }.padding(.trailing, 13)
                        
                        
                        VStack{
                            NavigationLink(destination: 
                                            NewsView()) {
                                ZStack {
                                    Image("ButtonLeft")
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                    Text("Новости")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(Color(.white))
                                        .padding(.bottom, 95)
                                    
                                    Image("news")
                                        .resizable()
                                        .frame(width: 97, height: 76)
                                        .padding(.leading, 55)
                                        .padding(.bottom, 7)
                                    
                                    
                                    Image("girl1")
                                        .resizable()
                                        .frame(width: 73, height: 131)
                                        .padding(.trailing, 50)
                                        .padding(.top, 28)
                                }
                                
                            }
                        } .padding(.top, 11)
                    }
                }
            }
        }
        .padding(.bottom, 25)
        .background(Color(.black))
        //        }
        .onAppear {
            vm.fetchCurrentUser()
        }
    }
}

struct MainPageView_Previews1: PreviewProvider {
    static var previews: some View {
        MainPageView()
    }
}
