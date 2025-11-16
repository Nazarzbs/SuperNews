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
        NavigationView {
            VStack {
                if let viewModel = viewModel {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.articles) { article in
                                if let favoritesService = favoritesService {
                                    ArticleRow(
                                        article: article,
                                        favoritesService: favoritesService,
                                        showDeleteButton: true,
                                        onDelete: {
                                            viewModel.removeFavorite(article)
                                        }
                                    )
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
                            Image(systemName: "heart.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Немає обраних новин")
                                .foregroundColor(.gray)
                                .padding(.top)
                            Spacer()
                        }
                    }
                    
                    if viewModel.isLoading && viewModel.articles.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationTitle("Обране")
            .onAppear {
                if favoritesService == nil {
                    favoritesService = FavoritesService(modelContext: modelContext)
                }
                if viewModel == nil, let favoritesService = favoritesService {
                    viewModel = FavoritesViewModel(favoritesService: favoritesService)
                }
                viewModel?.loadArticles()
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

