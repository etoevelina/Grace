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
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case date
        case time
        case amountOfPeople
        case description
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
            return "Тренировка по Йоге включает в себя общую растяжку всех основных групп мышц, таких как ноги, спина, плечи и шея. Упражнения выполняются плавно и удерживаются в течение 15-30 секунд для каждой группы мышц. Важно сосредоточиться на правильном дыхании и расслаблении во время растяжки."
        case .trx:
            return "Тренировка по ТРХ включает в себя общую растяжку всех основных групп мышц, таких как ноги, спина, плечи и шея. Упражнения выполняются плавно и удерживаются в течение 15-30 секунд для каждой группы мышц. Важно сосредоточиться на правильном дыхании и расслаблении во время растяжки."
        case .functionalTrain:
            return "Тренировка по растяжке включает в себя общую растяжку всех основных групп мышц, таких как ноги, спина, плечи и шея. Упражнения выполняются плавно и удерживаются в течение 15-30 секунд для каждой группы мышц. Важно сосредоточиться на правильном дыхании и расслаблении во время растяжки."
        case .silovaya:
            return "Тренировка по Барре включает в себя общую растяжку всех основных групп мышц, таких как ноги, спина, плечи и шея. Упражнения выполняются плавно и удерживаются в течение 15-30 секунд для каждой группы мышц. Важно сосредоточиться на правильном дыхании и расслаблении во время растяжки."
            
      
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
            return "Функциональная тренировка"
        case .silovaya:
            return "Барре"
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
    
    var body: some View {
        NavigationView{
            ZStack {
              
                
                
                VStack {
                    Text("Добавление тренировки")
                        .font(.system(size: 35, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 100)
                    
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
                        
                        Text("Тренер:")
                        
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
                    }

                    
                    Button {
                        addTraining()
                    } label: {
                        Text("Добавить ")
                    }
                }
                
                
            }
            .preferredColorScheme(.dark)
            
        }
        
    }
 
    
    func addTraining() {
        
        guard let amount = Int(amountOfPeople) else {
                print("Невозможно преобразовать количество людей в число")
                return
            }
        // Создаем экземпляр тренировки
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
                "описание": description.fullText,
               // "тренер": trainer
            ]) { err in
                if let err = err {
                    print("Ошибка добавления тренировки: \(err)")
                } else {
                    print("Тренировка успешно добавлена")
                }
            }
    }
}

#Preview {
    AddNewTrainView()
}
