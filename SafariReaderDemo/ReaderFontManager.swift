//
//  ReaderFontManager.swift
//  SafariReaderDemo
//
//  Created by XueyuanXiao on 2023/8/26.
//

import Foundation

private struct Constants {

    static let DownloadEndpoint = URL(string: "https://cdn.jsdelivr.net/gh/xxycode/ReaderFonts@main")!

    static let FontFolderName = "ReaderFonts"
    
}

class ReaderFontManager {

    private let fileRootURL: URL

    init() {
        let appSupport = URL.appSupportURL
        let root = appSupport.appendingPathComponent(Constants.FontFolderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: root.path) {
            try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        }
        fileRootURL = root
    }

    func fontExists(_ font: ReaderFont) -> Bool {
        guard let fileName = font.fileName else {
            return true
        }
        let fileURL = fileRootURL.appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    func fonts(for language: String) -> [ReaderFont] {
        if language.lowercased() == "zh-hans" {
            return [.pingfangSC, .songtiSC, .kaitiSC, .yuantiSC]
        } else if language.lowercased() == "zh-hans" {
            return [.pingfangTC, .songtiTC, .kaitiTC, .yuantiTC]
        } else if language.lowercased() == "ar" {
            return [.systemAr, .myriadArabic, .damascus, .timesNewRomanAr]
        } else if language.lowercased() == "ja" {
            return [.kaku, .sans, .maru, .mincho]
        } else if language.lowercased() == "ko" {
            return [.appleSDNeo, .nanumGothic, .nanumMyeongjo]
        }
        return [.athelas, .charter, .georgia, .iowan, .systemSerif, .palatino, .systemEn, .seravek, .timesNewRomanEn]
    }

    func font(with fileName: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let fileURL = fileRootURL.appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            guard let data = try? Data(contentsOf: fileURL) else {
                completion(.failure(NSError(domain: "reader.font", code: -1)))
                return
            }
            completion(.success(data))
        } else {
            let fontCDNURL = Constants.DownloadEndpoint.appendingPathComponent(fileName)
            URLSession.shared.dataTask(with: URLRequest(url: fontCDNURL), completionHandler: { data, _, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let data else {
                    completion(.failure(NSError(domain: "reader.font", code: -1)))
                    return
                }
                try? data.write(to: fileURL)
                completion(.success(data))
            }).resume()
        }
    }
    
}
