//
//  ViewController.swift
//  WebPIntegration
//
//  Created by Vladimir Kolbas on 4/7/16.
//  Copyright © 2016 Vladimir Kolbas. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .ScaleAspectFill
        }
    }

    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    private var dataTask: NSURLSessionDataTask?
    private var downloadTask: NSURLSessionDownloadTask?
    
    // MARK: - Actions
    
    /// Fetch webP from the web and display it.
    @IBAction func fetchWebPAction(sender: AnyObject) {
        // Cancel task, if it exists
        dataTask?.cancel()
        downloadTask?.cancel()
        
        let urlString = "http://www.gstatic.com/webp/gallery/1.webp"
        guard let url = NSURL(string: urlString) else { return }
        
        dataTask = session.dataTaskWithURL(url, completionHandler: { [weak self] (data, _, _) in
            dispatch_async(dispatch_get_main_queue()) {
                let image = UIImageWithWebPData(data!)
                self?.setImageWithImage(image)
            }
            })
        
        dataTask?.resume()
    }
    
    /// Fetch remote JPEG, convert to webP and set image
    @IBAction func fetchWebJPEGAction(sender: AnyObject) {
        // Cancel tasks, if it exists
        dataTask?.cancel()
        downloadTask?.cancel()
        
        let alertController = UIAlertController(title: "Loading Jpeg from the web", message: "Please wait...", preferredStyle: .Alert)
        presentViewController(alertController, animated: true, completion: nil)
        
//        let urlString = "https://upload.wikimedia.org/wikipedia/commons/4/4d/Cat_March_2010-1.jpg"
//        let urlString = "http://res.freestockphotos.biz/pictures/2/2706-outdoor-portrait-of-a-beautiful-teen-girl-pv.jpg"
//        let urlString = "http://www.inet.hr/~vkolbas/img.jpg"
        let urlString = "http://lorempixel.com/568/1136"
        
        guard let url = NSURL(string: urlString) else { return }
        
        // Download the JPEG from web
        downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak self] (localURL, _, _) in
            print("Done")
            guard let jpegData = NSData(contentsOfURL: localURL!) else { print("No data"); return }
            guard let jpegImage = UIImage(data: jpegData) else { return }
            print("AFtert done")
            // get webP data from JPEG for saving to cache?
            let webpData = UIImageWebPRepresentation(jpegImage, .PicturePreset, 50.0, nil)
            print (jpegData.length / 1024, webpData.length / 1024 )
            // get webP from data for displaying
            let webpImage = UIImageWithWebPData(webpData)
            
            // Possibly save webpImage to cache, and display it
            dispatch_async(dispatch_get_main_queue()) {
                self?.dismissViewControllerAnimated(true, completion: nil)
                self?.setImageWithImage(webpImage)
            }
        })
        
        downloadTask?.resume()
        print("Starting task")
    }
    
    /// Load local PNG, convert to webP and display
    @IBAction func localPNGAction(sender: AnyObject) {
        // Cancel tasks, if it exists
        dataTask?.cancel()
        downloadTask?.cancel()
        
        let alertController = UIAlertController(title: "Loading and\nconverting 25Mb PNG", message: "Please wait...", preferredStyle: .Alert)
        presentViewController(alertController, animated: true, completion: nil)
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // Load huge local png
            let imagePNG = UIImage(named: "galaxy.png")
            
            var documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
            documents = documents.stringByAppendingString("image.webp")
            
            // Save webP to disk (For FSNCachemanager or something similar...)
            let imageWebPSaveData = UIImageWebPRepresentation(imagePNG)
            
            imageWebPSaveData.writeToFile(documents, atomically: true)
            
            // Load webP from disk
            guard let imageWebPLoadData = NSData(contentsOfFile: documents) else { return }
            
            let imageWebP = UIImageWithWebPData(imageWebPLoadData)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: nil)
                self.setImageWithImage(imageWebP)
            }
        }
    }
    
    // MARK: - Setting image
    
    private func setImageWithImage(image: UIImage) {
        imageView.image = image
    }
}

