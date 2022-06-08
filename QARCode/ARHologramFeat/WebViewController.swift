//
//  WebViewController.swift
//  QARCodeApp
//
//  Created by Marcos Chevis on 02/06/22.
//

import Foundation
import UIKit
import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

final class WebViewController: UIViewController, WKNavigationDelegate {
    var url: URL
    lazy var webView: WKWebView = {
        
        let v = WKWebView(frame: .zero)
        v.configuration.allowsInlineMediaPlayback = true
        v.configuration.mediaTypesRequiringUserActionForPlayback = []
        v.load(URLRequest(url: self.url))
        v.reload()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.navigationDelegate = self
        
        return v
    }()
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
//        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        view = webView
    }
    
//    private func setupConstraints() {
//        self.view.addSubview(webView)
//        NSLayoutConstraint.activate([
//            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//        ])
//    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            let exceptions = SecTrustCopyExceptions(serverTrust)
            SecTrustSetExceptions(serverTrust, exceptions)
            completionHandler(.useCredential, URLCredential(trust: serverTrust));
        }
    
    
}
