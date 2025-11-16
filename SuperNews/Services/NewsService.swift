//
//  NewsService.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import Foundation

class NewsService {
    static let shared = NewsService()
    
    private let baseURL = "https://newsapi.org/v2"
    private let apiKey = "d30476204fc74acba24fc4b9680dac1d" 
    
    private init() {}
    
    func fetchTopHeadlines(page: Int = 1, pageSize: Int = 20, category: String? = nil, country: String = "us") async throws -> NewsResponse {
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
            return try decoder.decode(NewsResponse.self, from: data)
        } catch {
            throw NewsError.decodingError
        }
    }
    
    func searchNews(query: String, page: Int = 1, pageSize: Int = 20) async throws -> NewsResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NewsError.invalidQuery
        }
        
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
            return try decoder.decode(NewsResponse.self, from: data)
        } catch {
            throw NewsError.decodingError
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

