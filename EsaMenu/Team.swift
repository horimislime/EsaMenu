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

final class Team: Mappable {
    
    var name: String!
    var iconURLString: String!
    
    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        iconURLString <- map["icon"]
    }
    
    class func list(completion: Result<[Team], NSError> -> Void) {
        Alamofire
            .request(Router.Teams)
            .validate()
            .responseArray("teams") { (response: [Team]?, error: ErrorType?) in
                
                if let model = response {
                    completion(.Success(model))
                    return
                }
                
                completion(.Failure(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil)))
        }
    }
}
