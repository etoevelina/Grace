//
//  Rewiew.swift
//  Grace
//
//  Created by Эвелина Пенькова on 01.05.2024.
//

import Foundation
import FirebaseFirestoreSwift

struct Review: Codable, Identifiable {
    @DocumentID var id: String?
    var text: String
    var rating: Int
    var date: Date
    var trainerName: String
    var trainerSurname: String
    var userFullName: String
    static func == (lhs: Review, rhs: Review) -> Bool {
            return lhs.id == rhs.id
        }
}
