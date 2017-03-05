//
//  FetchedEntries.swift
//  EsaMenu
//
//  Created by horimislime on 2016/09/28.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper

final class FetchedEntries: Mappable {
    
    private var posts = [Entry]()
    var nextPage: Int!
    
    var count: Int {
        return posts.count
    }
    
    required convenience init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        posts <- map["posts"]
        nextPage <- map["next_page"]
    }

    
    func sorted() -> [Entry] {
        return posts.sort(by: { $0.0.updatedAt > $0.1.updatedAt })
    }
    
    func push(entries: [Entry]) {
        for entry in entries {
            guard let targetIndex = posts.index(where: { $0.number == entry.number }) else {
                posts.append(entry)
                continue
            }
            
            if posts[targetIndex].updatedAt != entry.updatedAt {
                posts.remove(at: targetIndex)
                posts.append(entry)
            }
        }
    }
    
    class func fetch(completion: Result<FetchedEntries, NSError> -> Void) {
        Alamofire.request(Router.Posts(1))
            .validate()
            .responseObject { (response: FetchedEntries?, error: Error?) in
                if let model = response {
                    completion(.Success(model))
                    return
                }
                
                completion(.Failure(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil)))
        }
    }
    
    func fetchLatest(completion: @escaping (NSError?) -> Void) {
        Alamofire.request(Router.Posts(1))
            .validate()
            .responseObject { [weak self] (response: FetchedEntries?, error: Error?) in
                
                guard let strongSelf = self else { return }
                
                if let model = response {
                    strongSelf.push(model.posts)
                    completion(nil)
                    return
                }
                completion(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil))
        }
    }
    
    func fetchMore(completion: @escaping (NSError?) -> Void) {
        
        guard let nextPage = nextPage else {
            completion(nil)
            return
        }
        
        Alamofire
            .request(Router.Posts(nextPage))
            .validate()
            .responseObject { [weak self] (response: FetchedEntries?, error: Error?) in
                
                guard let strongSelf = self else { return }
                
                if let model = response {
                    strongSelf.posts.appendContentsOf(model.posts)
                    strongSelf.nextPage = model.nextPage
                    completion(nil)
                    return
                }
                
                completion((NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil)))
        }
    }
}
