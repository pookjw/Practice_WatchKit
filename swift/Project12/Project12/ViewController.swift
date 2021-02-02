//
//  ViewController.swift
//  Project12
//
//  Created by Jinwoo Kim on 2/2/21.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    @IBOutlet weak var receivedData: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let complication = UIBarButtonItem(title: "Complication", style: .plain, target: self, action: #selector(sendComplicationTapped))
        let message = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(sendMessageTapped))
        let appInfo = UIBarButtonItem(title: "Context", style: .plain, target: self, action: #selector(sendAppContextTapped))
        let file = UIBarButtonItem(title: "File", style: .plain, target: self, action: #selector(sendFileTapped))
        navigationItem.leftBarButtonItems = [complication, message, appInfo, file]
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    @objc func sendMessageTapped() {
        let session = WCSession.default
        
        /// 1번
        if session.activationState == .activated {
            let data = ["text": "User info from the phone"]
            session.transferUserInfo(data)
        }
        
        /// isReachable : A Boolean value indicating whether the counterpart app is available for live messaging.
        
        /// 2번
        if session.isReachable {
            let data = ["text": "A message from phone"]
            session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        }
        
        /// 3번
        if session.isReachable {
            let data = ["text": "A message from phone"]
            session.sendMessage(data, replyHandler: { response in
                DispatchQueue.main.async {
                    self.receivedData.text = "Received response: \(response)"
                }
            }, errorHandler: nil)
        }
    }
    
    @objc func sendAppContextTapped() {
        let session = WCSession.default
        
        /// 4번
        /*
         context 전송
         - 전송이 반드시 보장된다. 당장은 아니더라도, 언젠가. Watch 쪽에서 앱이 종료된 상태에 전송되어도, 앱이 실행될 때 전송된다.
         - 실패할 경우 error handling이 가능하다.
         - 이전에 보낸 내용들이 replace 된다. 만약 서로 다른 내용의 A, B, C를 보내면, C만 보내진다.
         - reachable이 아니여도 작동한다.
         */
        if session.activationState == .activated {
            let data = ["text": "Hello from the phone \(Date())"]
            
            do {
                try session.updateApplicationContext(data)
            } catch {
                print("Alert! Updating app context failed")
            }
        }
    }
    
    @objc func sendComplicationTapped() {
        let session = WCSession.default
        
        /// 6번
        // check that we are good to send
        if session.activationState == .activated && session.isComplicationEnabled {
            // pick a random number and wrap it in a dictionary
            let randomNumber = String(Int.random(in: 0...9))
            let message = ["number": randomNumber]
            
            // transfer it across using a high-priority send
            session.transferCurrentComplicationUserInfo(message)
            
            // output how many high-priority sends we have left
            print("Attempted so send complication data. Remaining tansfers: \(session.remainingComplicationUserInfoTransfers)")
        }
    }
    
    @objc func sendFileTapped() {
        let session = WCSession.default
        
        /// 5번
        if session.activationState == .activated {
            // create a URL for where the file is/will be saved
            let fm = FileManager.default
            let sourceURL = getDocumentsDirectory().appendingPathComponent("saved_file")
            
            if !fm.fileExists(atPath: sourceURL.path) {
                // the file doesn't exist - create it now
                try? "Hello, from a phone file!".write(to: sourceURL, atomically: true, encoding: .utf8)
            }
            
            // the file exsits now; send it across the session
            session.transferFile(sourceURL, metadata: nil)
        }
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if activationState == .activated {
                if session.isWatchAppInstalled {
                    self.receivedData.text = "Watch app is installed!"
                }
            }
        }
    }
    
    /// 0번
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let text = userInfo["text"] as? String {
                self.receivedData.text = text
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
