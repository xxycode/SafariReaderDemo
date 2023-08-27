//
//  ViewController.swift
//  SafariReaderDemo
//
//  Created by Xueyuan Xiao on 2023/8/25.
//

import UIKit
import WebKit
import NaturalLanguage

extension String {
    func urlEncoded() -> String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

struct Article {

    let contentDocument: String
    let depthInDocument: Int
    let element: String
    let languageScoreMultiplier: Float
    let rawScore: Float
    let tagNameAndAttributesScoreMultiplier: Float

    init(contentDocument: String, depthInDocument: Int, element: String, languageScoreMultiplier: Float, rawScore: Float, tagNameAndAttributesScoreMultiplier: Float) {
        self.contentDocument = contentDocument
        self.depthInDocument = depthInDocument
        self.element = element
        self.languageScoreMultiplier = languageScoreMultiplier
        self.rawScore = rawScore
        self.tagNameAndAttributesScoreMultiplier = tagNameAndAttributesScoreMultiplier
    }

    init?(dictionary: [String: Any]) {
        guard let contentDocument = dictionary["contentDocument"] as? String,
              let depthInDocument = dictionary["depthInDocument"] as? Int,
              let element = dictionary["element"] as? String,
              let languageScoreMultiplier = dictionary["languageScoreMultiplier"] as? Float,
              let rawScore = dictionary["rawScore"] as? Double,
              let tagNameAndAttributesScoreMultiplier = dictionary["tagNameAndAttributesScoreMultiplier"] as? Float else {
            return nil
        }
        self.init(contentDocument: contentDocument, depthInDocument: depthInDocument, element: element, languageScoreMultiplier: languageScoreMultiplier, rawScore: Float(rawScore), tagNameAndAttributesScoreMultiplier: tagNameAndAttributesScoreMultiplier)
    }

}

struct FinderResult {
    let title: String
    let content: String
    let subhead: String
    let contentDocument: String
    let adoptableArticle: String
    let article: Article
    let articleNode: String
    let routeToArticleNode: String
    let articleTitleInformation: String
    let adoptableMetadataBlock: String
    let articleIsLTR: Bool
    let articleTextContent: String

    private(set) var langCode = ""

    init(title: String, content: String, subhead: String, contentDocument: String, adoptableArticle: String, article: Article, articleNode: String, routeToArticleNode: String, articleTitleInformation: String, adoptableMetadataBlock: String, articleIsLTR: Bool, articleTextContent: String) {
        self.title = title
        self.content = content
        self.subhead = subhead
        self.contentDocument = contentDocument
        self.adoptableArticle = adoptableArticle
        self.article = article
        self.articleNode = articleNode
        self.routeToArticleNode = routeToArticleNode
        self.articleTitleInformation = articleTitleInformation
        self.adoptableMetadataBlock = adoptableMetadataBlock
        self.articleIsLTR = articleIsLTR
        self.articleTextContent = articleTextContent

        let recognizer = NLLanguageRecognizer()
        let content = articleTextContent.replacingOccurrences(of: "\n", with: "")
        recognizer.processString(content)
        langCode = recognizer.dominantLanguage?.rawValue ?? ""
    }

