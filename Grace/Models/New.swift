//
//  News.swift
//  Grace
//
//  Created by Эвелина Пенькова on 02.04.2024.
//

import FirebaseFirestoreSwift
import Foundation

struct New: Identifiable, Codable {
    var id = UUID()
    var uid: String
    var name: String
    var description: String
    var profileImageUrl: String
    var creationDate: Date
}
