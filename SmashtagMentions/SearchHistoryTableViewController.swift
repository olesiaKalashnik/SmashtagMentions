//
//  SearchHistoryTableViewController.swift
//  SmashtagMentions
//
//  Created by Olesia Kalashnik on 2/10/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit

class SearchHistoryTableViewController: UITableViewController {
    
    var history = Defaults()
    
    // MARK: - View Controller Lifecycle
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.listOfSearches.count
    }
    
    private struct Storyboard {
        static let ReuseIdentifier = "HistoryReuseCell"
        static let SegueToTabBar = "ShowSearchResults"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = history.listOfSearches[indexPath.row]
        return cell
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.SegueToTabBar {
            if let tweetTableVC = segue.destinationViewController as? TweetTableViewController {
                if let theSender = sender as? UITableViewCell {
                    let newSearchText = theSender.textLabel!.text
                    tweetTableVC.searchText = newSearchText
                }
            }
        }
    }
    
}
