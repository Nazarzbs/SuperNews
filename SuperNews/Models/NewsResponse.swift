//
//  NewsResponse.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt, content
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

struct Source: Codable, Equatable {
    let id: String?
    let name: String
}

