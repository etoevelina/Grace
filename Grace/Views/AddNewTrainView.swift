//
//  AddNewTrainView.swift
//  Grace
//
//  Created by Эвелина Пенькова on 19.02.2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift



struct Training: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var date:  Date
    var time: Date
    var amountOfPeople: Int
    var description: String
    var trainerSurname: String
    var imageName: String

    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case date
        case time
        case amountOfPeople
        case description
        case trainerSurname
        case imageName
    }
}

enum Descriptions: String, CaseIterable, Identifiable{
    
    case stretching
    case yoga
    case trx
    case functionalTrain
    case silovaya
    
    var id: Self {
        self
    }
    var fullText: String{
        switch self{
            
        case .stretching:
            return "Тренировка по растяжке включает в себя общую растяжку всех основных групп мышц, таких как ноги, спина, плечи и шея. Упражнения выполняются плавно и удерживаются в течение 15-30 секунд для каждой группы мышц. Важно сосредоточиться на правильном дыхании и расслаблении во время растяжки."
        case .yoga:
            return "Йога - это практика, которая способствует укреплению и гибкости тела, улучшает дыхание и сосредоточение. Позы (асаны) выполняются плавно, помогая растягивать мышцы и успокаивать ум. Практика йоги приносит гармонию и равновесие в жизнь."
        case .trx:
            return "Тренировки TRX включают в себя использование петель для тренировки всех групп мышц. Эффективные упражнения помогают развить силу, гибкость и выносливость. Важно правильно выполнять каждое движение и поддерживать напряжение в мышцах. Тренировки TRX приносят результаты и улучшают физическую форму."
        case .functionalTrain:
            return "Круговая тренировка - это комплекс упражнений, направленных на развитие силы, выносливости и гибкости. Включает в себя выполнение различных упражнений без перерывов. Важно поддерживать высокий темп и правильно выполнять каждое движение. Круговые тренировки эффективно укрепляют тело и улучшают общую физическую форму."
        case .silovaya:
            return "Тренировки на барре объединяют элементы балета, йоги и силовых упражнений. Они направлены на укрепление мышц, улучшение гибкости и выносливости. Важно контролировать каждое движение и поддерживать правильную позу. Тренировки на барре эффективно формируют стройное тело и грациозную осанку."
            
      
        }
    }
}

enum Trains: String, CaseIterable, Identifiable{
    
    case stretching
    case yoga
    case trx
    case functionalTrain
    case silovaya
    
    
    var id: Self {
        self
    }
    
    var title: String{
        switch self{
            
        case .stretching:
            return "Растяжка"
        case .yoga:
            return "Йога"
        case .trx:
            return "TRX"
        case .functionalTrain:
            return "Круговая тренировка"
        case .silovaya:
            return "Барре"
        }
    }
    var imageName: String { // Добавляем свойство для имени изображения
            switch self {
            case .stretching:
                return "stretching" // Имя файла изображения для растяжки
            case .yoga:
                return "yoga" // Имя файла изображения для йоги
            case .trx:
                return "trx" // Имя файла изображения для TRX
            case .functionalTrain:
                return "functionalTrain" // Имя файла изображения для круговой тренировки
            case .silovaya:
                return "barre" // Имя файла изображения для барре
            }
        }
}


struct AddNewTrainView: View {
    @State private var date = Date()
    @State private var weekday = ""
    @State private var time = Date()
    @State private var amountOfPeople = "10"
    @State private var name: Trains = .stretching
    @State private var description: Descriptions = .stretching
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = MainPageViewViewModel()
    @State private var selectedTrainerIndex = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {

            ZStack {
              
                
                
                VStack {
//                    Text("Добавление тренировки")
//                        .font(.system(size: 35, weight: .bold))
//                        .multilineTextAlignment(.leading)
//                        .padding(.trailing, 100)
                    
                    
                    Form {
                        HStack {
                            //Text("Название:")
                            
                            Picker("Название:", selection: $name) {
                                ForEach(Trains.allCases) { train in
                                    Text(train.title).tag(train)
                                }
                            }
                            .onChange(of: name) { newValue in
                                // Обновляем описание тренировки при выборе новой тренировки
                                switch newValue {
                                case .stretching:
                                    description = .stretching
                                case .yoga:
                                    description = .yoga
                                case .trx:
                                    description = .trx
                                case .functionalTrain:
                                    description = .functionalTrain
                                case .silovaya:
                                    description = .silovaya
                                }
                            }
                        }
                        
                        HStack {
                            Text("Дата:")
                            Spacer()
                            DatePicker("Дата", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "ru_RU"))
                        }
                        
                        HStack {
                            Text("Время:")
                            Spacer()
                            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        
                        Picker("Тренер:", selection: $selectedTrainerIndex) {
                                           ForEach(viewModel.trainerLastNames.indices, id: \.self) { index in
                                               Text(viewModel.trainerLastNames[index])
                                           }
                                       }
                                       .onAppear {
                                           // Получаем список тренеров при загрузке представления
                                           viewModel.getUsersWithRoleTrainer()
                                       }
                        
                        HStack {
                            //Text("Описание:")
                            Picker("Описание:", selection: $description) {
                                ForEach(Descriptions.allCases) { description in
                                    let truncatedDescription = String(description.fullText.split(separator: " ").prefix(5).joined(separator: " ")) // Ограничиваем до первых 5 слов
                                    Text(truncatedDescription).tag(description)
                                }
                            }
                            .foregroundColor(.white)
                        }

                        
                        Picker("Количество мест:", selection: $amountOfPeople) {
                            ForEach(1..<21, id: \.self) { num in
                                Text(String(num))
                                    .tag(String(num))
                            }
                        }
                        HStack{
                            Spacer()
                            Button {
                                addTraining()
                            } label: {
                                Text("Добавить ")
                                
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Сохранение данных"), message: Text(alertMessage), dismissButton: .default(Text("ОК")))
                            }
                           Spacer()
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
            
        }

    func addTraining() {
        
        guard let amount = Int(amountOfPeople) else {
                print("Невозможно преобразовать количество людей в число")
                return
            }
        let selectedTrainerSurname = viewModel.trainerLastNames[selectedTrainerIndex]
        let db = Firestore.firestore()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            
        let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: time)
        
            db.collection("trainings").document(dateString).collection("trainings").addDocument(data: [
                "название": name.title,
                "дата": dateString,
                "время": timeString,
                "Количество человек": amount,
                "Тренер": selectedTrainerSurname,
                "описание": description.fullText,
               // "тренер": trainer
            ]) { err in
                if let err = err {
                    print("Ошибка добавления тренировки: \(err)")
                    showAlert = true
                    alertMessage = "Ошибка добавления тренировки: \(err)"
                } else {
                    print("Тренировка успешно добавлена")
                    showAlert = true
                    alertMessage = "Тренировка успешно добавлена"
                }
            }
    }
}

#Preview {
    AddNewTrainView()
}
