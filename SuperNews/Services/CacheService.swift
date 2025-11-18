import Foundation

actor CacheService {

    static let shared = CacheService()

    

    private let fileManager = FileManager.default

    private let cacheDirectory: URL

    

    private init() {

        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)

        cacheDirectory = paths[0].appendingPathComponent("NewsCache")

        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

    }

    

    func cache<T: Codable>(_ data: T, forKey key: String) async throws {

        let fileURL = cacheDirectory.appendingPathComponent(key)

        let encodedData = try JSONEncoder().encode(data)

        try encodedData.write(to: fileURL)

    }

    

    func retrieve<T: Codable>(forKey key: String) async throws -> T? {

        let fileURL = cacheDirectory.appendingPathComponent(key)

        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        return try JSONDecoder().decode(T.self, from: data)

    }

    

    func clearCache() async throws {

        try fileManager.removeItem(at: cacheDirectory)

        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

    }

}

