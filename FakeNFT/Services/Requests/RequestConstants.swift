import Foundation

enum RequestConstants {
    static let baseURL = "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net"
    // токен приходит из Secrets.xcconfig через Info.plist
    static let token = Bundle.main.object(forInfoDictionaryKey: "PracticumToken") as? String ?? ""
}
