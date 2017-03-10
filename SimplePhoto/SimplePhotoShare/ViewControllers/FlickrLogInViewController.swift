//
//  FlickrLogInViewController.swift
//  SimplePhotoShare
//
//  Created by Jin on 3/3/17.
//  Copyright © 2017 tsingshen. All rights reserved.
//

import UIKit
import FlickrKit

class FlickrLogInViewController: UIViewController {

    @IBOutlet weak var loginWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Flickr will call this back.
        let callbackURLString = "flickrkitauth://auth"
        
        // Begin the authentication process
        let url = URL(string: callbackURLString)
        FlickrKit.shared().beginAuth(withCallbackURL: url!, permission: FKPermission.delete, completion: { (url, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
                    self.loginWebView.loadRequest(urlRequest as URLRequest)
                } else {
                    let alert = UIAlertController(title: "Error", message: error as? String, preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            });
        })
    }

    // MARK: WebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //If they click NO DONT AUTHORIZE, this is where it takes you by default... maybe take them to my own web site, or show something else        
        let url = request.url        
        // If it's the callback url, then lets trigger that
        if  !(url?.scheme == "http") && !(url?.scheme == "https") {
            if (UIApplication.shared.canOpenURL(url!)) {
                UIApplication.shared.openURL(url!)
                return false
            }
        }
        return true
    }
}
