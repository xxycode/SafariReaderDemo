//
//  ReaderConfiguration.swift
//  SafariReaderDemo
//
//  Created by XueyuanXiao on 2023/8/26.
//

import Foundation

extension ReaderConfiguration {

    enum Theme: String {

        case white = "White"

        case night = "Night"

        case sepia = "Sepia"

        case gray = "Gray"

    }

    private struct Constants {
        static let DefaultFontFamilyNameForLanguage = [
            "lo": "Lao Sangam MN",
            "chr": "Plantagenet Cherokee",
            "iu-Cans": "Euphemia UCAS",
            "pa-Guru": "Mukta Mahee",
            "he": "Arial Hebrew",
            "km": "Khmer Sangam MN",
            "bn": "Kohinoor Bangla",
            "or": "Noto Sans Oriya",
            "te": "Kohinoor Telugu",
            "kn": "Noto Sans Kannada",
            "my": "Noto Sans Myanmar",
            "ur": "Noto Nastaliq Urdu",
            "ja": "Hiragino Maru Gothic ProN",
            "ko": "Apple SD Gothic Neo",
            "si": "Sinhala Sangam MN",
            "zh-Hans": "PingFang SC",
            "zh-Hant": "PingFang TC",
            "hy": "Mshtakan",
            "th": "Thonburi",
            "hi": "Kohinoor Devanagari",
            "ml": "Malayalam Sangam MN",
            "am": "Kefa",
            "ta": "Tamil Sangam MN",
            "gu": "Kohinoor Gujarati"
        ]
    }

}

class ReaderConfiguration {

    private var fontFamilyNameForLanguageTag: [String: String]

    var fontSize: Int

    var isOLEDDisplay = false

    var theme: Theme

    var jsJSON: String {
        let dictionary: [String: Any] = [
            "defaultFontFamilyNameForLanguage": Constants.DefaultFontFamilyNameForLanguage,
            "fontSizeIndex": fontSize,
            "isOLEDDisplay": isOLEDDisplay,
            "themeName": theme.rawValue,
            "fontFamilyNameForLanguageTag": fontFamilyNameForLanguageTag
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            fatalError()
        }
        return jsonString.urlEncoded()
    }

    var dictionaryValue: [String: Any] {
        [
            "fontSizeIndex": fontSize,
            "themeName": theme.rawValue,
            "fontFamilyNameForLanguageTag": fontFamilyNameForLanguageTag
        ]
    }

    convenience init() {
        self.init(fontSizeIndex: 6, theme: .white, fontFamilyNameForLanguageTag: [:])
    }

    init(fontSizeIndex: Int, theme: Theme, fontFamilyNameForLanguageTag: [String: String]) {
        self.fontSize = fontSizeIndex
        self.theme = theme
        self.fontFamilyNameForLanguageTag = fontFamilyNameForLanguageTag
    }

    convenience init?(dictionary: [String: Any]) {
        guard let fontSizeIndex = dictionary["fontSizeIndex"] as? Int,
              let themeName = dictionary["themeName"] as? String,
              let theme = Theme(rawValue: themeName),
              let fontFamilyNameForLanguageTag = dictionary["fontFamilyNameForLanguageTag"] as? [String: String] else {
            return nil
        }
        self.init(fontSizeIndex: fontSizeIndex, theme: theme, fontFamilyNameForLanguageTag: fontFamilyNameForLanguageTag)
    }

    func setFont(_ font: ReaderFont?, for locale: String) {
        fontFamilyNameForLanguageTag[locale] = font?.familyName
    }

}
