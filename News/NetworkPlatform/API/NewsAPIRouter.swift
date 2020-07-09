//
//  NewsAPIRouter.swift
//  News
//
//  Created by Viachaslau Holikau on 7/9/20.
//  Copyright © 2020 Viachaslau Holikau. All rights reserved.
//

import Foundation
import Alamofire

enum NewsAPIRouter {
    case getNews(fromDate: String, toDate: String)
    
    static let baseURLString = "https://newsapi.org/v2/"
    static let headerKey = "X-Api-Key"
    static let headerValue = "ccfac2896b4649eeb559ffe86cd4d8cb"
    
    var method: HTTPMethod {
        switch self {
        case .getNews:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getNews(let fromDate, let toDate):
            return "everything?domains=bbc.co.uk&from=\(fromDate)&to=\(toDate)"
        }
    }

}


// MARK: - URLRequestConvertible
extension NewsAPIRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = try NewsAPIRouter.baseURLString.asURL()
        let urlWithPath = try url.appendingPathComponent(path).absoluteString.removingPercentEncoding!.asURL()
        var urlRequest = URLRequest(url: urlWithPath)
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(NewsAPIRouter.headerValue, forHTTPHeaderField: NewsAPIRouter.headerKey)
        
        switch self {
        case .getNews(_,_):
            break
        }
        
        return urlRequest
    }
}
