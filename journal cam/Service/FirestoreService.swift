//
//  FirestoreService.swift
//  journal cam
//
//  Created by Dylan on 06/06/26.
//


import FirebaseFirestore
import UIKit

class FirestoreService {
    private let db = Firestore.firestore()
    private let cloudinary = CloudinaryService()

    func saveEntry(image: UIImage,title: String, note: String, userId: String) async throws {
        let photoURL = try await cloudinary.uploadPhoto(image)

        let entry = JournalEntry(
            userId: userId,
            title: title,
            note: note,
            photoURL: photoURL,
            createdAt: Date()
        )

        try db.collection("users")
              .document(userId)
              .collection("entries")
              .addDocument(from: entry)
    }

    func fetchEntries(userId: String) async throws -> [JournalEntry] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("entries")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap {
            try? $0.data(as: JournalEntry.self)
        }
    }
}
