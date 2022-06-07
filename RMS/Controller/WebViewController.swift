//
//  WebViewController.swift
//  RMS
//
//  Created by Hung Lam on 06/05/2022.
//

// https://i.imgur.com/SufVLiV.jpeg
// https://i.imgur.com/GVZQlyN.mp4

import UIKit
import WebKit
import SwiftUI
import AVKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    var url = URL(string:"https://csb-fxh99z.netlify.app/")!
    var urlScheme = "RMS"
    var fileManager = FileManager.default
    var dirUrl: URL!


    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.setURLSchemeHandler(self, forURLScheme: urlScheme)
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        webConfiguration.userContentController.add(self, contentWorld: .page, name: "observer")
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshContent(_:)), for: .valueChanged)
        
        webView.load(URLRequest(url: url))
        webView.scrollView.addSubview(refreshControl)
        
        fileManager = FileManager.default
        do {
            dirUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: URL(string: "ios-demo"), create: true)
        } catch {
            print(error)
        }
    }
     
    @objc private func refreshContent(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        webView.evaluateJavaScript("window.reloadContent?.()")
    }
    
    private func loadImage() {
        print("loading img")
        Downloader.load(url: URL(string: "https://i.imgur.com/SufVLiV.jpeg")!, fileHandler: { (data: Data) -> Void in
            let path = self.dirUrl.appendingPathComponent("cat.jpeg").path
            self.fileManager.createFile(atPath: path, contents: data)
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("window.setImgUrl?.('\(self.urlScheme)://temp/cat.jpeg')")
            }
        })
    }
    
    private func loadVideo() {
        print("loading video")
        Downloader.load(url: URL(string: "https://i.imgur.com/GVZQlyN.mp4")!, fileHandler: { (data: Data) -> Void in
            let path = self.dirUrl.appendingPathComponent("cat.mp4").path
            print(self.dirUrl.path)
            self.fileManager.createFile(atPath: path, contents: data)
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("window.setVideoUrl?.('\(self.urlScheme)://temp/cat.mp4')")
            }
        })
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if let data = message.body as? [String : String],
            let action = data["action"] {
            
            if action == "loadImage" {
                loadImage()
            }
            
            if action == "loadVideo" {
                loadVideo()
            }
        }
    }
}

extension WebViewController: WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let requestUrl = urlSchemeTask.request.url
        if (requestUrl?.host != "temp") {
            return
        }
        
        let response: HTTPURLResponse!
        
        guard let path = requestUrl?.path else { return }
        guard let data = fileManager.contents(atPath: dirUrl.appendingPathComponent(path).path) else { print(dirUrl.appendingPathComponent(path).path); return }
        
        print(dirUrl.appendingPathComponent(path).path)
        
        switch (requestUrl?.pathExtension) {
        case "mp4":
            // for video, the exact expectedContentLenght is required as it is a stream of data.
            response = HTTPURLResponse(url: url, mimeType: "video/mp4", expectedContentLength: data.count, textEncodingName: nil)
            break
        case "jpeg":
            response = HTTPURLResponse(url: url, mimeType: "image/jpeg", expectedContentLength: data.count, textEncodingName: nil)
            break
        default:
            return
        }

        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    // No use for now, but is required to conform to the WKURLSchemeHandler protocol
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    
    }
}
