//
//  ArticleRow.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftUI

struct ArticleRow: View {
    let article: Article
    var favoritesService: FavoritesService
    var showDeleteButton: Bool = false
    var onDelete: (() -> Void)? = nil
    
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack {
                if let urlToImage = article.urlToImage, let imageURL = URL(string: urlToImage) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                            
                        case .success(let image):
                            image
                                .resizable()
                        case .failure(let error):
                            Image(systemName: "photo")
                                .font(.system(size: 140))
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    .scaledToFill()
                    .frame(width: 350, height: 200)
                    .clipped()
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(article.title)
                        .font(.headline)
                    
                    HStack {
                        
                            if !showDeleteButton {
                                Button(action: {
                                    if isFavorite {
                                        favoritesService.removeFromFavorites(article)
                                        isFavorite = false
                                    } else {
                                        favoritesService.addToFavorites(article)
                                        isFavorite = true
                                    }
                                }) {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(isFavorite ? .red : .gray)
                                }
                            }
                            
                            if showDeleteButton {
                              
                                Button(action: {
                                    favoritesService.removeFromFavorites(article)
                                    onDelete?()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        
                        
                        Spacer()
                        VStack {
                            Text(article.source.name)
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            if let publishedAt = formatDate(article.publishedAt) {
                                Text(publishedAt)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            isFavorite = favoritesService.isFavorite(article)
        }
        .onChange(of: article.url) { 
            isFavorite = favoritesService.isFavorite(article)
        }
    }
    
    private func formatDate(_ dateString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return nil }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "uk_UA")
        
        return displayFormatter.string(from: date)
    }
}

