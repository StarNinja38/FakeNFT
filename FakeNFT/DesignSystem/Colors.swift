import UIKit

extension UIColor {
    // Creates color from a hex string
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }

    private static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        }
    }

    // MARK: - Палитра из макета

    static let ypBlack = dynamic(light: UIColor(hexString: "1A1B22"), dark: .white)
    static let ypWhite = dynamic(light: .white, dark: UIColor(hexString: "1A1B22"))
    static let ypLightGrey = dynamic(light: UIColor(hexString: "F7F7F8"), dark: UIColor(hexString: "2C2C2E"))
    static let ypGrey = UIColor(hexString: "625C5C")
    static let ypRed = UIColor(hexString: "F56B6C")
    static let ypGreen = UIColor(hexString: "1C9F00")
    static let ypBlue = UIColor(hexString: "0A84FF")
    static let ypYellow = UIColor(hexString: "FEEF0D")

    static let segmentActive = ypBlack
    static let segmentInactive = ypLightGrey
    static let closeButton = ypBlack
}
