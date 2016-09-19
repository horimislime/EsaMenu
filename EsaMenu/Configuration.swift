//
//  Configuration.swift
//  EsaMenu
//
//  Created by horimislime on 9/19/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Foundation

class Configuration {
    
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    var token: String?
    var teamName: String?
    
    convenience init(
        token: String?,
        teamName: String?)
    {
        self.init()
        self.token = token
        self.teamName = teamName
    }
    
    class func load() -> Configuration {
        return Configuration(token: "401359b959c54d8ed821a645e7212aa846a259310715b07a5b3ddf9553737ac3", teamName: "toreta")
    }
    
    func save() {
//        Configuration.defaults.setObject(self.token, forKey: DefaultsKeys.token)
//        Configuration.defaults.setObject(self.teamName, forKey: DefaultsKeys.teamName)
    }
}


