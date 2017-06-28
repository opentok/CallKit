//
//  ViewController.swift
//  CallKitDemo
//
//  Created by Xi Huang on 6/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    final let displayCaller = "Jane Appleseed"
    final let makeACallText = "Make a call"
    final let simulateIncomingCallText = "Simulate Incoming Call"
    final let simulateIncomingCallThreeSecondsText = "Simulate Incoming Call after 3 seconds(Background mode)"
    final let endCallText = "End call"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallsChangedNotification(notification:)), name: SpeakerboxCallManager.CallsChangedNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var simulateCallButton: UIButton!
    @IBOutlet weak var simulateCallButton2: UIButton!
    
    @IBAction func receiveCallLucas(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        if simulateCallButton.titleLabel?.text == simulateIncomingCallText {
            appdelegate.displayIncomingCall(uuid: UUID(), handle: displayCaller)
            sender.setTitle(endCallText, for: .normal)
            sender.setTitleColor(.red, for: .normal)
            callButton.isEnabled = false
            simulateCallButton2.isEnabled = false
        }
        else {
            endCall()
            sender.setTitle(simulateIncomingCallText, for: .normal)
            sender.setTitleColor(.blue, for: .normal)
            callButton.isEnabled = true
            simulateCallButton2.isEnabled = true
        }
    }
    
    @IBAction func receiveCallLucasAfterThreeSeconds(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        if sender.titleLabel?.text == simulateIncomingCallThreeSecondsText {
            
            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                appdelegate.displayIncomingCall(uuid: UUID(), handle: "Lucas Huang", hasVideo: false) { _ in
                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                }
            }
            sender.setTitle(endCallText, for: .normal)
            sender.setTitleColor(.red, for: .normal)
            callButton.isEnabled = false
            simulateCallButton.isEnabled = false
        }
        else {
            endCall()
            sender.setTitle(simulateIncomingCallThreeSecondsText, for: .normal)
            sender.setTitleColor(.blue, for: .normal)
            callButton.isEnabled = true
            simulateCallButton.isEnabled = true
        }
    }
    
    @IBAction func callButtonPressed(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        if sender.titleLabel?.text == makeACallText {
            appdelegate.callManager.startCall(handle: displayCaller)
            sender.setTitle(endCallText, for: .normal)
            sender.setTitleColor(.red, for: .normal)
            simulateCallButton.isEnabled = false
            simulateCallButton2.isEnabled = false
        }
        else {
            endCall()
            sender.setTitle(makeACallText, for: .normal)
            sender.setTitleColor(.blue, for: .normal)
            simulateCallButton.isEnabled = true
            simulateCallButton2.isEnabled = true
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        endCall()
        callButton.setTitle(makeACallText, for: .normal)
        callButton.setTitleColor(.blue, for: .normal)
        callButton.isEnabled = true
        simulateCallButton.setTitle(simulateIncomingCallText, for: .normal)
        simulateCallButton.setTitleColor(.blue, for: .normal)
        simulateCallButton.isEnabled = true
        simulateCallButton2.setTitle(simulateIncomingCallThreeSecondsText, for: .normal)
        simulateCallButton2.setTitleColor(.blue, for: .normal)
        simulateCallButton2.isEnabled = true
    }
    
    
    func handleCallsChangedNotification(notification: NSNotification) {
        
    }
    
    fileprivate func endCall() {
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
