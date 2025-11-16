//
//  PersistenceController.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: ModelContainer
    
    init() {
        let schema = Schema([FavoriteArticle.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("SwiftData помилка: \(error.localizedDescription)")
        }
    }
}
