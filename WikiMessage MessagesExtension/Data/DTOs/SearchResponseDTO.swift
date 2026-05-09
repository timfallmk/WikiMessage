import Foundation

struct SearchResponseDTO: Decodable {
    let pages: [PageDTO]

    struct PageDTO: Decodable {
        let id: Int
        let key: String
        let title: String
        let excerpt: String?
        let description: String?
        let thumbnail: ThumbnailDTO?
    }
}
