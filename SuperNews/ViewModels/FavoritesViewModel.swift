//
//  FavoritesViewModel.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import Foundation

@MainActor
@Observable
class FavoritesViewModel {
    var articles: [Article] = []
    var isLoading = false
    var currentPage = 1
    var hasMorePages = true
    
    private let pageSize = 20
    private let favoritesService: FavoritesService
    
    init(favoritesService: FavoritesService) {
        self.favoritesService = favoritesService
    }
    
    func loadArticles(isRefreshing: Bool = false) {
        if isRefreshing {
            currentPage = 1
        }
        
        isLoading = true
        
            let fetchedArticles = favoritesService.fetchFavorites(
                page: currentPage,
                pageSize: pageSize
            )
            
            let filteredArticles = fetchedArticles.filter { article in
                guard let urlToImage = article.urlToImage, !urlToImage.isEmpty else {
                    return false
                }
                return true
            }
            
            if isRefreshing {
                articles = filteredArticles
            } else {
                articles.append(contentsOf: filteredArticles)
            }
            
            let totalCount = favoritesService.getTotalFavoritesCount()
            hasMorePages = articles.count < totalCount
            
            isLoading = false
    }
    
    func loadMoreArticles() {
        guard !isLoading && hasMorePages else { return }
        currentPage += 1
        loadArticles()
    }
    
    func removeFavorite(_ article: Article) {
        favoritesService.removeFromFavorites(article)
        articles.removeAll { $0.url == article.url }
    }
    
    func isFavorite(_ article: Article) -> Bool {
        // В FavoritesView все статьи по определению являются избранными
        return true
    }
}

