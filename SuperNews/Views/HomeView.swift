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
        NavigationStack {
            VStack {
                SearchBar(text: $viewModel.searchText, onSearchButtonClicked: {
                    viewModel.searchArticles()
                })
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.articles) { article in
                            if article.urlToImage != nil {
                                if let favoritesService = favoritesService {
                                    NavigationLink(value: article) {
                                        ArticleRow(article: article, favoritesService: favoritesService)
                                    }
                                    .buttonStyle(.plain)
                                    .onAppear {
                                        if article.id == viewModel.articles.last?.id {
                                            viewModel.loadMoreArticles()
                                        }
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
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                .background(Color(.systemGroupedBackground))
                .refreshable {
                    await refreshArticles()
                }
                
                if viewModel.articles.isEmpty && !viewModel.isLoading {
                    if let errorMessage = viewModel.errorMessage {
                        ContentUnavailableView(errorMessage, systemImage: "wifi.slash")
                    } else {
                        ContentUnavailableView("Немає новин", systemImage: "newspaper")
                    }
                }
                
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Головна")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Article.self) { article in
                NewsDetailView(article: article)
            }
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
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                TextField("Пошук новин...", text: $text)
                    .font(.system(size: 16))
                    .onSubmit {
                        onSearchButtonClicked()
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
    }
}
