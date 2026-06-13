//
//  JournalEntry.swift
//  journal cam
//
//  Created by Dylan on 06/06/26.
//


import FirebaseFirestore
import Foundation

struct JournalEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    var title: String
    var note: String
    var photoURL: String
    let createdAt: Date
}
