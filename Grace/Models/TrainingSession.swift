//
//  TrainingSession.swift
//  Grace
//
//  Created by Эвелина Пенькова on 22.02.2024.
//

import Foundation

enum TrainingStatus {
    case scheduled, completed, cancelled
}

struct TrainingSession {
    let name: String
    let date: Date
    let time: Date
    let amountOfPeople: Int
    let weekday: String
    var status: TrainingStatus
    var participants: [String] // IDs of participants
    let trainerSurname: String // Добавляем фамилию тренера

    mutating func updateStatus(newStatus: TrainingStatus) {
        status = newStatus
    }

    mutating func addParticipant(userID: String) {
        participants.append(userID)
    }

    mutating func removeParticipant(userID: String) {
        participants.removeAll { $0 == userID }
    }
}
