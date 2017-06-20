//
//  ViewController.swift
//  CallKitDemo
//
//  Created by Xi Huang on 6/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallsChangedNotification(notification:)), name: SpeakerboxCallManager.CallsChangedNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func receiveCallLucas(_ sender: Any) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        appdelegate.displayIncomingCall(uuid: UUID(), handle: "Jane Appleseed")
    }
    
    
    @IBAction func callLucas(_ sender: Any) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        appdelegate.callManager.startCall(handle: "Jane Appleseed")
    }
    
    func handleCallsChangedNotification(notification: NSNotification) {
        
    }
    
    @IBAction func endCall(_ sender: Any) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        /*
         End any ongoing calls if the provider resets, and remove them from the app's list of calls,
         since they are no longer valid.
         */
        for call in appdelegate.callManager.calls {
            appdelegate.callManager.end(call: call)
        }
    }
    
}
