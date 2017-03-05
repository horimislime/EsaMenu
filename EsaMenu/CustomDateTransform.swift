//
//  CustomDateTransform.swift
//  EsaMenu
//
//  Created by horimislime on 9/19/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Foundation
import ObjectMapper

var formatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZ"
    return f
}()

class CustomDateTransform: TransformType {
    
    typealias Object = NSDate
    typealias JSON = String
    
    func transformFromJSON(_ value: Any?) -> NSDate? {
        if let timeString = value as? String {
            return formatter.date(from: timeString) as NSDate?
        }
        return nil
    }
    
    func transformToJSON(_ value: NSDate?) -> String? {
        if let date = value {
            return formatter.string(from: date as Date)
        }
        return nil
    }
}
