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
import enum Result.Result

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
        return posts.sorted { $0.0.updatedAt.timeIntervalSince1970 > $0.1.updatedAt.timeIntervalSince1970 }
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
    
    class func fetch(completion: @escaping (Result<FetchedEntries, NSError>) -> Void) {
        Alamofire.request(Router.Posts(1))
            .validate()
            .responseObject { (response: DataResponse<FetchedEntries>) in
                
                switch response.result {
                case .success(let entries):
                    completion(.success(entries))
                case .failure(_):
                    completion(.failure(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil)))
                }
        }
    }
    
    func fetchLatest(completion: @escaping (NSError?) -> Void) {
        Alamofire.request(Router.Posts(1))
            .validate()
            .responseObject { [weak self] (response: DataResponse<FetchedEntries>) in
        
                guard let strongSelf = self else { return }
                
                switch response.result {
                case .success(let entries):
                    strongSelf.push(entries: entries.posts)
                case .failure(_):
                    completion(NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil))
                }
                completion(nil)
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
            .responseObject { [weak self] (response: DataResponse<FetchedEntries>) in
                
                guard let strongSelf = self else { return }
                
                switch response.result {
                case .success(let entries):
                    strongSelf.posts.append(contentsOf: entries.posts)
                    strongSelf.nextPage = entries.nextPage
                case .failure(_):
                    completion((NSError(domain: "jp.horimislime.cage.error", code: -1, userInfo: nil)))
                }
                
                completion(nil)
        }
    }
}
