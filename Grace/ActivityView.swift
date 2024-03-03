//
//  ActivityView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 13.02.2024.
//

import SwiftUI

struct GoalSelectionView: View {
    @Binding var goal: Int
    @State private var selectedGoal: Int // Уберем изначальное значение selectedGoal
    @Binding var isPresented: Bool
    
    var step: Int
    
    init(goal: Binding<Int>, step: Int, isPresented: Binding<Bool>) {
        self._goal = goal
        self.step = step
        self._selectedGoal = State(initialValue: goal.wrappedValue)
        self._isPresented = isPresented // Устанавливаем начальное значение selectedGoal из goal
    }
    
    var body: some View {
        VStack {
            Stepper(value: $selectedGoal, in: 0...30000, step: step) {
                Text("Цель: \(selectedGoal)")
            }
            .padding(20)
            .background(Color(.pink))
            .frame(width: 300)
            //.padding(20) // Добавить отступы
            .cornerRadius(18)
            
            Button(action: {
                saveSelectedGoal()
                withAnimation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                isPresented = false
                                  }
                              }
                          }) {
                Text("Сохранить цель")
            }
        }
    }
    
    func saveSelectedGoal() {
        goal = selectedGoal
        UserDefaults.standard.set(selectedGoal, forKey: "SelectedGoal")
        print("Новая цель: \(goal)")
    }
}



struct ActivityView: View {
    @ObservedObject var manager = HealthManager()

    @State var goalForSteps: Int = UserDefaults.standard.integer(forKey: "GoalForSteps")
       @State var goalForCalories: Int = UserDefaults.standard.integer(forKey: "GoalForCalories")
    @State private var showGoalSelectionForSteps = false
    @State private var showGoalSelectionForCalories = false
    @Binding var show: Bool
    
    var body: some View {
        VStack{
            HStack(spacing: 30){
                Text("Активность")
                    .font(.system(size: 32, weight: .bold))
                
                
                Group{
                    Image("fleme")
                        .resizable()
                        .frame(width: 108, height: 152)
                        .rotationEffect(Angle(degrees: 5))
                        
                }
            }.padding(.top, 25)
            
            HStack{
               ZStack{
                   
                   
                    Ellipse()
                        .colorMultiply(Color(red: 0, green: 0.96, blue: 1)).opacity(0.74)
                        .frame(width: 176, height: 176)
                        .blur(radius: 52.5)
                        
                   Ellipse()
                       .colorMultiply(.black)
                       .frame(width: 195, height: 195)
                   
                   RingView(ring: Ring(id: 1, wh: 130, target: CGFloat(goalForCalories), done: CGFloat(manager.caloriesToday), progress: 5, c1: "ColorCalories", c2: "ColorDarkBlue"), show: $show)
                      
                   
                   
                   RingView(ring: Ring(id: 0, wh: 176, target: CGFloat(goalForSteps), done: CGFloat(manager.stepsToday), progress: 5, c1: "ColorSteps", c2: "ColorDarkGreen"), show: $show)
                     
                   
                  
                   
                }.padding(.leading, 30)
                
                
                 Spacer()
                VStack(spacing: 10) {
                    ActivityCard(activity: Activity(id: 0, title: "Шаги сегодня", subtitle: "Цель: \(goalForSteps) шагов", image: "figure.walk", amount: String(manager.stepsToday), background: "", fieldForText: "ColorSteps", ramka: "GreenRam", shade: "ColorShadeSteps"))
                        .id(UUID())
                        .onTapGesture {
                            showGoalSelectionForSteps.toggle()
                        }
                        .sheet(isPresented: $showGoalSelectionForSteps) {
                            GoalSelectionView(goal: $goalForSteps, step: 500, isPresented: $showGoalSelectionForSteps)
                                .presentationDragIndicator(.visible)
                                .presentationDetents([.medium])
                        }
                    
                    ActivityCard(activity: Activity(id: 0, title: "Ккал сегодня", subtitle: "Цель: \(goalForCalories) шагов", image: "flame", amount: String(manager.caloriesToday), background: "", fieldForText: "ColorCalories", ramka: "BlueRam", shade: "ColorShadeSteps"))
                        .id(UUID())
                        .onTapGesture {
                            showGoalSelectionForCalories.toggle()
                        }
                        .sheet(isPresented: $showGoalSelectionForCalories) {
                            GoalSelectionView(goal: $goalForCalories, step: 50, isPresented: $showGoalSelectionForCalories)
                                .presentationDragIndicator(.visible)
                                .presentationDetents([.medium])
                        }
                }.padding(.horizontal)
                    .preferredColorScheme(.dark)
            }
            Spacer()
            
            VStack{
                ZStack{
                    Ellipse()
                        .colorMultiply(Color("ColorPink"))
                        .frame(width: 249, height: 249)
                        .cornerRadius(249)
                        .blur(radius: 58.5)
                    
                    Image("girlActivity1")
                        .resizable()
                        .frame(width: 305, height: 383)
                }
            }
            
        }
    
        .onDisappear {
                    UserDefaults.standard.set(goalForSteps, forKey: "GoalForSteps")
                    UserDefaults.standard.set(goalForCalories, forKey: "GoalForCalories")
                }
                .onAppear {
                    goalForSteps = UserDefaults.standard.integer(forKey: "GoalForSteps")
                    goalForCalories = UserDefaults.standard.integer(forKey: "GoalForCalories")
                }
            }
}



#Preview {
    ActivityView(show: .constant(true))
}
