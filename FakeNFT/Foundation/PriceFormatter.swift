import Foundation

enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func eth(_ value: Double) -> String {
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(number) ETH"
    }
}
