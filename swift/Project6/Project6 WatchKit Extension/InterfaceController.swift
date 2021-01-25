//
//  InterfaceController.swift
//  Project6 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/26/21.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func dictateTapped() {
        presentTextInputController(withSuggestions: nil, allowedInputMode: .plain) { result in
            guard let result = result?.first as? String else { return }
            print(result)
        }
    }
    
    @IBAction func multiInputTapped() {
        presentTextInputController(withSuggestions: ["Hacking with Swift", "Hacking with macOS", "Server-Side Swift"],
                                   allowedInputMode: .allowEmoji) { result in
            guard let result = result?.first as? String else { return }
            print(result)
        }
    }
    
    @IBAction func recordingTapped() {
        // set where we'll read and save from
        let saveURL = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        if FileManager.default.fileExists(atPath: saveURL.path) {
            // if we have a recording already, play it
            let options = [WKMediaPlayerControllerOptionsAutoplayKey: "true"]
            
            presentMediaPlayerController(with: saveURL, options: options) { didPlayToEnd, endTime, error in
                // do nothing here
            }
        } else {
            // we don't have a recording; make one
            let options: [String: Any] = [WKAudioRecorderControllerOptionsMaximumDurationKey: 60,
                                          WKAudioRecorderControllerOptionsActionTitleKey: "Done"]
            
            presentAudioRecorderController(withOutputURL: saveURL, preset: .narrowBandSpeech, options: options) { success, error in
                if success {
                    print("Saved successfully!")
                } else {
                    print(error?.localizedDescription ?? "Unknown error")
                }
            }
        }
    }
}
