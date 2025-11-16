//
//  FavoriteArticle.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import Foundation
import SwiftData

@Model
final class FavoriteArticle {
    var id: UUID
    var title: String
    var articleDescription: String?
    var url: String
    var urlToImage: String?
    var publishedAt: String
    var author: String?
    var sourceName: String
    var content: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        articleDescription: String? = nil,
        url: String,
        urlToImage: String? = nil,
        publishedAt: String,
        author: String? = nil,
        sourceName: String,
        content: String? = nil
    ) {
        self.id = id
        self.title = title
        self.articleDescription = articleDescription
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.author = author
        self.sourceName = sourceName
        self.content = content
    }
    
    func toArticle() -> Article {
        Article(
            source: Source(id: nil, name: sourceName),
            author: author,
            title: title,
            description: articleDescription,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            content: content
        )
    }
}

