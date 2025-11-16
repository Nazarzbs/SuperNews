//
//  ContentView.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Головна", systemImage: "house.fill")
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    Label("Категорії", systemImage: "list.bullet")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Label("Обране", systemImage: "heart.fill")
                }
                .tag(2)
        }
    }
}
