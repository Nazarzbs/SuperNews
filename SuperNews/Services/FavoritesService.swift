//
//  FavoritesService.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftData
import Foundation

class FavoritesService {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addToFavorites(_ article: Article) {
        guard !isFavorite(article) else { return }
        
        let favorite = FavoriteArticle(
            title: article.title,
            articleDescription: article.description,
            url: article.url,
            urlToImage: article.urlToImage,
            publishedAt: article.publishedAt,
            author: article.author,
            sourceName: article.source.name,
            content: article.content
        )
        
        modelContext.insert(favorite)
        
        do {
            try modelContext.save()
        } catch {
            print("Помилка збереження: \(error.localizedDescription)")
        }
    }
    
    func removeFromFavorites(_ article: Article) {
        let descriptor = FetchDescriptor<FavoriteArticle>(
            predicate: #Predicate { $0.url == article.url }
        )
        
        do {
            let favorites = try modelContext.fetch(descriptor)
            favorites.forEach { modelContext.delete($0) }
            try modelContext.save()
        } catch {
            print("Помилка видалення: \(error.localizedDescription)")
        }
    }
    
    func isFavorite(_ article: Article) -> Bool {
        let descriptor = FetchDescriptor<FavoriteArticle>(
            predicate: #Predicate { $0.url == article.url }
        )
        
        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            return false
        }
    }
    
    func fetchFavorites(page: Int = 1, pageSize: Int = 20) -> [Article] {
        var descriptor = FetchDescriptor<FavoriteArticle>(
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        
        descriptor.fetchOffset = (page - 1) * pageSize
        descriptor.fetchLimit = pageSize
        
        do {
            let favorites = try modelContext.fetch(descriptor)
            return favorites.map { $0.toArticle() }
        } catch {
            print("Помилка завантаження обраного: \(error.localizedDescription)")
            return []
        }
    }
    
    func getTotalFavoritesCount() -> Int {
        let descriptor = FetchDescriptor<FavoriteArticle>()
        
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            return 0
        }
    }
}
