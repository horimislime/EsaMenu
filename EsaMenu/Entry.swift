//
//  Entry.swift
//  EsaMenu
//
//  Created by horimislime on 9/19/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import enum Result.Result

class EntryAuthor: Mappable {
    
    var name: String = ""
    var screenName: String = ""
    var iconUrlString: String = ""
    
    var iconURL: NSURL {
        return NSURL(string: iconUrlString)!
    }
    
    required convenience init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        screenName <- map["screen_name"]
        iconUrlString <- map["icon"]
    }
}

class Entry : Mappable {
    
    var number: Int!
    var name: String!
    var markdown: String?
    var tags: [String]?
    var category: String?
    var wip = true
    var message: String?
    var url: String!
    
    var createdAt: NSDate!
    var updatedAt: NSDate!
    
    var updatedBy: EntryAuthor!
    
    
    required convenience init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        number <- map["number"]
        name <- map["name"]
        markdown <- map["body_md"]
        category <- map["category"]
        wip <- map["wip"]
        url <- map["url"]
        
        createdAt <- (map["created_at"], CustomDateTransform())
        updatedAt <- (map["updated_at"], CustomDateTransform())
        updatedBy <- map["updated_by"]
    }
    
    class func list(completion: @escaping (Result<[Entry], NSError>) -> Void) {
        Alamofire.request(Router.Posts(1))
            .validate()
            .responseArray(keyPath: "posts") { (response: DataResponse<[Entry]>) in
                
                switch response.result {
                case .success(let entries):
                    completion(.success(entries))
                case .failure(_):
                    completion(.failure(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil)))
                }
        }
    }
}




