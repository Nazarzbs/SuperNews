//
//  CategoriesViewModel.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import Foundation

@MainActor
@Observable
class CategoriesViewModel {
    var articles: [Article] = []
    var isLoading = false
    var errorMessage: String?
    var selectedCategory: String? = nil
    var currentPage = 1
    var hasMorePages = true
    var favoriteArticleUrls: Set<String> = []
    
    let categories = AppConstants.categories
    
    private let pageSize = AppConstants.defaultPageSize
    private var favoritesService: FavoritesService?
    
    func setFavoritesService(_ service: FavoritesService) {
        self.favoritesService = service
        updateFavoriteStatuses()
    }
    
    func loadArticles(isRefreshing: Bool = false) async {
        if isRefreshing {
            currentPage = 1
            hasMorePages = true
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
       
            do {
                // Load cached data first if available and not refreshing
                if !isRefreshing && articles.isEmpty {
                    if let cachedResponse = await NewsService.shared.getCachedTopHeadlines(
                        page: currentPage,
                        pageSize: pageSize,
                        category: selectedCategory
                    ) {
                        let filteredArticles = cachedResponse.articles.filter { article in
                            guard let urlToImage = article.urlToImage, !urlToImage.isEmpty else {
                                return false
                            }
                            return true
                        }
                        articles = filteredArticles
                    }
                }
                
                let response = try await NewsService.shared.fetchTopHeadlines(
                    page: currentPage,
                    pageSize: pageSize,
                    category: selectedCategory
                )
                
                let filteredArticles = response.articles.filter { article in
                    guard let urlToImage = article.urlToImage, !urlToImage.isEmpty else {
                        return false
                    }
                    return true
                }
                
                if isRefreshing {
                    articles = filteredArticles
                } else {
                    let newArticles = filteredArticles.filter { newArticle in
                        !articles.contains { $0.url == newArticle.url }
                    }
                    articles.append(contentsOf: newArticles)
                }
                
                hasMorePages = articles.count < response.totalResults
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        
    }
    
    func loadMoreArticles() async {
        guard !isLoading && hasMorePages else { return }
        currentPage += 1
        await loadArticles()
    }
    
    func selectCategory(_ category: String?) {
        selectedCategory = category
        currentPage = 1
        hasMorePages = true
        articles = []
    }
    
    // MARK: - Favorites Management
    
    func isFavorite(_ article: Article) -> Bool {
        favoriteArticleUrls.contains(article.url)
    }
    
    func toggleFavorite(_ article: Article) {
        guard let favoritesService = favoritesService else { return }
        
        if isFavorite(article) {
            favoritesService.removeFromFavorites(article)
            favoriteArticleUrls.remove(article.url)
        } else {
            favoritesService.addToFavorites(article)
            favoriteArticleUrls.insert(article.url)
        }
    }
    
    func updateFavoriteStatuses() {
        guard let favoritesService = favoritesService else { return }
        favoriteArticleUrls = Set(articles.filter { favoritesService.isFavorite($0) }.map { $0.url })
    }
}

