//
//  ScheduleView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 08.02.2024.
//

import SwiftUI

extension Training {
    var hasStarted: Bool {
        return Date() >= self.time
    }
}



struct ScheduleView: View {
    @State private var selectedDate = Date()
    @State private var selectedDateIndex: Int? = 0
    @ObservedObject var viewModel = ScheduleViewModel()
    @ObservedObject var vm = MainPageViewViewModel()
    
    let daysOfWeek = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]
    
    init() {
        _selectedDateIndex = State(initialValue: indexOfCurrentDate ?? 0)
    }
    
    var allDatesOfYear: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        let currentDate = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        let startDateComponents = DateComponents(year: year, month: 1, day: 1)
        let endDateComponents = DateComponents(year: year + 1, month: 1, day: 1)
        
        if let startDate = calendar.date(from: startDateComponents),
           let endDate = calendar.date(from: endDateComponents) {
            var dates: [String] = []
            var currentDate = startDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM"
            
            while currentDate < endDate {
                let dateString = dateFormatter.string(from: currentDate)
                dates.append(dateString)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            return dates
        }
        
        return []
    }
    
    var indexOfCurrentDate: Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        let currentDate = formatter.string(from: Date())
        return allDatesOfYear.firstIndex(of: currentDate)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("backSch")
                    .resizable()
                    .frame(width: 393, height: 892)
                    .padding(.top, 38)
                
                Rectangle()
                    .colorMultiply(.black)
                    .frame(width: 393, height: 892)
                    .opacity(0.5)
                
                VStack(spacing: 0){
                    HStack(spacing: -15){
                        Text("Расписание")
                            .font(.system(size: 35, weight: .bold))
                        Image("girlSch")
                            .resizable()
                            .frame(width: 176, height: 166)
                    }.padding(.top, 90)
                    
                    
                    
    ScrollView(.horizontal, showsIndicators: false) {
        ScrollViewReader { scrollView in
            HStack(spacing: 15) {
                ForEach(0..<allDatesOfYear.count, id: \.self) { index in
                    Button(action: {
                        selectedDateIndex = index
                        selectedDate = getDateFromIndex(index)
                        viewModel.fetchTrainings(forDate: selectedDate)
                    }) {
                        VStack {
                            Text(allDatesOfYear[index])
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(selectedDateIndex == index ? .white : .primary)
                            Text(daysOfWeek[index % 7])
                                .font(.system(size: 15))
                                .foregroundColor(selectedDateIndex == index ? .white : .primary)
                        }
                        .frame(width: 65, height: 65)
                        .background(selectedDateIndex == index ? Color("ColorPurple") : Color.clear)
                        .cornerRadius(65)
                    }
                }
                
            }
            .padding(.horizontal, 10)
            .onAppear {
                // Прокручиваем ScrollView к текущей дате при загрузке
                if let indexOfCurrentDate = indexOfCurrentDate {
                    DispatchQueue.main.async {
                        withAnimation {
                            scrollView.scrollTo(indexOfCurrentDate)
                            // Выбираем сегодняшнюю дату
                            selectedDate = getDateFromIndex(indexOfCurrentDate)
                            viewModel.fetchTrainings(forDate: selectedDate)
                        }
                    }
                }
            }
        }
        
    }
    .padding()
    ScrollView{
    VStack(spacing: 0) {
        if !viewModel.trainingsForSelectedDate.isEmpty {
            ForEach(viewModel.trainingsForSelectedDate.sorted(by: { $0.time < $1.time })) { training in
                NavigationLink(destination: TrainView(training: training)) {
                    ZStack{
                        Rectangle()
                            .stroke(Color(red: 1, green: 1, blue: 1), lineWidth: 1)
                            .frame(width: 399, height: 62)
                            .background(Color(.black).opacity(0.3))
                        //.opacity(0.3)
                        HStack{
                            Text("\(formattedTime(from: training.time))")
                            
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.93))
                            
                            Spacer()
                            
                            Text(training.name)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 25, weight: .bold))
                            Spacer()
                            Text("\(training.amountOfPeople)")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(Color(red: 0.24, green: 1, blue: 0))
                        }
                        .frame(width: 354)
                        .foregroundColor(.white)
                        
                        
                    }
                    
                }
            }
            
        } else {
            Text("Тренировок на выбранную дату нет")
                .foregroundColor(.white)
                .padding()
        }
        
    }
         if vm.user?.role == "Администратор" {
            NavigationLink {
                AddNewTrainView()
                    .navigationTitle("Добавить занятие")
                    .navigationBarTitleDisplayMode(.large)
            } label: {
                Text("Добавить занятие")
            }
        }
    }
                   
                    
                
                    
//                    NavigationLink(destination: AddNewTrainView()) {
//                        Text("Добавить занятие")
//                    }
                    

                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    func getDateFromIndex(_ index: Int) -> Date {
        let dateString = allDatesOfYear[index]
        let components = dateString.components(separatedBy: ".")
        
        guard components.count == 2,
              let day = Int(components[0]),
              let month = Int(components[1]) else {
            // Если разделение по "." не удалось или количество компонентов неверное,
            // возвращаем текущую дату
            return Date()
        }
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        
        // Создаем дату на основе компонентов дня, месяца и текущего года
        if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
            return date
        } else {
            // Если создание даты не удалось, возвращаем текущую дату
            return Date()
        }
    }
    func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }



}

#Preview {
    ScheduleView()
}
