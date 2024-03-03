//
//  Traner.swift
//  Grace
//
//  Created by Эвелина Пенькова on 16.03.2024.
//

import FirebaseFirestoreSwift

struct Trainer: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var name: String
    var surname: String
    var description: String
    var profileImageUrl: String
}


