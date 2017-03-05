//
//  Team.swift
//  EsaMenu
//
//  Created by horimislime on 12/5/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import enum Result.Result

final class Team: Mappable {
    
    var name: String!
    var iconURLString: String!
    
    required convenience init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        iconURLString <- map["icon"]
    }
}
