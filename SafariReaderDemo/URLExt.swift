//
//  URLExt.swift
//  SafariReaderDemo
//
//  Created by XueyuanXiao on 2023/8/26.
//

import Foundation

extension URL {

    static var appSupportURL: URL {
        guard let url = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            fatalError()
        }
        return url
    }
    
}

