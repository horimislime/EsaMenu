//
//  Esa.swift
//  EsaMenu
//
//  Created by horimislime on 9/19/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import OAuthSwift
import ObjectMapper
import enum Result.Result

class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix("https://api.esa.io") {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}

enum Router: URLRequestConvertible {
    
    func asURLRequest() throws -> URLRequest {
        
        let result: (path: String, parameters: [String: AnyObject]) = {
            switch self {
            case .Posts(let page):
                let team = UserDefaults.standard.object(forKey: "esa-current-team-name") as! String
                return ("/teams/\(team)/posts", ["page": page as AnyObject, "per_page": 50 as AnyObject])
            case .Teams:
                return ("/teams", [:])
            }
        }()
        
        var request = URLRequest(url: URL(string: Router.baseURLString + result.path)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        
        return try URLEncoding.default.encode(request, with: result.parameters)
    }

    
    static let baseURLString = "https://api.esa.io/v1"
    
    case Posts(Int)
    case Teams
    
    var method: HTTPMethod {
        switch self {
        case .Posts: return .get
        case .Teams: return .get
        }
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
    
    static let shared: Esa = {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "esa-credential") as? Data,
            let credential = NSKeyedUnarchiver.unarchiveObject(with: data) {
            return Esa(token: (credential as! OAuthSwiftCredential).oauthToken)
        } else {
            return Esa()
        }
    }()
    
    convenience init(token: String) {
        self.init()
        sessionManager.adapter = AccessTokenAdapter(accessToken: token)
    }
    
    fileprivate let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    func authorize(completion: @escaping (Result<OAuthSwiftCredential, OAuthSwiftError>) -> Void) {
        
        oauth.authorize(withCallbackURL: "esamenuapp://oauth-callback", scope: "read", state: "app-secret", parameters: [:], headers: nil,  success: { (credential: OAuthSwiftCredential, response: OAuthSwiftResponse?, params: Parameters) in
            debugPrint("credential = \(credential)")
            self.sessionManager.adapter = AccessTokenAdapter(accessToken: credential.oauthToken)
            completion(.success(credential))

        }) { (error: OAuthSwiftError) in
            completion(.failure(error))
        }
    }
    
    func teams(completion: @escaping (Result<[Team], NSError>) -> Void) {
        sessionManager
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
    
    func posts(page: Int, completion: @escaping (Result<FetchedEntries, NSError>) -> Void) {
        sessionManager
            .request(Router.Posts(page))
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
}




