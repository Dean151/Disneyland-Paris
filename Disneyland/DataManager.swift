//
//  DataManager.swift
//  Disneyland
//
//  Created by Thomas Durand on 07/01/2015.
//  Copyright (c) 2015 Dean151. All rights reserved.
//

import Foundation

let availableCountryCodes = ["en", "fr"]
let countryCode = "en"

let attractionsURL = "http://api.disneyfan.fr/attractions/extended/\(countryCode)"
let restaurantsURL = "http://api.disneyfan.fr/restaurants/extended/\(countryCode)"
let waitTimesURL = "http://api.disneyfan.fr/waittimes"
let ouvertureURL = "http://api.disneyfan.fr/ouverture"

class DataManager {
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        var session = NSURLSession.sharedSession()
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain:"fr.dean151", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        }
    }
    
    class func getUrlWithSuccess(#url: String, success: (data: NSData?, error: NSError?) -> Void) {
        loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            if let responseError = error {
                success(data: nil, error: responseError)
            } else if let urlData = data {
                success(data: urlData, error: nil)
            }
        })
    }
}

