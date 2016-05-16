//
//  ImageTableViewCell.swift
//  SmashtagMentions
//
//  Created by Olesia Kalashnik on 2/2/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pictureLabel: UIImageView!
    
    var theMediaItem : MediaItem? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func updateUI() {
        pictureLabel.image = nil
        spinner.startAnimating()
        if let theMediaItem = self.theMediaItem {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            let notMainQueue = dispatch_get_global_queue(qos, 0)
            dispatch_async(notMainQueue) { () -> Void in
                if let pictureURL = theMediaItem.url {
                    if let data = NSData(contentsOfURL: pictureURL) {
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.pictureLabel.image = UIImage(data: data)
                            self.spinner.stopAnimating()
                        }
                    }
                }
            }
        }
    }
}
