//
//  NewsService.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import Foundation

class NewsService {
    static let shared = NewsService()
    
    private let baseURL = AppConstants.baseURL
    private let apiKey = AppConstants.apiKey
    private let cacheService = CacheService.shared
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private init() {}
    
    // MARK: - Generic Network Request
    
    private func performRequest(
        urlString: String,
        cacheKey: String
    ) async throws -> NewsResponse {
        do {
            guard let url = URL(string: urlString) else {
                throw NewsError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NewsError.invalidResponse
            }
            
            let newsResponse = try decoder.decode(NewsResponse.self, from: data)
            
            // Cache the response
            try await cacheService.cache(newsResponse, forKey: cacheKey)
            
            return newsResponse
        } catch _ as DecodingError {
            throw NewsError.decodingError
        } catch {
            // Fallback to cache
            if let cachedResponse: NewsResponse = try? await cacheService.retrieve(forKey: cacheKey) {
                return cachedResponse
            }
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func getDefaultPageSize() -> Int {
        AppConstants.defaultPageSize
    }
    
    @MainActor
    private func getDefaultCountry() -> String {
        AppConstants.defaultCountry
    }
    
    private func resolvePageSize(_ pageSize: Int?) async -> Int {
        if let pageSize = pageSize {
            return pageSize
        }
        return getDefaultPageSize()
    }
    
    private func resolveCountry(_ country: String?) async -> String {
        if let country = country {
            return country
        }
        return getDefaultCountry()
    }
    
    // MARK: - Public API
    
    func fetchTopHeadlines(
        page: Int = 1,
        pageSize: Int? = nil,
        category: String? = nil,
        country: String? = nil
    ) async throws -> NewsResponse {
        let resolvedPageSize = await resolvePageSize(pageSize)
        let resolvedCountry = await resolveCountry(country)
        
        let cacheKey = "top-headlines-\(resolvedCountry)-\(category ?? "all")-\(page)-\(resolvedPageSize)"
        
        var urlString = "\(baseURL)/top-headlines?country=\(resolvedCountry)&page=\(page)&pageSize=\(resolvedPageSize)&apiKey=\(apiKey)"
        
        if let category = category {
            urlString += "&category=\(category)"
        }
        
        return try await performRequest(urlString: urlString, cacheKey: cacheKey)
    }
    
    func searchNews(
        query: String,
        page: Int = 1,
        pageSize: Int? = nil
    ) async throws -> NewsResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NewsError.invalidQuery
        }
        
        let resolvedPageSize = await resolvePageSize(pageSize)
        let cacheKey = "search-\(encodedQuery)-\(page)-\(resolvedPageSize)"
        
        let urlString = "\(baseURL)/everything?q=\(encodedQuery)&page=\(page)&pageSize=\(resolvedPageSize)&sortBy=publishedAt&apiKey=\(apiKey)"
        
        return try await performRequest(urlString: urlString, cacheKey: cacheKey)
    }
    
    // MARK: - Cache Methods
    
    func getCachedTopHeadlines(
        page: Int = 1,
        pageSize: Int? = nil,
        category: String? = nil,
        country: String? = nil
    ) async -> NewsResponse? {
        let resolvedPageSize = await resolvePageSize(pageSize)
        let resolvedCountry = await resolveCountry(country)
        let cacheKey = "top-headlines-\(resolvedCountry)-\(category ?? "all")-\(page)-\(resolvedPageSize)"
        return try? await cacheService.retrieve(forKey: cacheKey)
    }
    
    func getCachedSearch(
        query: String,
        page: Int = 1,
        pageSize: Int? = nil
    ) async -> NewsResponse? {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        let resolvedPageSize = await resolvePageSize(pageSize)
        let cacheKey = "search-\(encodedQuery)-\(page)-\(resolvedPageSize)"
        return try? await cacheService.retrieve(forKey: cacheKey)
    }
}

enum NewsError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case invalidQuery
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Невірний URL"
        case .invalidResponse:
            return "Невірна відповідь від сервера"
        case .decodingError:
            return "Помилка декодування даних"
        case .invalidQuery:
            return "Невірний запит"
        }
    }
}
