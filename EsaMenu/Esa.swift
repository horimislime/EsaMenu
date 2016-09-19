//
//  Esa.swift
//  EsaMenu
//
//  Created by horimislime on 9/19/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Alamofire
import OAuthSwift
import ObjectMapper

enum Router: URLRequestConvertible {
    
    static let baseURLString = "https://api.esa.io/v1"
    
    case Posts(Configuration)
    
    var method: Alamofire.Method {
        switch self {
        case .Posts:
            return .GET
        }
    }
    
    var URLString: String {
        
        let path: String = {
            switch self {
            case .Posts(let config):
                return "/teams/\(config.teamName!)/posts"
            }
        }()
        
        return Router.baseURLString + path
    }
    
    var URLRequest: NSMutableURLRequest {
        
        let request = NSMutableURLRequest(URL: NSURL(string: self.URLString)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = method.rawValue
        
        switch self {
            
        case .Posts(let config):
            
            if let raw = NSUserDefaults.standardUserDefaults().objectForKey("esa-credential") as? NSData, credential = NSKeyedUnarchiver.unarchiveObjectWithData(raw) {
                request.setValue("Bearer \(credential.oauth_token)", forHTTPHeaderField: "Authorization")
            }
            
            return request
        }
    }
}

let env = NSProcessInfo.processInfo().environment
let oauth: OAuth2Swift = OAuth2Swift(
    consumerKey: env["consumerKey"]!,
    consumerSecret: env["consumerSecret"]!,
    authorizeUrl: "https://api.esa.io/oauth/authorize",
    accessTokenUrl: "https://api.esa.io/oauth/token",
    responseType: "code"
)

final class Esa {
    class func authorize(completion: Result<OAuthSwiftCredential, NSError> -> Void) {
        oauth.authorizeWithCallbackURL(NSURL(string: "esamenuapp://oauth-callback")!,
                                       scope: "read", state: "app-secret",
                                       success: { credential, response, parameters in
            
            print("credential = \(credential)")
            completion(.Success(credential))
            
            }, failure: { error in
                completion(.Failure(error))
        })
    }
}




