//
//  ViewController.swift
//  Comunication Analytics
//
//  Created by Mateo Badillo on 3/8/16.
//  Copyright (c) 2016 Mateo Badillo. All rights reserved.
//

import UIKit
import WatsonDeveloperCloud
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var resultText: UITextView!
    
    @IBOutlet weak var btnRecord: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioURL:NSURL!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.btnRecord.enabled = true
                    } else {
                        print("No permission granted")
                    }
                }
            }
        } catch {
                    print("error recording audio")
        }
        
    }
    
    
    // Recording Audio
    
    func startRecording() {
        //let audioFilename = getDocumentsDirectory().stringByAppendingPathComponent("recording.m4a")
        //audioURL = NSURL(fileURLWithPath: audioFilename)
        audioURL = NSURL(fileURLWithPath: "\(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])/SpeechToTextRecording.wav")

        print(audioURL)
        
        let settings = [
            
            AVSampleRateKey: NSNumber(float: 44100.0),
            AVNumberOfChannelsKey: NSNumber(int: 1)
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            btnRecord.setTitle("Tap to Stop", forState: .Normal)
        } catch {
            finishRecording(success: false)
        }
    }

    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            btnRecord.setTitle("Tap to Re-record", forState: .Normal)
        } else {
            btnRecord.setTitle("Tap to Record", forState: .Normal)
            // recording failed :(
        }
    }
    
    @IBAction func recordTapped() {
        if audioRecorder == nil {
            startRecording()
            //
            // cambiar boton a parar
            
            print("Recording")
        } else {
            finishRecording(success: true)
            print("finished")
            // cambiar botón a watson
            initializeService1()
            print("Watson initialized")
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    /////////
    
    // Speech to text
    
    func initializeService1(){
        let service = SpeechToText(username: "ae4e162f-b542-4e75-ae3f-1966814a565d", password: "ZFHjq88WKQV3")
        
        
        let data = NSData(contentsOfURL: audioURL)
        
        
        if let data = data {
            
            
            
            service.transcribe(data , format: .WAV, completionHandler: {
                
                response, error in
                
                // code here
                
                let resultT = response?.transcription()
                
           
                self.resultText.text = resultT
                
                // cambiar botón a watson cargando 2
                
                // Tone Analysis
                

                //let token = TokenAuthenticationStrategy(token : <b1ccaaa323cb7145ff0159a1218a3c78e70ffaf2>)
                //let alchemyLanguageInstance = AlchemyLanguage(tokenAuthenticationStrategy: token)
                let alchemyLanguageInstance = AlchemyLanguage(apiKey: "b1ccaaa323cb7145ff0159a1218a3c78e70ffaf2")
                
               /* alchemyLanguageInstance.getEntities(requestType: .Text,
                    html: nil,
                    url: nil,
                    text: resultText) {
                        
                        (error, SentimentResponse) in
                        
                        // returned data is inside "entities" in this case
                        // code here
                        
                        print(SentimentResponse)
                        
                        
                }
                
                */
                
                alchemyLanguageInstance.getSentiment(requestType: .Text, html: nil, url: nil, text: "im really sad"){
                 
                    (error, SentimentResponse) in
                    
                    print(SentimentResponse)
                    
                }
                
                
                
            }
            )
        }
        
        

        
    }
    
    

}

