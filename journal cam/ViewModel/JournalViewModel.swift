//
//  JournalViewModel.swift
//  journal cam
//
//  Created by Dylan on 10/06/26.
//


import UIKit

@Observable
class JournalViewModel {
    var title = ""
    var content = ""
    var isSaving = false
    var errorMessage: String?
    
    var entries: [JournalEntry] = []
    var isLoading = false

    private let firestoreService = FirestoreService()

    func save(image: UIImage, userId: String) async throws {
        guard !title.isEmpty else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        try await firestoreService.saveEntry(
            image: image,
            title: title,
            note: content,
            userId: userId
        )
    }
    
    func loadEntries(userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            entries = try await firestoreService.fetchEntries(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
