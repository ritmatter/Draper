//
//  ViewController.swift
//  MadMen
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
  
  var text = ""
  var speaker = ""
  var season =  1
  var episode = 1
  var episodeTitle = ""
  var quotes: [PFObject]!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsChanged:",
      name: NSUserDefaultsDidChangeNotification, object: nil)

    retrieveQuotes()
    // Do any additional setup after loading the view, typically from a nib.
  }

  func defaultsChanged(note: NSNotification) {
    println("The settings changed OMMG!")
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // Schedule notifications for every 3 hours
  // Delete all prior notifications
  func scheduleNotifications() {
    // Delete all existing notifications
    var app:UIApplication = UIApplication.sharedApplication()
    for event in app.scheduledLocalNotifications {
      var notification = event as! UILocalNotification
      app.cancelLocalNotification(notification)
    }
    
    // Schedule 64 new notifications (maximum possible)
    var interval = 0
    for i in 0...63 {
      //let date:NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval(i))
      let date:NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*i))
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

  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
    if motion == .MotionShake {
      setQuote()
    }
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
        self.scheduleNotifications()
      }
    })
  }
  
  @IBAction func shareSheet(sender: AnyObject, quote: PFObject){
    let activityItem1 = "\(self.text)\n-\(self.speaker)"
    let activityItem2 = NSURL(string: "http://www.amazon.com")
    let activityViewController : UIActivityViewController = UIActivityViewController(
      activityItems: [activityItem1], applicationActivities: nil)
    
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

