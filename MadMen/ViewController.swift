//
//  ViewController.swift
//  Draper
//
//  Created by ritmatter on 5/19/15.
//  Copyright (c) 2015 ritmatter. All rights reserved.
//

import Parse
import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var episodeTitleLabel: UILabel!
  @IBOutlet weak var speakerLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var episodeLabel: UILabel!
  @IBOutlet weak var backgroundView: UIImageView!
  @IBOutlet weak var shareButton: UIButton!

  var text = ""
  var speaker = ""
  var season =  1
  var episode = 1
  var episodeTitle = ""
  var quotes: [PFObject]!

  let image_names = [
    "ad.png",
    "ad2.png",
    "ad3.png",
    "ad4.png",
    "ad5.png",
    "ad6.png",
    "ad7.png",
    "ad8.png",
    "ad10.png",
    "ad14.png",
    "ad15.png",
    "ad22.png",
    "ad25.png",
    "coke1.png",
    "coke2.png",
    "coke3.png",
    "coke4.png",
    "coke10.png",
    "heinz1.png",
    "panam1.png",
    "ford1.png",
    "budweiser1.png",
    "budweiser2.png",
    "kraft1.png"
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("defaultsChanged"),
      name: NSUserDefaultsDidChangeNotification, object: nil)
    
    setImage()

    var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    leftSwipe.direction = .Left
    view.addGestureRecognizer(leftSwipe)
    retrieveQuotes()
  }
  
  func setNotifications() {
    let defaults = NSUserDefaults.standardUserDefaults()
    var n = defaults.stringForKey("quote_notifications")
    
    if n == nil {
      n = "3"
    }
    let quote_notification:Int = n!.toInt()!
    var interval: Int

    switch quote_notification {
      // Hourly
    case 0:
      interval = 60*60
      break
      
      // Every 3 Hours
    case 1:
      interval = 60*60*3
      break
      
      // Every 6 Hours
    case 2:
      interval = 60*60*6
      break
      
      // Daily
    case 3:
      interval = 60*60*24
      break
      
      // Weekly
    case 4:
      interval = 60*60*24*7
      break
      
      // Never
    case 5:
      interval = 0
      break
      
      // Daily
    default:
      interval = 60*60*24
      break
    }
    
    scheduleNotifications(interval)
  }

  func defaultsChanged() {
    setNotifications()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func scheduleNotifications(interval: Int) {
    
    // Validate that we have all the quotes
    if self.quotes == nil {
      return
    }

    // Delete all existing notifications
    var app:UIApplication = UIApplication.sharedApplication()
    for event in app.scheduledLocalNotifications {
      var notification = event as! UILocalNotification
      app.cancelLocalNotification(notification)
    }
    
    // If the interval provided is 0, then do just return
    if interval == 0 {
      return
    }
    
    // Schedule 64 new notifications (maximum possible)
    for i in 0...63 {
      //let date:NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval(i))
      let date:NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval(interval*i))
      var localNotification = UILocalNotification()
      let quote = quotes[Int(arc4random_uniform(UInt32(quotes.count)))]
      let text = quote["text"] as! String
      let speaker = quote["speaker"] as! String
      localNotification.fireDate = date
      localNotification.alertBody = "\(text)\n-\(speaker)"
      localNotification.timeZone = NSTimeZone.defaultTimeZone()
      UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func canBecomeFirstResponder() -> Bool {
    return true
  }

  func handleSwipes(sender:UISwipeGestureRecognizer) {
    setQuote()
    setImage()
  }

  // Set a new image
  func setImage() {
    let imageName = image_names[Int(arc4random_uniform(UInt32(image_names.count)))]
    
    backgroundView.fadeOut(completion: {
      (finished: Bool) -> Void in
      self.backgroundView.image = UIImage(named: imageName)
      self.backgroundView.fadeIn()
    })
  }
  
  // Sets a new quote. Assumes that we have the list of quotes
  func setQuote() {
    let index = Int(arc4random_uniform(UInt32(quotes.count)))
    let quote = quotes[index]

    text = quote["text"] as! String
    textView.fadeOut(completion: {
      (finished: Bool) -> Void in
      self.textView.text = self.text
      self.textView.fadeIn()
    })
  
    speaker = quote["speaker"] as! String
    speakerLabel.fadeOut(completion: {
      (finished: Bool) -> Void in
      self.speakerLabel.text = "-\(self.speaker)"
      self.speakerLabel.fadeIn()
    })
    
    season = quote["season"] as! Int
    episode = quote["episode"] as! Int
    episodeLabel.fadeOut(completion: {
      (finished: Bool) -> Void in
      self.episodeLabel.text = "Season \(self.season), Episode \(self.episode)"
      self.episodeLabel.fadeIn()
    })
    
    episodeTitle = quote["episodeTitle"] as! String
    episodeTitleLabel.fadeOut(completion: {
      (finished: Bool) -> Void in
      self.episodeTitleLabel.text = self.episodeTitle
      self.episodeTitleLabel.fadeIn()
    })
  }

  func retrieveQuotes() {
    var query = PFQuery(className: "quote")
    query.findObjectsInBackgroundWithBlock({(quotes: [AnyObject]?, error: NSError?) -> Void in
      if (error != nil) {
        NSLog("error " + error!.localizedDescription)
      } else {
        self.quotes = (quotes as? [PFObject])
        
        self.setQuote()
        
        self.setNotifications()
      }
    })
  }
  
  @IBAction func shareSheet(sender: AnyObject, quote: PFObject){
    let sendText = "\(self.text)\n-\(self.speaker)"
    
    self.shareButton.hidden = true
    UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, 0);
    self.view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
    var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    self.shareButton.hidden = false
  
    //let activityViewController : UIActivityViewController = UIActivityViewController(
    //  activityItems: [sendText], applicationActivities: nil)
    let activityViewController : UIActivityViewController = UIActivityViewController(
      activityItems: [sendText, image], applicationActivities: nil)
    
    activityViewController.excludedActivityTypes = [
      UIActivityTypePostToWeibo,
      UIActivityTypePrint,
      UIActivityTypeAssignToContact,
      UIActivityTypeCopyToPasteboard,
      UIActivityTypeSaveToCameraRoll,
      UIActivityTypeAddToReadingList,
      UIActivityTypePostToFlickr,
      UIActivityTypePostToVimeo,
      UIActivityTypePostToTencentWeibo,
      UIActivityTypeAirDrop
    ]
    
    self.presentViewController(activityViewController, animated: true, completion: nil)
  }
}

