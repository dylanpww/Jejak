//
//  ProfileView.swift
//  journal cam
//
//  Created by Dylan on 10/06/26.
//


import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    let authService: AuthService

    var body: some View {
        NavigationStack {
            ZStack{
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.08, blue: 0.18),
                        Color(red: 0.10, green: 0.16, blue: 0.32)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                List {
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authService.user?.email ?? "Anonymous")
                                    .font(.headline)
                                Text("Journal Cam member")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section("Account") {
                        Button(role: .destructive) {
                            try? authService.signOut()
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                        
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Profile")
            }
        }
    }
}
