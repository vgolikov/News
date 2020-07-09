//
//  NetworkManager.swift
//  News
//
//  Created by Viachaslau Holikau on 7/9/20.
//  Copyright © 2020 Viachaslau Holikau. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

typealias NewsAPIResponse = ((_ response: [News], _ error: Error?) -> Void)

protocol NewsAPI {
    func getNews(fromDate: String, toDate: String, completionHandler: @escaping NewsAPIResponse)
}

class NetworkManager: NewsAPI {
    
    static let shared = NetworkManager()
    
    func getNews(fromDate: String, toDate: String, completionHandler: @escaping NewsAPIResponse) {
        AF.request(NewsAPIRouter.getNews(fromDate: fromDate, toDate: toDate))
            .validate()
            .responseObject { (response: DataResponse<Articles, AFError>) in
                if let error = response.error {
                    completionHandler([], error)
                } else {
                    if let news = response.value?.news {
                        completionHandler(news, nil)
                    }
                }
        }
    }
    
}
