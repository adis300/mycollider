//
//  HTTPRequest.swift
//  WebRTC-iOS-Client
//
//  Created by Disi A on 3/30/17.
//  Copyright © 2017 Innovation. All rights reserved.
//

import UIKit

fileprivate var kTimeout:TimeInterval = 10

enum HTTPResponseStatus: Int {
    // Server Events
    case success = 200,
    successCreated = 201,
    
    // Server Error Events
    badRequest = 400,
    unauthorized = 401,
    forbidden = 403,
    methodNotAllowed = 405,
    preconditionFailed = 412,
    tooManyRequest = 429,
    
    serverInternalError = 500,
    
    // SDK Events
    requestTimeout = 1001,
    sslHandshakeFailure = 1004
}

class HTTPRequest {
    
    
    static func post(url:String, data:Data, headers:Dictionary<String, String>, onSuccess:(_ response: NSData) -> Void, onFailure:(_ error:Error) -> Void){
        HTTPRequest.sendHTTPRequest(url: url, method: "POST", data: data, headers: headers, onSuccess: onSuccess, onFailure: onFailure, timeout: kTimeout, delegate: nil)
    }
    
    static func get(url:String, headers:Dictionary<String, String>, onSuccess:(_ response: NSData) -> Void, onFailure:(_ error:Error) -> Void){
        HTTPRequest.sendHTTPRequest(url: url, method: "POST", data: nil, headers: headers, onSuccess: onSuccess, onFailure: onFailure, timeout: kTimeout, delegate: nil)
    }
    
    fileprivate static func sendHTTPRequest(url:String, method:String, data:Data?, headers:Dictionary<String, String>, onSuccess:(_ response: NSData) -> Void, onFailure:(_ error:Error) -> Void, timeout: TimeInterval, delegate: URLSessionDelegate?){
        let urlAddress = URL(string: url)
        assert(urlAddress != nil, "HTTPRequest: Sending request to invalid URL")
        
        var request = URLRequest(url: urlAddress!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = method
        request.httpBody = data
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = headers
        
        var session:URLSession // = URLSession.shared

        if let sessionDelegate = delegate {
            session = URLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil)
        }else{
            session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error{
                DispatchQueue.main.async {
                    onFailure(err);
                }
            }
        }
        
        
        
    }
    
    
}
