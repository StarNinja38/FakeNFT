import Foundation

struct NftCollection: Decodable {
    let id: String
    let name: String
    let cover: String
    let nfts: [String]
    let description: String
    let author: String
    let website: String

    var coverURL: URL? { URL(string: cover) }
}
