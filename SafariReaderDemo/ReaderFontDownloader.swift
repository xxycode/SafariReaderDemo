//
//  ReaderFontDownloader.swift
//  SafariReaderDemo
//
//  Created by XueyuanXiao on 2023/8/27.
//

import Foundation

extension ReaderFontDownloader {

    private struct Constants {

        static let DownloadEndpoint = URL(string: "https://cdn.jsdelivr.net/gh/xxycode/ReaderFonts@main")!

        static let FontFolderName = "ReaderFonts"

    }

    typealias TaskProgressHandler = (Float) -> Void

    typealias TaskCompletionHandler = (Error?) -> Void

    class DownloadTask {

        let font: ReaderFont

        let guid = UUID().uuidString

        var progressHandler: TaskProgressHandler?

        var completion: TaskCompletionHandler?

        private var progress: Float = 0

        weak var dataTask: URLSessionTask?

        init(font: ReaderFont, dataTask: URLSessionTask?) {
            self.font = font
            self.dataTask = dataTask
        }

    }

}

class ReaderFontDownloader: NSObject {

    private let fileRootURL: URL

    private var tasks: [DownloadTask] = []

    override init() {
        let appSupport = URL.appSupportURL
        let root = appSupport.appendingPathComponent(Constants.FontFolderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: root.path) {
            try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        }
        fileRootURL = root
        super.init()
    }

    func download(font: ReaderFont) -> DownloadTask {
        guard let fileName = font.fileName else {
            fatalError()
        }

        let fontDownloadURL = Constants.DownloadEndpoint.appendingPathComponent(fileName, isDirectory: false)
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTask(with: fontDownloadURL)
        downloadTask.resume()
        let task = DownloadTask(font: font, dataTask: downloadTask)
        tasks.append(task)
        return task
    }

    private func task(with downloadTask: URLSessionTask) -> DownloadTask? {
        tasks.first(where: { $0.dataTask == downloadTask })
    }
    
}

extension ReaderFontDownloader: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let task = task(with: downloadTask),
              let fileName = task.font.fileName else {
            return
        }
        let destinationURL = fileRootURL.appendingPathComponent(fileName, isDirectory: false)
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            task.completion?(nil)
        } catch {
            task.completion?(error)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let task = task(with: downloadTask), totalBytesExpectedToWrite != 0 else {
            return
        }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        task.progressHandler?(progress)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let fontTask = self.task(with: task) else {
            return
        }
        fontTask.completion?(error)
        tasks.removeAll(where: { $0.guid == fontTask.guid })
    }


}
