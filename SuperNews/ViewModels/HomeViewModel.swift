//
//  HomeViewModel.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import Foundation

@MainActor
@Observable
class HomeViewModel {
    var articles: [Article] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var currentPage = 1
    var hasMorePages = true

    private let pageSize = AppConstants.defaultPageSize
    private var searchTask: Task<Void, Never>?
    
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
                    let cachedResponse: NewsResponse?
                    if searchText.isEmpty {
                        cachedResponse = await NewsService.shared.getCachedTopHeadlines(
                            page: currentPage,
                            pageSize: pageSize
                        )
                    } else {
                        cachedResponse = await NewsService.shared.getCachedSearch(
                            query: searchText,
                            page: currentPage,
                            pageSize: pageSize
                        )
                    }
                    
                    if let cachedResponse = cachedResponse {
                        var filteredArticles: [Article] = []
                        for article in cachedResponse.articles {
                            guard let url = article.urlToImage, !url.isEmpty else { continue }
                            let isValid = await validateImageURL(url)
                            if isValid {
                                filteredArticles.append(article)
                            }
                        }
                        articles = filteredArticles
                    }
                }
                
                let response: NewsResponse
                
                if searchText.isEmpty {
                    response = try await NewsService.shared.fetchTopHeadlines(
                        page: currentPage,
                        pageSize: pageSize
                    )
                } else {
                    response = try await NewsService.shared.searchNews(
                        query: searchText,
                        page: currentPage,
                        pageSize: pageSize
                    )
                }
                
                var filteredArticles: [Article] = []
                
                for article in response.articles {
                    // є URL картинки?
                    guard let url = article.urlToImage, !url.isEmpty else { continue }

                    // перевіряємо чи реально існує
                    let isValid = await validateImageURL(url)
                    if isValid {
                        filteredArticles.append(article)
                    }
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
    
    func searchArticles() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            if !Task.isCancelled {
                currentPage = 1
                hasMorePages = true
                articles = []
                await loadArticles()
            }
        }
    }
    
    func validateImageURL(_ urlString: String?) async -> Bool {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"   // швидше ніж качати все зображення

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                return http.statusCode == 200
            }
        } catch {
            return false
        }

        return false
    }

}

