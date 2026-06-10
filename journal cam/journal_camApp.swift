//
//  journal_camApp.swift
//  journal cam
//
//  Created by Dylan on 06/06/26.
//

import SwiftUI
import FirebaseCore

@main
struct journal_camApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
