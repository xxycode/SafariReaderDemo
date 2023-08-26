//
//  ReaderFont.swift
//  SafariReaderDemo
//
//  Created by XueyuanXiao on 2023/8/26.
//

// zh-Hans System, Songti SC, Kaiti SC, Yuanti SC
// en-US Athelas, Charter, Georgia, Iowan Old Style, Seravek, Times New Roman

import Foundation

struct ReaderFont {

    let familyName: String

    let displayName: String

    let fileName: String?

    // zh-Hans
    static let pingfangSC = ReaderFont(familyName: "PingFang SC", displayName: "苹方", fileName: nil)

    static let songtiSC = ReaderFont(familyName: "Songti SC", displayName: "宋体", fileName: "Songti-SC.ttf")

    static let kaitiSC = ReaderFont(familyName: "Kaiti SC", displayName: "楷体", fileName: "Kaiti-SC.ttf")

    static let yuantiSC = ReaderFont(familyName: "Yuanti SC", displayName: "圆体", fileName: "Yuanti-SC.ttf")

    // zh-Hant
    static let pingfangTC = ReaderFont(familyName: "PingFang TC", displayName: "蘋方", fileName: nil)

    static let songtiTC = ReaderFont(familyName: "Songti TC", displayName: "宋體", fileName: "Songti-TC.ttf")

    static let kaitiTC = ReaderFont(familyName: "Kaiti TC", displayName: "楷體", fileName: "Kaiti-TC.ttf")

    static let yuantiTC = ReaderFont(familyName: "Yuanti TC", displayName: "圓體", fileName: "Yuanti-TC.ttf")

    // ja
    static let kaku = ReaderFont(familyName: "Hiragino Kaku Gothic ProN", displayName: "ヒラギノ角ゴ", fileName: "Hiragino-Kaku-Gothic-ProN.otf")

    static let sans = ReaderFont(familyName: "Hiragino Sans W3", displayName: "ヒラギノ角ゴシック", fileName: "Hiragino-Sans-GB-W3.otf")

    static let maru = ReaderFont(familyName: "Hiragino Maru Gothic ProN", displayName: "ヒラギノ丸ゴ", fileName: "Hiragino-Maru-Gothic-ProN.otf")

    static let mincho = ReaderFont(familyName: "Hiragino Mincho ProN", displayName: "ヒラギノ明朝", fileName: "Hiragino-Mincho-ProN.otf")

    // en
    static let athelas = ReaderFont(familyName: "Athelas", displayName: "Athelas", fileName: nil)

    static let charter = ReaderFont(familyName: "Charter", displayName: "Charter", fileName: nil)

    static let georgia = ReaderFont(familyName: "Georgia", displayName: "Georgia", fileName: nil)

    static let iowan = ReaderFont(familyName: "Iowan Old Style", displayName: "Iowan", fileName: nil)

    static let systemSerif = ReaderFont(familyName: "System Serif", displayName: "New York", fileName: nil)

    static let palatino = ReaderFont(familyName: "Palatino", displayName: "Palatino", fileName: nil)

    static let systemEn = ReaderFont(familyName: "System", displayName: "System", fileName: nil)

    static let seravek = ReaderFont(familyName: "Seravek", displayName: "Seravek", fileName: nil)

    static let timesNewRomanEn = ReaderFont(familyName: "Times New Roman", displayName: "Times New Roman", fileName: nil)

    // ar
    static let systemAr = ReaderFont(familyName: "System", displayName: "سان فرانسيسكو", fileName: nil)

    static let myriadArabic = ReaderFont(familyName: "Myriad Arabic", displayName: "Myriad عربي", fileName: "Myriad-Arabic.ttf")

    static let damascus = ReaderFont(familyName: "Damascus", displayName: "دمشق عادي", fileName: nil)
    
    static let timesNewRomanAr = ReaderFont(familyName: "Times New Roman", displayName: "تايمز نيو رومان", fileName: nil)

    // ko
    static let appleSDNeo = ReaderFont(familyName: "Apple SD Gothic Neo", displayName: "산돌고딕 Neo", fileName: nil)

    static let nanumGothic = ReaderFont(familyName: "Nanum Gothic", displayName: "나눔고딕", fileName: "NanumGothic.ttf")

    static let nanumMyeongjo = ReaderFont(familyName: "Nanum Myeongjo", displayName: "나눔명조", fileName: "NanumMyeongjo.ttf")
}
