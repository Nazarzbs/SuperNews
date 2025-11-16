//
//  HomeView.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var favoritesService: FavoritesService?
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText, onSearchButtonClicked: {
                    viewModel.searchArticles()
                })
                .padding(.horizontal)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.articles) { article in
                            if let favoritesService = favoritesService {
                                ArticleRow(article: article, favoritesService: favoritesService)
                                    .onAppear {
                                        if article.id == viewModel.articles.last?.id {
                                            viewModel.loadMoreArticles()
                                        }
                                    }
                            }
                        }
                        
                        if viewModel.isLoading && !viewModel.articles.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await refreshArticles()
                }
                
                if viewModel.articles.isEmpty && !viewModel.isLoading {
                    VStack {
                        Image(systemName: "newspaper")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Немає новин")
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Головна")
            .onAppear {
                if favoritesService == nil {
                    favoritesService = FavoritesService(modelContext: modelContext)
                }
                if viewModel.articles.isEmpty {
                    viewModel.loadArticles()
                }
            }
        }
    }
    
    @MainActor
    private func refreshArticles() async {
        viewModel.loadArticles(isRefreshing: true)
        while viewModel.isLoading {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Пошук новин...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            Button(action: onSearchButtonClicked) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
            }
        }
    }
}

