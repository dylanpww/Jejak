//
//  ContentView.swift
//  journal cam
//
//  Created by Dylan on 06/06/26.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var authService = AuthService()

    var body: some View {
        Group {
            if let user = authService.user {
                MainTabView(userId: user.uid, authService: authService)
            } else {
                LoginView(authService: authService)
            }
        }
    }
}
#Preview {
    ContentView()
}
