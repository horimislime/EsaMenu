//
//  FetchedEntries.swift
//  EsaMenu
//
//  Created by horimislime on 2016/09/28.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Foundation

final class FetchedEntries {
    
    private var entries = [Entry]()
    
    var count: Int {
        return entries.count
    }
    
    func sorted() -> [Entry] {
        return entries.sort({ $0.0.updatedAt > $0.1.updatedAt })
    }
    
    func push(entries: [Entry]) {
        for entry in entries {
            guard let targetIndex = self.entries.indexOf({ $0.number == entry.number }) else {
                self.entries.append(entry)
                continue
            }
            
            if self.entries[targetIndex].updatedAt != entry.updatedAt {
                self.entries.removeAtIndex(targetIndex)
                self.entries.append(entry)
            }
        }
    }
}