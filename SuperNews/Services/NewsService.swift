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
    
    private init() {}
    
    func fetchTopHeadlines(page: Int = 1, pageSize: Int? = nil, category: String? = nil, country: String? = nil) async throws -> NewsResponse {
        let resolvedPageSize: Int
        let resolvedCountry: String
        if let pageSize = pageSize, let country = country {
            resolvedPageSize = pageSize
            resolvedCountry = country
        } else {
            // Access AppConstants on the main actor to avoid isolation warnings
            resolvedPageSize = await MainActor.run { AppConstants.defaultPageSize }
            resolvedCountry = await MainActor.run { AppConstants.defaultCountry }
        }
        
        let cacheKey = "top-headlines-\(resolvedCountry)-\(category ?? "all")-\(page)-\(resolvedPageSize)"
        
        // Try to fetch from network first
        do {
            var urlString = "\(baseURL)/top-headlines?country=\(resolvedCountry)&page=\(page)&pageSize=\(resolvedPageSize)&apiKey=\(apiKey)"
            
            if let category = category {
                urlString += "&category=\(category)"
            }
            
            guard let url = URL(string: urlString) else {
                throw NewsError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NewsError.invalidResponse
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let newsResponse = try decoder.decode(NewsResponse.self, from: data)
                
                // Cache the response
                try await cacheService.cache(newsResponse, forKey: cacheKey)
                
                return newsResponse
            } catch {
                throw NewsError.decodingError
            }
        } catch {
            // If network fails, try to get from cache
            if let cachedResponse: NewsResponse = try? await cacheService.retrieve(forKey: cacheKey) {
                return cachedResponse
            }
            // If cache also fails, throw the original error
            throw error
        }
    }
    
    func searchNews(query: String, page: Int = 1, pageSize: Int? = nil) async throws -> NewsResponse {
        let resolvedPageSize: Int
        if let pageSize = pageSize {
            resolvedPageSize = pageSize
        } else {
            resolvedPageSize = await MainActor.run { AppConstants.defaultPageSize }
        }
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NewsError.invalidQuery
        }
        
        let cacheKey = "search-\(encodedQuery)-\(page)-\(resolvedPageSize)"
        
        // Try to fetch from network first
        do {
            let urlString = "\(baseURL)/everything?q=\(encodedQuery)&page=\(page)&pageSize=\(resolvedPageSize)&sortBy=publishedAt&apiKey=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                throw NewsError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NewsError.invalidResponse
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let newsResponse = try decoder.decode(NewsResponse.self, from: data)
                
                // Cache the response
                try await cacheService.cache(newsResponse, forKey: cacheKey)
                
                return newsResponse
            } catch {
                throw NewsError.decodingError
            }
        } catch {
            // If network fails, try to get from cache
            if let cachedResponse: NewsResponse = try? await cacheService.retrieve(forKey: cacheKey) {
                return cachedResponse
            }
            // If cache also fails, throw the original error
            throw error
        }
    }
    
    func getCachedTopHeadlines(page: Int = 1, pageSize: Int? = nil, category: String? = nil, country: String? = nil) async -> NewsResponse? {
        let defaultPageSize = await MainActor.run { AppConstants.defaultPageSize }
        let defaultCountry = await MainActor.run { AppConstants.defaultCountry }
        let resolvedPageSize = pageSize ?? defaultPageSize
        let resolvedCountry = country ?? defaultCountry
        let cacheKey = "top-headlines-\(resolvedCountry)-\(category ?? "all")-\(page)-\(resolvedPageSize)"
        do {
            let cached: NewsResponse? = try await cacheService.retrieve(forKey: cacheKey)
            return cached
        } catch {
            return nil
        }
    }
    
    func getCachedSearch(query: String, page: Int = 1, pageSize: Int? = nil) async -> NewsResponse? {
        let defaultPageSize = await MainActor.run { AppConstants.defaultPageSize }
        let resolvedPageSize = pageSize ?? defaultPageSize
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        let cacheKey = "search-\(encodedQuery)-\(page)-\(resolvedPageSize)"
        do {
            let cached: NewsResponse? = try await cacheService.retrieve(forKey: cacheKey)
            return cached
        } catch {
            return nil
        }
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
