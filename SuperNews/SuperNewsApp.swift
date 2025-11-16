//
//  SuperNewsApp.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftUI
import SwiftData

@main
struct SuperNewsApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(persistenceController.container)
        }
    }
}
