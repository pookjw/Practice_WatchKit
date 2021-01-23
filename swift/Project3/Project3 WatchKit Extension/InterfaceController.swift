//
//  InterfaceController.swift
//  Project3 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/23/21.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        testUserDefaults()
        testUserDefaults()
        
        testKeychain()
        testKeychain()
        
        testFile()
        testFile()
    }
    
    func testUserDefaults() {
        // get hold of our app's user defaults
        let defaults = UserDefaults.standard
        
        if let contents = defaults.string(forKey: "shared_default") {
            // save data was found!
            print("Reading from defaults")
            print(contents)
        } else {
            // no saved data - create it!
            print("Writing to defaults")
            defaults.set("This is the saved default", forKey: "shared_default")
        }
    }

    func testKeychain() {
        let keychain = KeychainWrapper.standard
        
        if let contents = keychain.string(forKey: "shared_keychain") {
            print("Reading from keychain")
            print(contents)
        } else {
            print("Writing to keychain")
            keychain.set("This is the saved keychain.", forKey: "shared_keychain")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func testFile() {
        let saveURL = getDocumentsDirectory().appendingPathComponent("shared_file")
        
        if let contents = try? String(contentsOf: saveURL) {
            print("Reading from file")
            print(contents)
        } else {
            print("Writing to file")
            try? "This is the saved file".write(to: saveURL, atomically: true, encoding: .utf8)
        }
    }
}
