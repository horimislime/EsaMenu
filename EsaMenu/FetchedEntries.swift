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
    
    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    func mapping(map: Map) {
        posts <- map["posts"]
        nextPage <- map["next_page"]
    }

    
    func sorted() -> [Entry] {
        return posts.sort({ $0.0.updatedAt > $0.1.updatedAt })
    }
    
    func push(entries: [Entry]) {
        for entry in entries {
            guard let targetIndex = posts.indexOf({ $0.number == entry.number }) else {
                posts.append(entry)
                continue
            }
            
            if posts[targetIndex].updatedAt != entry.updatedAt {
                posts.removeAtIndex(targetIndex)
                posts.append(entry)
            }
        }
    }
    
    class func fetch(completion: Result<FetchedEntries, NSError> -> Void) {
        Alamofire.request(Router.Posts(Configuration.load(), 1))
            .validate()
            .responseObject { (response: FetchedEntries?, error: ErrorType?) in
                if let model = response {
                    completion(.Success(model))
                    return
                }
                
                completion(.Failure(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil)))
        }
    }
    
    func fetchLatest(completion: NSError? -> Void) {
        Alamofire.request(Router.Posts(Configuration.load(), 1))
            .validate()
            .responseObject { [weak self] (response: FetchedEntries?, error: ErrorType?) in
                
                guard let strongSelf = self else { return }
                
                if let model = response {
                    strongSelf.push(model.posts)
                    completion(nil)
                    return
                }
                completion(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil))
        }
    }
    
    func fetchMore(completion: NSError? -> Void) {
        
        Alamofire
            .request(Router.Posts(Configuration.load(), nextPage))
            .validate()
            .responseObject { [weak self] (response: FetchedEntries?, error: ErrorType?) in
                
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