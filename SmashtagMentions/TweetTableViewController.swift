//
//  TweetTableViewController.swift
//  SmashtagMentions
//
//  Created by Olesia Kalashnik on 1/29/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [[Tweet]]()
    var history = Defaults()
    var searchText : String? = "#seattle" {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            self.title = searchText
            history.addSearchItemToHistory(searchText!)
            refresh()
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField?.text = searchText
        }
    }
    
    var lastSuccessfulRequest : TwitterRequest?
    var nextRequest : TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            }
            else {
                return nil
            }
        }
        else {
            return lastSuccessfulRequest?.requestForNewer
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequest {
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                        }
                        sender?.endRefreshing()
                    }
                }
            }
        }
        else {
            sender?.endRefreshing()
        }
    }
    
    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
        self.title = "Search"
    }
    
    // MARK: - UITextField delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
        static let SegueIdentifier = "showTweetMentions"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        if tweets.count > 0 {
            cell.tweet = tweets[indexPath.section][indexPath.row]
        }
        return cell
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mvc = segue.destinationViewController as? MentionsTableViewController {
            if segue.identifier == Storyboard.SegueIdentifier {
                let selectedSection = tableView.indexPathForSelectedRow!.section
                let selectedRow = tableView.indexPathForSelectedRow!.row
                let tweet = tweets[selectedSection][selectedRow]
                mvc.tweet = tweet
                mvc.title = searchText
            }
        }
    }
}
