//
//  ReaderManager.swift
//  SafariReaderDemo
//
//  Created by XueyuanXiao on 2023/8/27.
//

import Foundation

class ReaderManager {

    private let configuration = ReaderConfiguration()

    private let fontManager = ReaderFontManager()

    var fontSize: Int {
        get {
            configuration.fontSize
        }
        set {
            configuration.fontSize = newValue
        }
    }

    var theme: ReaderConfiguration.Theme {
        get {
            configuration.theme
        }
        set {
            configuration.theme = newValue
        }
    }

    var configurationJSJson: String {
        configuration.jsJSON
    }

    private lazy var sharedUIJS: String = {
        guard let url = Bundle.main.url(forResource: "ReaderSharedUI", withExtension: "js"),
              let js = try? String(contentsOf: url) else {
            fatalError()
        }
        return js
    }()

    private var articleCache: [String: FinderResult] = [:]

    private(set) var readerConfiguration = ReaderConfiguration()

    static let shared = ReaderManager()

    private init() {

    }

    func set(article: FinderResult, for url: String) {
        articleCache[url] = article
    }

    func getArticle(with url: String) -> FinderResult? {
        articleCache[url]
    }

    func getHtmlString(for article: FinderResult, url: String) -> String {
        let readerURL = Bundle.main.url(forResource: "Reader", withExtension: "html")!
        var readerHtml = try! String(contentsOf: readerURL)
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_BASE_URL}}", with: url)
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ROOT}}", with: "reader://home")
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_TITLE}}", with: article.title.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_CONTENT}}", with: article.adoptableArticle)
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_CONTENTDOCUMENT}}", with: article.contentDocument.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_SUBHEAD}}", with: article.subhead.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_NODE}}", with: article.articleNode.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_ROUTE_NODE}}", with: article.routeToArticleNode.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ADOPTABLE_ARTICLE}}", with: article.adoptableArticle.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_DOC_URL_STRING}}", with: url.urlEncoded())

        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_CONTENTDOCUMENT}}", with: article.article.contentDocument.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_DEPTH}}", with: "\(article.article.depthInDocument)")
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_ELEMENT}}", with: article.article.element.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_LSM}}", with: "\(article.article.languageScoreMultiplier)")
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_RS}}", with: "\(article.article.rawScore)")
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_TAM}}", with: "\(article.article.tagNameAndAttributesScoreMultiplier)")

        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_LOCALE}}", with: article.langCode)
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_TITLE_INFORMATION}}", with: article.articleTitleInformation.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ADOPTABLE_METADATA}}", with: article.adoptableMetadataBlock.urlEncoded())
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_ARTICLE_LTR}}", with: "\(article.articleIsLTR ? "true":"false")")

        readerHtml = readerHtml.replacingOccurrences(of: "{{UI_JS}}", with: sharedUIJS)
        readerHtml = readerHtml.replacingOccurrences(of: "{{READER_CONFIG}}", with: readerConfiguration.jsJSON)
        return readerHtml
    }

    func font(with fileName: String, completion: @escaping (Result<Data, Error>) -> Void) {
        fontManager.font(with: fileName, completion: completion)
    }

    func setFont(_ font: ReaderFont?, for locale: String) {
        configuration.setFont(font, for: locale)
    }
    
}
