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
    
    func deleteEntry(_ entry: JournalEntry, userId: String) async {
        guard let entryId = entry.id else { return }
        do {
            try await firestoreService.deleteEntry(entryId: entryId, userId: userId)
            await loadEntries(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateEntry(_ entry: JournalEntry, title: String, note: String, userId: String) async {
        guard let entryId = entry.id else { return }
        do {
            try await firestoreService.updateEntry(entryId: entryId, userId: userId, title: title, note: note)
            await loadEntries(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