    init?(dictionary: [String: Any]) {
        guard let title = dictionary["title"] as? String,
              let content = dictionary["content"] as? String,
              let subhead = dictionary["subhead"] as? String,
              let contentDocument = dictionary["contentDocument"] as? String,
              let adoptableArticle = dictionary["adoptableArticle"] as? String,
              let routeToArticleNode = dictionary["routeToArticleNode"] as? String,
              let articleTitleInformation = dictionary["articleTitleInformation"] as? String,
              let adoptableMetadataBlock = dictionary["adoptableMetadataBlock"] as? String,
              let articleTextContent = dictionary["articleTextContent"] as? String,
              let articleIsLTR = dictionary["articleIsLTR"] as? Bool,
              let articleNode = dictionary["articleNode"] as? String,
              let articleDictionary = dictionary["article"] as? [String: Any],
              let article = Article(dictionary: articleDictionary) else {
            return nil
        }
        self.init(title: title, content: content, subhead: subhead, contentDocument: contentDocument, adoptableArticle: adoptableArticle, article: article, articleNode: articleNode, routeToArticleNode: routeToArticleNode, articleTitleInformation: articleTitleInformation, adoptableMetadataBlock: adoptableMetadataBlock, articleIsLTR: articleIsLTR, articleTextContent: articleTextContent)
    }
}

extension URLComponents {
    // Return the first query parameter that matches
    func valueForQuery(_ param: String) -> String? {
        return self.queryItems?.first { $0.name == param }?.value
    }
}

// font size 0~11
/**
 var e = {"defaultFontFamilyNameForLanguage":{"lo":"Lao Sangam MN","chr":"Plantagenet Cherokee","iu-Cans":"Euphemia UCAS","pa-Guru":"Mukta Mahee","he":"Arial Hebrew","km":"Khmer Sangam MN","bn":"Kohinoor Bangla","or":"Noto Sans Oriya","te":"Kohinoor Telugu","kn":"Noto Sans Kannada","my":"Noto Sans Myanmar","ur":"Noto Nastaliq Urdu","ja":"Hiragino Maru Gothic ProN","ko":"Apple SD Gothic Neo","si":"Sinhala Sangam MN","zh-Hans":"PingFang SC","zh-Hant":"PingFang TC","hy":"Mshtakan","th":"Thonburi","hi":"Kohinoor Devanagari","ml":"Malayalam Sangam MN","am":"Kefa","ta":"Tamil Sangam MN","gu":"Kohinoor Gujarati"},"javaScriptEnabled":true,"fontFamilyNameForLanguageTag":{},"fontSizeIndex":6,"isOLEDDisplay":false,"themeName":"Sepia"}
 setConfiguration(e);
 */
class ViewController: UIViewController {

    @IBOutlet weak var webViewContainer: UIView!

    @IBOutlet var locationBar: UITextField!

    @IBOutlet weak var readerButton: UIBarButtonItem!

    private var articleFinderJS: String {
        guard let url = Bundle.main.url(forResource: "ReaderArticleFinder", withExtension: "js"),
              let js = try? String(contentsOf: url) else {
            fatalError()
        }
        return js
    }

    private var sharedUIJS: String {
        guard let url = Bundle.main.url(forResource: "ReaderSharedUI", withExtension: "js"),
              let js = try? String(contentsOf: url) else {
            fatalError()
        }
        return js
    }

    private var polyfillJS: String {
        guard let url = Bundle.main.url(forResource: "ReaderPolyfill", withExtension: "js"),
              let js = try? String(contentsOf: url) else {
            fatalError()
        }
        return js
    }

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController.addUserScript(WKUserScript(source: articleFinderJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true, in: .defaultClient))
        config.setURLSchemeHandler(self, forURLScheme: "reader")
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.isInspectable = true
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let urls = [
            "https://juejin.cn/post/7227258137765953597?searchId=20230825210632235FE757A9137ABAC1C5",
            "https://mp.weixin.qq.com/s/xdCNYTl64_kDrBzwFamGEw",
            "https://www.zdnet.com/home-and-office/work-life/how-to-enable-and-use-google-chromes-reading-mode/",
            "https://news.yahoo.co.jp/articles/82c9ea1eb7c723aad3d41cc283f7669e413ca702",
            "https://nabulsi.com/story/El-poder-del-intelecto-necesita-un-mundo-interno-y-otro-externo11576"
        ]
        locationBar.text = urls[0]
        ReaderManager.shared.readerConfiguration.setFont(.songtiSC, for: "zh-Hans")
        ReaderManager.shared.readerConfiguration.theme = .sepia
        ReaderManager.shared.readerConfiguration.fontSize = 3
        webView.frame = webViewContainer.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webViewContainer.addSubview(webView)
        loadRequest()
    }

    @IBAction func goBack(_ sender: Any) {
        webView.goBack()
    }

    @IBAction func goForward(_ sender: Any) {
        webView.goForward()
    }

    @IBAction func refresh(_ sender: Any) {
        webView.reload()
    }

