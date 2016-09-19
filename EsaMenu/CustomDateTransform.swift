//
//  CustomDateTransform.swift
//  EsaMenu
//
//  Created by horimislime on 9/19/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Foundation
import ObjectMapper

var formatter: NSDateFormatter = {
    let f = NSDateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZ"
    return f
}()

class CustomDateTransform: TransformType {
    
    typealias Object = NSDate
    typealias JSON = String
    
    func transformFromJSON(value: AnyObject?) -> NSDate? {
        if let timeString = value as? String {
            return formatter.dateFromString(timeString)
        }
        return nil
    }
    
    func transformToJSON(value: NSDate?) -> String? {
        if let date = value {
            return formatter.stringFromDate(date)
        }
        return nil
    }
}
