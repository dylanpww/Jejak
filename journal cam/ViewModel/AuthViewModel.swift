//
//  AuthService.swift
//  journal cam
//
//  Created by Dylan on 06/06/26.
//


import FirebaseAuth

@Observable
class AuthService {
    var user: User?

    init() {
        user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        user = result.user
    }

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        user = result.user
    }

    func signOut() throws {
        try Auth.auth().signOut()
        user = nil
    }
}