    @IBAction func reader(_ sender: Any) {
        let script = """
        function extArticle() {
            var articleNode = ReaderArticleFinderJS.articleNode();
            var articleTitle = ReaderArticleFinderJS.articleTitle();
            var articleContent = ReaderArticleFinderJS.article.element.outerHTML;
            var subhead = ReaderArticleFinderJS.articleSubhead() || '';
            var contentDocument = ReaderArticleFinderJS.contentDocument.documentElement.outerHTML;
            var articleNodeString = articleNode.outerHTML;
            var adoptableArticle = ReaderArticleFinderJS.adoptableArticle().outerHTML;
            var article = ReaderArticleFinderJS.article;
            var routeToArticleNode = JSON.stringify(ReaderArticleFinderJS.routeToArticleNode());
            var articleTitleInformation = JSON.stringify(ReaderArticleFinderJS.articleTitleInformation());
            var adoptableMetadataBlock = "";
            if (ReaderArticleFinderJS.adoptableMetadataBlock() != null) {
                adoptableMetadataBlock = ReaderArticleFinderJS.adoptableMetadataBlock().outerHTML
            }
            var articleIsLTR = ReaderArticleFinderJS.articleIsLTR();
            var articleTextContent = ReaderArticleFinderJS.articleTextContent();
            var articleInfo = {
                'contentDocument': article.contentDocument.documentElement.outerHTML,
                'depthInDocument': article.depthInDocument,
                'element': article.element.outerHTML,
                'languageScoreMultiplier': article.languageScoreMultiplier,
                'rawScore': article.rawScore,
                'tagNameAndAttributesScoreMultiplier': article.tagNameAndAttributesScoreMultiplier,
            };
            return {'title': articleTitle, 'content': articleContent, 'subhead': subhead, 'articleNode': articleNodeString, 'contentDocument': contentDocument, 'adoptableArticle': adoptableArticle, 'article': articleInfo, 'routeToArticleNode': routeToArticleNode, 'articleTitleInformation': articleTitleInformation, 'adoptableMetadataBlock': adoptableMetadataBlock, 'articleIsLTR': articleIsLTR, 'articleTextContent': articleTextContent};
        }
        extArticle();
"""
        webView.evaluateJavaScript(script, in: nil, in: .defaultClient) { result in
            guard let url = self.webView.url?.absoluteString,
                  let finderResultDictionary = (try? result.get()) as? [String: Any],
                  let finderResult = FinderResult(dictionary: finderResultDictionary) else {
                return
            }
            ReaderManager.shared.set(article: finderResult, for: url)
            guard let articleURL = URL(string: "reader://home/index?url=\(url)") else {
                return
            }
            self.webView.load(URLRequest(url: articleURL))
        }
    }
    @IBAction func setting(_ sender: Any) {
        ReaderManager.shared.setFont(.kaitiSC, for: "zh-Hans")
        ReaderManager.shared.fontSize = 6
        ReaderManager.shared.theme = .gray
        webView.evaluateJavaScript("updateConfig(\"\(ReaderManager.shared.configurationJSJson)\")")
    }

    func loadRequest() {
        guard var urlString = locationBar.text else {
            return
        }
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        guard let url = URL(string: urlString) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return true
        }
        var urlString = text
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        guard let url = URL(string: urlString) else {
            return true
        }
        webView.load(URLRequest(url: url))
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: WKURLSchemeHandler {

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            urlSchemeTask.didFailWithError(NSError(domain: "failed", code: -1))
            return
        }
        let path = components.path
        print(path)
        if path == "/index" {
            guard let originalURL = components.valueForQuery("url"),
                  let article = ReaderManager.shared.getArticle(with: originalURL) else {
                urlSchemeTask.didFailWithError(NSError(domain: "failed", code: -1))
                return
            }
            let readerHtml = ReaderManager.shared.getHtmlString(for: article, url: originalURL)
            let data = readerHtml.data(using: .utf8)!
            let response = URLResponse(url: url, mimeType: "text/html", expectedContentLength: -1, textEncodingName: "utf-8")
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } else if path.hasPrefix("/fonts/") {
            let fileName = url.lastPathComponent
            ReaderManager.shared.font(with: fileName) { result in
                switch result {
                case .success(let data):
                    let response = URLResponse(url: url, mimeType: "application/octet-stream", expectedContentLength: -1, textEncodingName: nil)
                    urlSchemeTask.didReceive(response)
                    urlSchemeTask.didReceive(data)
                    urlSchemeTask.didFinish()
                case .failure(let failure):
                    guard let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil) else {
                        urlSchemeTask.didFailWithError(failure)
                        return
                    }
                    urlSchemeTask.didReceive(response)
                    urlSchemeTask.didFinish()
                }
            }
        } else {
            guard let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil) else {
                urlSchemeTask.didFailWithError(NSError(domain: "scheme handler error", code: -1))
                return
            }
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didFinish()
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {

    }
}

