//
//  NewsDetailView.swift
//  SuperNews
//
//  Created by nazar on 30.10.2025.
//

import SwiftUI

struct NewsDetailView: View {
    let article: Article
    
    var body: some View {
        if let url = URL(string: article.url) {
            WebView(url: url)
                .ignoresSafeArea()
                .navigationTitle(Text(host(from: url)))
                .navigationBarTitleDisplayMode(.inline)
        } else {
            ContentUnavailableView("Invalid URL", systemImage: "exclamationmark.triangle")
        }
    }
    
    private func host(from url: URL) -> String {
        url.host ?? "News"
    }
}

