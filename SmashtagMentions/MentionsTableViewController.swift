//
//  MentionsTableViewController.swift
//  SmashtagMentions
//
//  Created by Olesia Kalashnik on 2/1/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit

class MentionsTableViewController: UITableViewController {
    
    private var mentionsStack = [Mention]()
    
    var tweet : Tweet? {
        didSet {
            mentionsStack.removeAll()
            loadMentions()
        }
    }
    
    private enum Mention {
        case image([MediaItem])
        case hashtag([String])
        case userMention([String])
        case url([String])
        
        var count : Int {
            get {
                switch self {
                case .hashtag(let hashtags):
                    return hashtags.count
                case .image(let images):
                    return images.count
                case .url(let urls):
                    return urls.count
                case .userMention(let userMentions):
                    return userMentions.count
                }
            }
        }
        
        var sectionHeader : String? {
            switch self {
            case .image(let images):
                if images.count > 0 {return "Images"}
                else {return nil}
            case .hashtag(let hashtags):
                if hashtags.count > 0 { return "Hashtags"}
                else { return nil }
            case .url(let urls):
                if urls.count > 0 { return "URLS" }
                else { return nil }
            case .userMention(_): return "Mentions"
            }
        }
        
        func indexOfString(index : Int) -> String? {
            switch self {
            case .userMention(let users):
                return users[index]
            case .hashtag(let hashtags):
                return hashtags[index]
            case .url(let urls):
                return urls[index]
            default:
                return nil
            }
        }
        
        subscript(index: Int) -> MediaItem? {
            switch self {
            case .image(let images):
                return images[index]
            default:
                return nil
            }
        }
    }
    
    private func loadMentions() {
        if let tweet = self.tweet {
            if !tweet.media.isEmpty {
                mentionsStack.append(Mention.image(tweet.media))
            }
            if !tweet.hashtags.isEmpty {
                mentionsStack.append(Mention.hashtag(tweet.hashtags.map({$0.keyword})))
            }
            if !tweet.urls.isEmpty {
                mentionsStack.append(Mention.url(tweet.urls.map({$0.keyword})))
            }
            mentionsStack.append(Mention.userMention(tweet.userMentions.map({$0.keyword}) + ["@\(tweet.user.screenName)"]))
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentionsStack.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionsStack[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionsStack[section].sectionHeader
    }
    
    private struct Storyboard {
        static let ImageCellIdentifier = "ImageReuseCell"
        static let MentionCellIdentifier = "MentionReuseCell"
        static let ShowNewHashtagTweets = "ShowNewTweetSearchResults"
        static let EnterURL = "DisplayURLContents"
        static let ShowImage = "ShowImageContents"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch mentionsStack[indexPath.section].sectionHeader! {
        case "Images":
            let imageCell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath) as! ImageTableViewCell
            // Configure the imageCell
            if let theMediaItem = mentionsStack[indexPath.section][indexPath.row] {
                imageCell.theMediaItem = theMediaItem
            }
            return imageCell
            
        default:
            let mentionCell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MentionCellIdentifier, forIndexPath: indexPath)
            // Configure the mentionCell
            if let mention = mentionsStack[indexPath.section].indexOfString(indexPath.row) {
                mentionCell.textLabel?.text = mention
            }
            return mentionCell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let header = mentionsStack[indexPath.section].sectionHeader {
            switch header {
            case "URLS":
                if let selectedURL = mentionsStack[indexPath.section].indexOfString(indexPath.row) {
                    if let url = NSURL(string: selectedURL) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            case "Images":
                performSegueWithIdentifier(Storyboard.ShowImage, sender: self)
            default:
                performSegueWithIdentifier(Storyboard.ShowNewHashtagTweets, sender: self)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let image = mentionsStack[indexPath.section][indexPath.row] {
            return tableView.bounds.size.width / CGFloat(image.aspectRatio)
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let selectedSection = tableView.indexPathForSelectedRow!.section
        let selectedRow = tableView.indexPathForSelectedRow!.row
        navigationController?.navigationItem.backBarButtonItem?.title = sender?.title
        
        if segue.identifier == Storyboard.ShowNewHashtagTweets {
            var destination = segue.destinationViewController as UIViewController
            if let tabBarVC = destination as? UITabBarController {
                destination = tabBarVC.customizableViewControllers![0]}
            
            if let tweetTableVC = destination as? TweetTableViewController {
                if let newSearchText = mentionsStack[selectedSection].indexOfString(selectedRow) {
                    if newSearchText.hasPrefix("@") {
                        var fromNewSearchText = newSearchText
                        fromNewSearchText.removeAtIndex(newSearchText.startIndex)
                        tweetTableVC.searchText = "\(newSearchText) OR from:\(fromNewSearchText)"
                    }
                    else {
                        tweetTableVC.searchText = newSearchText
                    }
                    tweetTableVC.title = newSearchText
                }
            }
        }
            
        else if segue.identifier == Storyboard.ShowImage {
            if let imageViewingVC = segue.destinationViewController as? ImageViewingViewController {
                imageViewingVC.title = "Image"
                let mediaItemForViewing = mentionsStack[selectedSection][selectedRow]
                imageViewingVC.imageURL = mediaItemForViewing?.url
            }
        }
    }
}
