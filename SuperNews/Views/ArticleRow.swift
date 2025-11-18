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
        VStack(alignment: .leading, spacing: 0) {
            // Image Section with Gradient Overlay
            ZStack(alignment: .topTrailing) {
                if let urlToImage = article.urlToImage, let imageURL = URL(string: urlToImage) {
                    CachedAsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 32, height: 220)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(.systemGray6), Color(.systemGray5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: UIScreen.main.bounds.width - 32, height: 220)
                            .overlay(
                                ProgressView()
                                    .tint(.gray)
                            )
                    }
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: UIScreen.main.bounds.width - 32, height: 220)
                        .overlay(
                            Image(systemName: "newspaper.fill")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(.gray.opacity(0.4))
                        )
                }
                
                // Source Badge
                HStack {
                    Text(article.source.name)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                }
                .padding([.top, .trailing], 12)
            }
            
            // Content Section
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(article.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Footer Section
                HStack(alignment: .center, spacing: 12) {
                    // Date
                    if let publishedAt = formatDate(article.publishedAt) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(publishedAt)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        if !showDeleteButton {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    if isFavorite {
                                        favoritesService.removeFromFavorites(article)
                                        isFavorite = false
                                    } else {
                                        favoritesService.addToFavorites(article)
                                        isFavorite = true
                                    }
                                }
                            }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(isFavorite ? .red : .gray)
                                    .scaleEffect(isFavorite ? 1.1 : 1.0)
                            }
                        }
                        
                        if showDeleteButton {
                            Button(action: {
                                withAnimation {
                                    favoritesService.removeFromFavorites(article)
                                    onDelete?()
                                }
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color.red)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
        .padding(.horizontal)
        .padding(.vertical, 6)
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
