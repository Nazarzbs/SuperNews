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
    
    let categories = ["business", "entertainment", "general", "health", "science", "sports", "technology"]
    
    private let pageSize = 20
    
    func loadArticles(isRefreshing: Bool = false) {
        if isRefreshing {
            currentPage = 1
            hasMorePages = true
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
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
    }
    
    func loadMoreArticles() {
        guard !isLoading && hasMorePages else { return }
        currentPage += 1
        loadArticles()
    }
    
    func selectCategory(_ category: String?) {
        selectedCategory = category
        currentPage = 1
        hasMorePages = true
        articles = []
        loadArticles()
    }
}

