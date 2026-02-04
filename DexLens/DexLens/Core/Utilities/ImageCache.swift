import Foundation

@MainActor
final class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: URL] = [:]

    private init() {}

    func get(imageURL: String) -> URL? {
        cache[imageURL]
    }

    func set(imageURL: URL, for coinId: String) {
        cache[coinId] = imageURL
    }
}
