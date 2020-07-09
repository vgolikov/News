//
//  Articles+Mapping.swift
//  News
//
//  Created by Viachaslau Holikau on 7/9/20.
//  Copyright © 2020 Viachaslau Holikau. All rights reserved.
//

import Foundation
import ObjectMapper

extension Articles: Mappable {
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        news <- map["articles"]
    }
}
