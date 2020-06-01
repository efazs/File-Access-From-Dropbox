//
//  ViewController.swift
//  driveConnector
//
//  Created by Dynamite Games #1 on 13/4/20.
//  Copyright © 2020 Dynamite Games #1. All rights reserved.
//

import UIKit
import SwiftyDropbox
import AVFoundation
//1.Add the appkey in didfinishlauncing with option in appdelgate
//2.Call the authentication function if not called... This should not be called after viewDidLoad()
//3.Add a FUnction that is called if the user responds to the event of 2. The function is in Appdelegate, marked as "UrlResponse"

class ViewController: UIViewController {

    
    @IBOutlet var imageView: UIImageView!
    let client1 = DropboxClientsManager.authorizedClient
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //audioTest()
    }
    
     
    @IBAction func loginButtonPressed(_ sender: Any) {
        myButtonInControllerPressed()
    }
    func myButtonInControllerPressed() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
                                                      })
    }
    @IBAction func checkButtonPressed(_ sender: Any) {
        //audioTest()
        //check()
        //download()
        filenames = [String]()
        check2(With : "")
    }
    var filenames : [String]!
    
    var folders : [String]!
    
    func check2(With remotePath:String){
        
        
        if let authorizedClient = DropboxClientsManager.authorizedClient{
            print("Authorized")
            print(authorizedClient.files.debugDescription)
            
            
            // List contents of app folder\\Mobile_Uploads
            
            _ = authorizedClient.files.listFolder(path: remotePath).response { response, error in
                if error != nil{
                    print("Error is \(error)")
                }
                if let result = response {
                    
                    
                    for entry in result.entries {
                        print("1 :\(entry.pathDisplay)")
                        
                        if !entry.name.contains("."){
                            print(entry.name)
                            let newPath = remotePath + "/\(entry.name)/"
                            //print("New Path is \(newPath)")
                            self.check2(With: newPath)
                        }
                        // Check that file is a photo (by file extension)
                        if entry.name.hasSuffix(".mp3") || entry.name.hasSuffix(".jpeg") {
                            // Add photo!
                            print("bsl")
                            if !(self.filenames?.contains(entry.name))!{
                                self.filenames?.append(entry.name)
                            }
                            
                            print(entry.parentSharedFolderId)
                            print(entry.pathDisplay)
                        }
                    }
                    
                    
                    if self.filenames != nil{
                        print(self.filenames)
                    }
                    
//
                    
                } else {
                    print("Error: \(error!)")
                }
            }
            
            
            
        }else{
            print("Not autorized")
        }
        
        
        
        
    }
    
    
    
    func check(){
        
        filenames = [String]()
        if let authorizedClient = DropboxClientsManager.authorizedClient{
            print("Authorized")
            print(authorizedClient.files.debugDescription)
            
            
            // List contents of app folder\\Mobile_Uploads
            
            _ = authorizedClient.files.listFolder(path: "/MobileUploads/").response { response, error in
                if error != nil{
                    print("Error is \(error)")
                }
                if let result = response {
                    
                    print("Folder contents:")
                    for entry in result.entries {
                        print("1 :\(entry.pathDisplay)")
                        
                        // Check that file is a photo (by file extension)
                        if entry.name.hasSuffix(".mp3") || entry.name.hasSuffix(".jpeg") {
                            // Add photo!
                            print("bsl")
                            self.filenames?.append(entry.name)
                            print(entry.parentSharedFolderId)
                            print(entry.pathDisplay)
                        }
                    }
                    
                    
                    
                    // Display the first photo screen
                    if self.filenames != nil {
                        print(self.filenames[0])
                        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                            let fileManager = FileManager.default
                            let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            // generate a unique name for this file in case we've seen it before
                            let UUID = Foundation.UUID().uuidString
                            let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                            return directoryURL.appendingPathComponent(pathComponent)
                        }
                        
                        
                        //- = DropboxClientsManager.authorizedClient!.files.

                        _ = DropboxClientsManager.authorizedClient!.files.getThumbnail(path: "/\(self.filenames[0])", format: .png, size: .w640h480, destination: destination).response { response, error in
                            if let (metadata, url) = response {
                                if let data = try? Data(contentsOf: url) {
                                    if let image = UIImage(data: data) {
                                        print("Dowloaded file name: \(metadata.name)")
                                        
                                        // Resize image for watch (so it's not huge)
                                        let resizedImage = self.resizeImage(image)
                                        
                                        // Display image
                                        self.imageView.image = resizedImage
                                        
                                        // Save image to local filesystem app group - allows us to access in the watch
                                        let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0)
                                        //try? resizedImageData!.write(to: fileURL)
                                    }
                                }
                            } else {
                                print("Error downloading file from Dropbox: \(error!)")
                            }
                            
                        }
                    }
                    
                    // Change the size of page view controller
                    
                    
                    // Display the page view controller on top of background view controller
                    
                    
                } else {
                    print("Error: \(error!)")
                }
            }
            
            
            
        }else{
            print("Not autorized")
        }
        
        
        
        
    }
    var url : URL!
    var engine: AVAudioEngine = AVAudioEngine()
    var audioBasser : AVAudioUnitEQ!
    var player : AVAudioPlayerNode!
    var avPlayer : AVPlayer!
    var avaplayer : AVAudioPlayer!
    func audioTest(){
        
        
        let filemanager = FileManager.default
        let directory = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDirectory = directory.appendingPathComponent("MobileUploadsaaa.mp3")
        
        do{
            let audioFile = try AVAudioFile(forReading: audioDirectory)
            avPlayer = AVPlayer(url: audioDirectory)
            avaplayer = try AVAudioPlayer(contentsOf: audioDirectory)
            //avaplayer.play()
            
            player = AVAudioPlayerNode()
            audioBasser = AVAudioUnitEQ(numberOfBands: 5)
            engine.attach(audioBasser)
            engine.attach(player)
            //engine.connect(player, to: engine.mainMixerNode, format: internalFormat)
            
            //MARK: Delete the following lines and uncomment the previous one if needed
            engine.connect(player, to: audioBasser, format: nil)
            //audioEngine.connect(audioEquilizer, to: audioBasser, format: nil)
            engine.connect(audioBasser, to: engine.outputNode, format: nil)
            
            
            //MARK: This is for basser
            
            let bassbands = audioBasser.bands
            let bassfrequencies:[Float] = [20, 40, 80, 160, 200]
            let bassgains:[Float] = [12,12,12,12,12]//[0,0,0,0,0]//[12,12,12,12,12]
            
            for i in 0..<bassbands.count{
                bassbands[i].frequency = bassfrequencies[i]
                bassbands[i].bypass = false
                bassbands[i].filterType = .parametric
                
                bassbands[i].gain = bassgains[i]
                
                //print(defaultIndex)
            }
            
            print("I have come")
            engine.prepare()
            try! engine.start()
            //player.play()
            print(audioFile)
            player.scheduleFile(audioFile, at: nil, completionHandler: nil)
            player.play()
            print(try filemanager.contentsOfDirectory(at: directory, includingPropertiesForKeys: .none, options: .skipsHiddenFiles))
        }catch{
            print(error)
        }
        
        
        
        
        
    }
    func download(){
        // Download to URL
        
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = directoryURL.appendingPathComponent("MobileUploadsaaa.mp3")
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            print("I ma in")
            return destURL
        }
        if let client = DropboxClientsManager.authorizedClient{
            print("I ma in 2")
            client.files.download(path: "/MobileUploads/gain.mp3", overwrite: true, destination: destination)
                .response { response, error in
                    if let response = response {
                        print(response)
                    } else if let error = error {
                        print(error)
                    }
                }
                .progress { progressData in
                    print(progressData)
                }


            // Download to Data
            client.files.download(path: "/test/path/in/Dropbox/account")
                .response { response, error in
                    print("I ma in 3")
                    if let response = response {
                        let responseMetadata = response.0
                        print(responseMetadata)
                        let fileContents = response.1
                        print(fileContents)
                    } else if let error = error {
                        print("I ma in error")
                        print(error)
                    }
                }
                .progress { progressData in
                    print(progressData)
                    print(progressData.isFinished)
                }
        }
        
    }
    fileprivate func resizeImage(_ image: UIImage) -> UIImage {

        // Resize and crop to fit Apple watch (square for now, because it's easy)
        let maxSize: CGFloat = 200.0
        var size: CGSize?

        if image.size.width >= image.size.height {
            size = CGSize(width: (maxSize / image.size.height) * image.size.width, height: maxSize)
        } else {
            size = CGSize(width: maxSize, height: (maxSize / image.size.width) * image.size.height)
        }
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size!, !hasAlpha, scale)
        
        let rect = CGRect(origin: CGPoint.zero, size: size!)
        UIRectClip(rect)
        image.draw(in: rect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
}

