//
//  TweetTableViewCell.swift
//  SmashtagMentions
//
//  Created by Olesia Kalashnik on 1/29/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet : Tweet? {
        didSet {
            updateUI()
        }
    }
    
    // Attributes for hashtags, urls, and userMentions
    let hashtagAttributes = [NSForegroundColorAttributeName : UIColor.brownColor()]
    let urlAttributes = [NSForegroundColorAttributeName : UIColor.blueColor()]
    let mentionAttributes = [NSForegroundColorAttributeName : UIColor.purpleColor()]

    func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        userNameLabel?.text = nil
        profileImageView?.image = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.text = tweet.text

            if tweetTextLabel?.text != nil  {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
                let mutableLabelText = NSMutableAttributedString(string: tweetTextLabel.text!)

                for hashtag in tweet.hashtags {
                    mutableLabelText.addAttributes(hashtagAttributes, range: hashtag.nsrange)
                }
                for url in tweet.urls {
                    mutableLabelText.addAttributes(urlAttributes, range: url.nsrange)
                }
                for mention in tweet.userMentions {
                    mutableLabelText.addAttributes(mentionAttributes, range: mention.nsrange)
                }
                tweetTextLabel.attributedText = mutableLabelText
            }
            
            userNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            let notMainQueue = dispatch_get_global_queue(qos, 0)
            dispatch_async(notMainQueue) { () -> Void in
                if let url = self.tweet?.user.profileImageURL {
                    if let data = NSData(contentsOfURL: url) {
                        dispatch_async(dispatch_get_main_queue())  { () -> Void in
                        self.profileImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
}

