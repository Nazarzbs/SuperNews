//
//  FavoritesView.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var favoritesService: FavoritesService?
    @State private var viewModel: FavoritesViewModel?
    
    var body: some View {
        NavigationStack {
            VStack {
                if let viewModel = viewModel {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.articles) { article in
                                NavigationLink(value: article) {
                                    ArticleRow(
                                        article: article,
                                        isFavorite: viewModel.isFavorite(article),
                                        onToggleFavorite: {
                                            viewModel.removeFavorite(article)
                                        },
                                        showDeleteButton: true,
                                        onDelete: {
                                            viewModel.removeFavorite(article)
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if article.id == viewModel.articles.last?.id {
                                        viewModel.loadMoreArticles()
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
                        ContentUnavailableView("Немає обраних новин", systemImage: "heart.slash")
                    }
                    
                    if viewModel.isLoading && viewModel.articles.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationTitle("Обране")
            .navigationDestination(for: Article.self) { article in
                NewsDetailView(article: article)
            }
            .onAppear {
                if favoritesService == nil {
                    favoritesService = FavoritesService(modelContext: modelContext)
                }
                if viewModel == nil, let favoritesService = favoritesService {
                    viewModel = FavoritesViewModel(favoritesService: favoritesService)
                }
                viewModel?.loadArticles(isRefreshing: true)
            }
        }
    }
    
    @MainActor
    private func refreshArticles() async {
        viewModel?.loadArticles(isRefreshing: true)
        while viewModel?.isLoading == true {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
}

