//
//  DetailInterfaceController.swift
//  Project1 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/21/21.
//

import WatchKit
import Foundation


class DetailInterfaceController: WKInterfaceController {
    @IBOutlet weak var textLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let contextDictionary = context as? [String: String] {
            textLabel.setText(contextDictionary["note"] ?? "")
            
            let index = contextDictionary["index"] ?? "1"
            setTitle("Note \(index)")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
