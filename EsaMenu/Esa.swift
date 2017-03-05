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
    
    case Posts(Int)
    case Teams
    
    var method: Alamofire.Method {
        switch self {
        case .Posts: return .GET
        case .Teams: return .GET
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        
        

        let result: (path: String, parameters: [String: AnyObject]) = {
            switch self {
            case .Posts(let page):
                let team = UserDefaults.standard.object(forKey: "esa-current-team-name") as! String
                return ("/teams/\(team)/posts", ["page": page as AnyObject, "per_page": 50 as AnyObject])
            case .Teams:
                return ("/teams", [:])
            }
        }()
        
        let request = NSMutableURLRequest(url: URL(string: Router.baseURLString + result.path)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = method.rawValue

        
        if let raw = UserDefaults.standard.object(forKey: "esa-credential") as? NSData, let credential = NSKeyedUnarchiver.unarchiveObject(with: raw as Data) as? OAuthSwiftCredential {
            request.setValue("Bearer \(credential.oauth_token)", forHTTPHeaderField: "Authorization")
        }
        
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(request, parameters: result.parameters).0
    }
}

let oauth: OAuth2Swift = OAuth2Swift(
    consumerKey: Environment.consumerKey,
    consumerSecret: Environment.consumerSecret,
    authorizeUrl: "https://api.esa.io/oauth/authorize",
    accessTokenUrl: "https://api.esa.io/oauth/token",
    responseType: "code"
)

final class Esa {
    class func authorize(completion: Result<OAuthSwiftCredential, NSError> -> Void) {
        oauth.authorizeWithCallbackURL(NSURL(string: "esamenuapp://oauth-callback")!,
                                       scope: "read", state: "app-secret",
                                       success: { credential, response, parameters in
            
            debugPrint("credential = \(credential)")
            completion(.Success(credential))
            
            }, failure: { error in
                completion(.Failure(error))
        })
    }
}




