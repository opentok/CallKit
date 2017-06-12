//
//  ViewController.swift
//  CallKitDemo
//
//  Created by Xi Huang on 6/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
}
