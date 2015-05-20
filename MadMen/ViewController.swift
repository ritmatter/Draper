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
    retrieveQuotes()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // Sets a new quote. Assumes that we have the list of quotes
  func setQuote() {
    let index = Int(arc4random_uniform(UInt32(quotes.count)))
    let quote = quotes[index]
    println(quote)

    text = quote["text"] as! String
    println(text)
    textView.text = text
    
    speaker = quote["speaker"] as! String
    speakerLabel.text = speaker
    
    season = quote["season"] as! Int
    episode = quote["episode"] as! Int
    episodeLabel.text = "Season \(season), Episode \(episode)"
    
    episodeTitle = quote["episodeTitle"] as! String
    episodeTitleLabel.text = episodeTitle
  }

  func retrieveQuotes() {
    var query = PFQuery(className: "quote")
    query.findObjectsInBackgroundWithBlock({(quotes: [AnyObject]?, error: NSError?) -> Void in
      if (error != nil) {
        NSLog("error " + error!.localizedDescription)
      } else {
        self.quotes = (quotes as? [PFObject])
        
        self.setQuote()
      }
    })
  }
}

