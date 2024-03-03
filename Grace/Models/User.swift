//
//  User.swift
//  Grace
//
//  Created by Эвелина Пенькова on 07.02.2024.
//

import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var uid, email, name, surname, role, description: String
}
