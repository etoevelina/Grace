//
//  ScheduleViewViewModel.swift
//  Grace
//
//  Created by Эвелина Пенькова on 29.03.2024.
//

import Foundation


class ScheduleViewModel: ObservableObject {
    @Published var trainingsForSelectedDate: [Training] = []
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    func fetchTrainings(forDate date: Date) {
        print("Fetching trainings for date: \(date)")
        let db = FirebaseManager.shared.firestore
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        db.collection("trainings").document(dateString).collection("trainings").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Ошибка получения тренировок: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.trainingsForSelectedDate = documents.compactMap { queryDocumentSnapshot in
                do {
                    // Получаем данные тренировки из документа Firestore
                    let data = queryDocumentSnapshot.data()
                    print("Данные тренировки из Firestore: \(data)")
             
                    // Преобразование строки времени в объект Date
                    guard let timeString = data["время"] as? String else {
                        print("Ошибка преобразования даты или времени")
                        return nil
                    }
                    
                    // Создаем объект timeFormatter для форматирования времени
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HH:mm"
                    
                    guard let time = timeFormatter.date(from: timeString) else {
                        print("Ошибка преобразования времени")
                        return nil
                    }
                    
                    // Преобразуем строки даты в объект Date
                    guard let dateString = data["дата"] as? String,
                          let date = dateFormatter.date(from: dateString) else {
                        print("Ошибка преобразования даты или времени")
                        return nil
                    }
                    
                    // Создаем экземпляр тренировки
                    let training = Training(
                        id: queryDocumentSnapshot.documentID,
                        name: data["название"] as? String ?? "",
                        date: date,
                        time: time,
                        amountOfPeople: data["Количество человек"] as? Int ?? 0,
                        // Добавляем проверку наличия описания тренировки в данных Firestore
                        description: data["описание"] as? String ?? "Описание отсутствует",
                        trainerSurname: data["Тренер"] as? String ?? "Тренер отсутствует",
                        imageName: data["Изображение"] as? String ?? "Изображение отсутсвует"
                    )
                    
                
                    
                    return training
                } catch {
                    print("Ошибка декодирования тренировки: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }
    
    func deleteTraining(atIndex index: Int) {
        // Удаляем тренировку из массива trainingsForSelectedDate по индексу
        trainingsForSelectedDate.remove(at: index)
        // Здесь вы можете добавить логику для удаления тренировки из базы данных, если это необходимо
    }

}
