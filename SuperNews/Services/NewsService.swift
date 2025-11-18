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
    
    func fetchTopHeadlines(page: Int = 1, pageSize: Int = AppConstants.defaultPageSize, category: String? = nil, country: String = AppConstants.defaultCountry) async throws -> NewsResponse {
        let cacheKey = "top-headlines-\(country)-\(category ?? "all")-\(page)-\(pageSize)"
        
        // Try to fetch from network first
        do {
            var urlString = "\(baseURL)/top-headlines?country=\(country)&page=\(page)&pageSize=\(pageSize)&apiKey=\(apiKey)"
            
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
    
    func searchNews(query: String, page: Int = 1, pageSize: Int = AppConstants.defaultPageSize) async throws -> NewsResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NewsError.invalidQuery
        }
        
        let cacheKey = "search-\(encodedQuery)-\(page)-\(pageSize)"
        
        // Try to fetch from network first
        do {
            let urlString = "\(baseURL)/everything?q=\(encodedQuery)&page=\(page)&pageSize=\(pageSize)&sortBy=publishedAt&apiKey=\(apiKey)"
            
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
    
    func getCachedTopHeadlines(page: Int = 1, pageSize: Int = AppConstants.defaultPageSize, category: String? = nil, country: String = AppConstants.defaultCountry) async -> NewsResponse? {
        let cacheKey = "top-headlines-\(country)-\(category ?? "all")-\(page)-\(pageSize)"
        return try? await cacheService.retrieve(forKey: cacheKey)
    }
    
    func getCachedSearch(query: String, page: Int = 1, pageSize: Int = AppConstants.defaultPageSize) async -> NewsResponse? {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        let cacheKey = "search-\(encodedQuery)-\(page)-\(pageSize)"
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

