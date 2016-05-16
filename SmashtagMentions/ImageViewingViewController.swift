//
//  ImageViewingViewController.swift
//  SmashtagMentions
//
//  Created by Olesia Kalashnik on 2/5/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit

class ImageViewingViewController: UIViewController, UIScrollViewDelegate {
    
    private var imageView = UIImageView()
    
    private var scrollViewDidZoomOrScroll = false
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 5.0
            scrollView.minimumZoomScale = 0.1
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var imageURL : NSURL? {
        didSet {
            image = nil  // set the old image (if any) to nil
            if view.window != nil { // fetch image only if I'm currently on screen
                fetchImage()
            }
        }
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollViewDidZoomOrScroll = true
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        scrollViewDidZoomOrScroll = true
    }
    
    func fetchImage() {
        if let url = imageURL {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            let notMainQueue = dispatch_get_global_queue(qos, 0)
            spinner?.startAnimating()
            dispatch_async(notMainQueue) {
                let imageData = NSData(contentsOfURL: url)
                if url == self.imageURL {
                    dispatch_async(dispatch_get_main_queue()) { // return to the main queue for all the UI related actions
                        if imageData != nil {
                            self.image = UIImage(data: imageData!)
                        }
                        else {
                            self.image = nil
                        }
                    }
                }
            }
        }
    }

    private var image : UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            //every time a new image is set update the size of imageView frame and the scrollView's contentSize to fit the new image
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
            scrollViewDidZoomOrScroll = false
            autoZoom()
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private func autoZoom() {
        if scrollViewDidZoomOrScroll {
            return
        } else {
            if image != nil {
                scrollView.zoomScale = max(scrollView.bounds.size.height / imageView.bounds.height, scrollView.bounds.size.width / imageView.bounds.width)
                scrollView.contentOffset = CGPoint(x: (imageView.frame.size.width - scrollView.frame.width) / 2.0, y: (imageView.frame.size.height - scrollView.frame.size.height) / 2.0)
                scrollViewDidZoomOrScroll = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //if no image has been set before you're going to appear, fetch one
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        autoZoom()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
