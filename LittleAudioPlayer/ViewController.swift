//
//  ViewController.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 17.06.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyDropbox


var player: AVAudioPlayer?

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var filenames: Array<String>?
    var albums = [String: [String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let url = URL(fileURLWithPath:"/Users/roland1/Dropbox/music/boney_m/belfast.mp3")
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.rate = 1.0
            player?.volume = 1.0
            player?.delegate = self
        } catch let e {
            // couldn't load file :(
            print("ERROR \(e.localizedDescription)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func stop(_ sender: UIButton) {
        player?.stop()
    }
    
    @IBAction func play(_ sender: UIButton) {
        player?.play()
    }
    
    
    @IBAction func logonIntoDropbox(_ sender: UIButton) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
    }
    
    
    @IBAction func listDropbox(_ sender: UIButton) {
        self.filenames = []
        self.albums = [:]
        if let client = DropboxClientsManager.authorizedClient {
            // List contents of app folder
            client.files.listFolder(path: "", recursive: false).response { response, error in
                if let result = response {
                    print("Folder contents:")
                    for entry in result.entries {
                        if entry is Files.FolderMetadata {
                            print("Folder \(entry.name)")
                            self.albums[entry.name] = [String]()
                        } else {
                            print("File \(entry.name)")
                        }
                        // Check that file is a mp3 (by file extension)
                        if entry.name.hasSuffix(".mp3") {
                            // Adfile
                            self.filenames?.append(entry.name)
                        }
                    }
                } else {
                    print("Error: \(error!)")
                }
            }.response(completionHandler:   { _, _ in
                                                for (album, _) in self.albums {
                                                    _ = client.files.listFolder(path: "/\(album)", recursive: false).response {
                                                        response, error in
                                                        if let result = response {
                                                            for entry in result.entries {
                                                                if entry is Files.FileMetadata && entry.name.hasSuffix(".mp3") {
                                                                    self.albums[album]?.append(entry.name)
                                                                }
                                                            }
                                                        }else {
                                                            print("Error: \(error!)")
                                                        }
                                                    }
                                                }
                                            }
            )
        }
    }
    
    @IBAction func playFromDropbox(_ sender: UIButton) {
        if let client = DropboxClientsManager.authorizedClient {
            // Download to Data
            client.files.download(path: "/boney_m/belfast.mp3")
                .response { response, error in
                    if let response = response {
                        let responseMetadata = response.0
                        print(responseMetadata)
                        let fileContents = response.1
                        print(fileContents)
                        do {
                            player = try AVAudioPlayer(data: response.1)
                            player?.prepareToPlay()
                            player?.rate = 1.0
                            player?.volume = 1.0
                            player?.delegate = self
                        } catch let e {
                            // couldn't load file :(
                            print("ERROR \(e.localizedDescription)")
                        }

                    } else if let error = error {
                        print(error)
                    }
                }
                .progress { progressData in
                    print(progressData)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RealApp" {
        }
    }
    
    
}

