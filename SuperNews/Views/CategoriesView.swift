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
        NavigationView {
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
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemGray6))
                
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
                        Image(systemName: "list.bullet.rectangle")
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
            .navigationTitle("Категорії")
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

