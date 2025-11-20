# SuperNews (SwiftUI, MVVM)

<img src="https://github.com/user-attachments/assets/a21aa68a-1945-48b9-a7bb-ae1a6c4943b6" alt="App Icon" width="120" height="120" style="margin-bottom: 10px;">  

</p>

A modern iOS news application built with SwiftUI that fetches real-time news from NewsAPI with favorites, and category filtering.

<img width="1000" alt="Group 15" src="https://github.com/user-attachments/assets/d6ca2d6a-1df7-471d-bf35-299538026198" /> 


https://github.com/user-attachments/assets/ab062dc8-1554-4ba0-af4b-7bfc30f20467


---

## Features

### Core

* **Top headlines + search** — Default feed shows top headlines; search functionality with submit button.

* **Search on Submit** — Searches are triggered when the user explicitly submits; optimized with debouncing.

* **Clear to reset** — Clearing the search resets the query and reloads the default feed.

* **Category filtering** — Browse news by categories: Business, Entertainment, General, Health, Science, Sports, and Technology.

* **Favorites** — Save articles to favorites with SwiftData persistence for offline access.

* **Offline-ready** — Disk caching with automatic fallback when requests fail.

* **Pull-to-refresh** — Refresh feed anytime via `refreshable`.

* **Infinite scroll** — Automatic pagination with lazy loading for seamless browsing.

* **Optimized images** — Custom `CachedAsyncImage` with in-memory caching, placeholders, and graceful fallbacks.

* **Image validation** — Validates image URLs before display to ensure quality content.

* **Modern UI** — `NavigationStack`, `ContentUnavailableView`, `TabView` with clear loading/error states.

* **Robust error handling** — Explicit network/decoding errors surfaced in UI with user-friendly messages.

* **SwiftData persistence** — Favorites are persisted using SwiftData for reliable offline access.

## Project Structure

```
SuperNews/
├─ SuperNewsApp.swift
├─ ContentView.swift
├─ Constants.swift
├─ Models/
│  ├─ NewsResponse.swift
│  └─ FavoriteArticle.swift
├─ Services/
│  ├─ NewsService.swift
│  ├─ CacheService.swift
│  ├─ FavoritesService.swift
│  └─ PersistenceController.swift
├─ ViewModels/
│  ├─ HomeViewModel.swift
│  ├─ CategoriesViewModel.swift
│  └─ FavoritesViewModel.swift
├─ Views/
│  ├─ HomeView.swift
│  ├─ CategoriesView.swift
│  ├─ FavoritesView.swift
│  ├─ ArticleRow.swift
│  ├─ NewsDetailView.swift
│  ├─ WebView.swift
│  └─ CachedAsyncImage.swift
└─ Assets.xcassets
```

