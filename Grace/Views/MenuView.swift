//
//  MenuView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 08.02.2024.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject  var vm = MainPageViewViewModel()
    @State private var isMainPageViewActive = false
    
    
    var body: some View {
        NavigationView {
            TabView {
                MainPageView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Главная")
                    }.onAppear {
                        print("MainPageView appeared")
                        isMainPageViewActive = true
                    }
                ScheduleView()
                    .tabItem {
                        Image(systemName: "list.bullet.clipboard")
                        Text("Расписание")
                    }
                ProfileView(vm: vm)
                .tabItem {
                        Image(systemName: "person.circle")
                        Text("Профиль")
                    }
                    .onAppear(){
                        print("MenuView appeared")
                    }
    
                }
            //РАСКОММЕНТИРОВАТЬ ПЕРЕД ИСПОЛЬЗОВАНИЕ!!!!!!!
                    .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
                        AuthView(didCompleteLoginProcess: {
                    vm.isUserCurrentlyLoggedOut = false
                })
            }
        }
    }
}

struct MenuView_Previews1: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}

