//
//  CategoriesView.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @State private var viewModel = CategoriesViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var favoritesService: FavoritesService?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(
                            title: "Всі",
                            isSelected: viewModel.selectedCategory == nil,
                            action: { viewModel.selectCategory(nil) }
                        )
                        
                        ForEach(viewModel.categories, id: \.self) { category in
                            CategoryButton(
                                title: category.capitalized,
                                isSelected: viewModel.selectedCategory == category,
                                action: { viewModel.selectCategory(category) }
                            )
                            .onChange(of: viewModel.selectedCategory) {
                                Task {
                                    await viewModel.loadArticles()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemGray6))
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.articles) { article in
                            if article.urlToImage != nil {
                                NavigationLink(value: article) {
                                    ArticleRow(
                                        article: article,
                                        isFavorite: viewModel.isFavorite(article),
                                        onToggleFavorite: {
                                            viewModel.toggleFavorite(article)
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                .task {
                                    if article.id == viewModel.articles.last?.id {
                                        await viewModel.loadMoreArticles()
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
                        ContentUnavailableView("Немає новин", systemImage: "list.bullet.rectangle")
                    }
                }
                
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Категорії")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Article.self) { article in
                NewsDetailView(article: article)
            }
            .task {
                if favoritesService == nil {
                    let service = FavoritesService(modelContext: modelContext)
                    favoritesService = service
                    viewModel.setFavoritesService(service)
                }
                if viewModel.articles.isEmpty {
                    await viewModel.loadArticles()
                } else {
                    viewModel.updateFavoriteStatuses()
                }
            }
            .onChange(of: viewModel.articles) {
                viewModel.updateFavoriteStatuses()
            }
        }
    }
    
    @MainActor
    private func refreshArticles() async {
        await viewModel.loadArticles(isRefreshing: true)
        while viewModel.isLoading {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

