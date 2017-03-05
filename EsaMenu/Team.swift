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
    
    class func list(completion: @escaping (Result<[Team], NSError>) -> Void) {
        Alamofire
            .request(Router.Teams)
            .validate()
            .responseArray(keyPath: "teams") { (response: DataResponse<[Team]>) in
                
                switch response.result {
                case .success(let teams):
                    completion(.success(teams))
                case .failure(_):
                    completion(.failure(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil)))
                }
        }
    }
}
