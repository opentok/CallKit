/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	CallKit provider delegate class, which conforms to CXProviderDelegate protocol
*/

import Foundation
import UIKit
import CallKit
import AVFoundation
import OpenTok

final class ProviderDelegate: NSObject, CXProviderDelegate {

    let callManager: SpeakerboxCallManager
    private let provider: CXProvider
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?

    init(callManager: SpeakerboxCallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)

        super.init()

        provider.setDelegate(self, queue: nil)
        
        session = OTSession(apiKey: "45625732", sessionId: "1_MX40NTYyNTczMn5-MTQ5NzA0ODMzNjgzMX52ZUNjTk4zbmtZbG8wN1p4a2g4amZOQVB-fg", delegate: self)
    }

    /// The app's provider configuration, representing its CallKit capabilities
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = NSLocalizedString("CallKitDemo", comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)

//        providerConfiguration.supportsVideo = true

        providerConfiguration.maximumCallsPerCallGroup = 1

        providerConfiguration.supportedHandleTypes = [.phoneNumber]

//        if let iconMaskImage = UIImage(named: "IconMask") {
//            providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation(iconMaskImage)
//        }

//        providerConfiguration.ringtoneSound = "Ringtone.caf"

        return providerConfiguration
    }

    // MARK: Incoming Calls

    /// Use CXProvider to report the incoming call to the system
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo

        // Report the incoming call to the system
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            /*
                Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
                since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            if error == nil {
                let call = SpeakerboxCall(uuid: uuid)
                call.handle = handle

                self.callManager.addCall(call)
            }
            
            completion?(error as NSError?)
        }
    }

    // MARK: CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")

        // FIXME
//        stopAudio()

        /*
            End any ongoing calls if the provider resets, and remove them from the app's list of calls,
            since they are no longer valid.
         */
        for call in callManager.calls {
            call.endSpeakerboxCall()
        }

        // Remove all calls from the app's list of calls.
        callManager.removeAllCalls()
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Create & configure an instance of SpeakerboxCall, the app's model class representing the new outgoing call.
        let call = SpeakerboxCall(uuid: action.callUUID, isOutgoing: true)
        call.handle = action.handle.value

        // FIXME
        /*
            Configure the audio session, but do not start call audio here, since it must be done once
            the audio session has been activated by the system after having its priority elevated.
         */
//        configureAudioSession()

        /*
            Set callback blocks for significant events in the call's lifecycle, so that the CXProvider may be updated
            to reflect the updated state.
         */
        call.hasStartedConnectingDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectingDate)
        }
        call.hasConnectedDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
        }

        // Trigger the call to be started via the underlying network service.
        call.startSpeakerboxCall { success in
            if success {
                // Signal to the system that the action has been successfully performed.
                action.fulfill()

                // Add the new outgoing call to the app's list of calls.
                self.callManager.addCall(call)
            } else {
                // Signal to the system that the action was unable to be performed.
                action.fail()
            }
        }
    }

    var call: SpeakerboxCall?
    var action: CXAnswerCallAction?
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // FIXME
        /*
            Configure the audio session, but do not start call audio here, since it must be done once
            the audio session has been activated by the system after having its priority elevated.
         */
//        configureAudioSession()
        
        var error: OTError?
        session?.connect(withToken: "T1==cGFydG5lcl9pZD00NTYyNTczMiZzZGtfdmVyc2lvbj10YnBocC12MC45MS4yMDExLTA3LTA1JnNpZz0yY2FkNGYxYmU2YmY4MmRkMzQ0MWMyZjRkNWMxYWUyZmJhZTMzNTBmOnNlc3Npb25faWQ9MV9NWDQwTlRZeU5UY3pNbjUtTVRRNU56QTBPRE16Tmpnek1YNTJaVU5qVGs0emJtdFpiRzh3TjFwNGEyZzRhbVpPUVZCLWZnJmNyZWF0ZV90aW1lPTE0OTczMDAzNTUmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ5NzMwMDM1NS45NTg3MTYyMzQwMjA4OCZleHBpcmVfdGltZT0xNDk5ODkyMzU1", error: &error)
        if error != nil {
            print(error!)
        }

        // Trigger the call to be answered via the underlying network service.
//        call.answerSpeakerboxCall()
        self.call = call

        // Signal to the system that the action has been successfully performed.
//        action.fulfill()
        self.action = action
    }

    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // Stop call audio whenever ending the call.
//        stopAudio()
        if let publisher = publisher {
            var error: OTError?
            session?.unpublish(publisher, error: &error)
            if error != nil {
                print(error!)
            }
        }
        
        if let subscriber = subscriber {
            var error: OTError?
            session?.unsubscribe(subscriber, error: &error)
            if error != nil {
                print(error!)
            }
        }

        // Trigger the call to be ended via the underlying network service.
        call.endSpeakerboxCall()

        // Signal to the system that the action has been successfully performed.
        action.fulfill()

        // Remove the ended call from the app's list of calls.
        callManager.removeCall(call)
    }

    // FIXME
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // Update the SpeakerboxCall's underlying hold state.
        call.isOnHold = action.isOnHold

        // Stop or start audio in response to holding or unholding the call.
        if call.isOnHold {
//            stopAudio()
            if let publisher = publisher {
                publisher.publishAudio = false
            }
            if let subscriber = subscriber {
                subscriber.subscribeToAudio = false
            }
        } else {
//            startAudio()
            if let publisher = publisher {
                publisher.publishAudio = true
            }
            if let subscriber = subscriber {
                subscriber.subscribeToAudio = true
            }
        }

        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Timed out \(#function)")

        // React to the action timeout if necessary, such as showing an error UI.
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Received \(#function)")

        // FIXME
        // Start call audio media, now that the audio session has been activated after having its priority boosted.
//        startAudio()
        if let publisher = publisher, let audioDevice = OTDefaultAudioDeviceWithVolumeControl.sharedInstance() {
            
            audioDevice.customAudioSession = audioSession
            OTAudioDeviceManager.setAudioDevice(audioDevice)
            
            var error: OTError?
            session?.publish(publisher, error: &error)
            if error != nil {
                print(error!)
            }
        }
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Received \(#function)")

        /*
             Restart any non-call related audio now that the app's audio session has been
             de-activated after having its priority restored to normal.
         */
        
    }
}

extension ProviderDelegate: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print(#function)
        
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        settings.audioTrack = true
        settings.videoTrack = false
        publisher = OTPublisher.init(delegate: self, settings: settings)
        
        self.call?.answerSpeakerboxCall()
        self.action?.fulfill()
    }
    
    func sessionDidDisconnect(_ session: OTSession){
        print(#function)
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print(#function, error)
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print(#function)
        subscriber = OTSubscriber.init(stream: stream, delegate: self)
        subscriber?.subscribeToVideo = false
        if let subscriber = subscriber {
            var error: OTError?
            session.subscribe(subscriber, error: &error)
            if error != nil {
                print(error!)
            }
        }
    }
    
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print(#function)
    }
}

extension ProviderDelegate: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print(#function)
    }
}

extension ProviderDelegate: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print(#function)
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print(#function)
    }
}
