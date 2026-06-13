//
//  MainTabView.swift
//  journal cam
//
//  Created by Dylan on 10/06/26.
//


import SwiftUI

struct MainTabView: View {
    let userId: String
    let authService: AuthService

    var body: some View {
        TabView {
            JournalListView(userId: userId)
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
            CalendarView(userId: userId)
                            .tabItem {
                                Label("Calendar", systemImage: "calendar")
                            }

            ProfileView(authService: authService)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
