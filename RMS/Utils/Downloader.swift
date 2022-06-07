//
//  Downloader.swift
//  RMS
//
//  Created by Hung Lam on 07/06/2022.
//

import Foundation

class Downloader {
    static func load(url: URL, fileHandler: @escaping (Data) -> Void ) -> Void {
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (data: Data!, response: URLResponse!, error: Error!) -> Void in
            if (error == nil) {
                fileHandler(data)
            }
        })
        task.resume()
    }
}
