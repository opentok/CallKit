//
//  AppDelegate.swift
//  CallKitDemo
//
//  Created by Xi Huang on 6/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit
import PushKit
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let callManager = SpeakerboxCallManager()
    var prodviderDelegate: ProviderDelegate?

    // Trigger VoIP registration on launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        prodviderDelegate = ProviderDelegate(callManager: callManager)
        
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        return true
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        
        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
            let handle = payload.dictionaryPayload["handle"] as? String,
            let uuid = UUID(uuidString: uuidString) {
            
            displayIncomingCall(uuid: uuid, handle: handle)
        }
    }
    
    func displayIncomingCall(uuid: UUID, handle: String) {
        
        // Post local notification for incoming call
        prodviderDelegate?.reportIncomingCall(uuid: uuid, handle: handle)
    }
}
