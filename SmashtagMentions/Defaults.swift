//
//  Defaults.swift
//  SmashtagMentions
//
//  Created by Olesia Kalashnik on 2/11/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import Foundation

class Defaults {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    private struct Keys {
        static let SearchItems = "searchItem"
    }
    
    var listOfSearches : [String] {
        return defaults.objectForKey(Keys.SearchItems) as? [String]
            ?? [] }
    
    func addSearchItemToHistory(searchItem : String) {
        if !listOfSearches.contains({searchItem.caseInsensitiveCompare($0) == NSComparisonResult.OrderedSame}) {
            defaults.setObject([searchItem]+listOfSearches, forKey: Keys.SearchItems)
        }
        if self.listOfSearches.count > 100 {
            var shortenedList = self.listOfSearches
            shortenedList.removeLast()
            defaults.setObject(shortenedList, forKey: Keys.SearchItems)
        }
    }
}