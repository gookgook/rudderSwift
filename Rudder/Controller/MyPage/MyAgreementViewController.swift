//
//  MyAgreementViewController.swift
//  Rudder
//
//  Created by Brian Bae on 12/09/2021.
//

import UIKit
import WebKit

class MyAgreementViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://sites.google.com/view/mateprivacyterms") else {
            return
        }
        
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))

        // Do any additional setup after loading the view.
    }
}

extension MyAgreementViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.startAnimating()
        print("load start")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
        print("load finish")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
        print("server error")
    }
}
