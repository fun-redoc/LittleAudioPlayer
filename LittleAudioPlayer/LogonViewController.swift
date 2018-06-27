//
//  LogonViewController.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 24.06.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import UIKit
import SwiftyDropbox
import AVFoundation

class LogonViewController: UIViewController {

    var player:AVQueuePlayer?
    var playerItem:AVPlayerItem?

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func adjustButtonState() {
        DispatchQueue.main.async {
            if let _ = DropboxClientsManager.authorizedClient {
                self.loginButton.isEnabled = false
                self.logoutButton.isEnabled = true
                self.startPlayerButton.isEnabled = true
            } else {
                self.loginButton.isEnabled = true
                self.logoutButton.isEnabled = false
                self.startPlayerButton.isEnabled = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var startPlayerButton: UIButton!
    
    @IBAction func logout(_ sender: UIButton) {
        if let client = DropboxClientsManager.authorizedClient {
            DropboxClientsManager.unlinkClients()
            adjustButtonState()
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        logonIntoDropbox()
        //adjustButtonState()
    }
    
    @IBAction func startPlayer(_ sender: UIButton) {
    }
    
    @IBAction func playItTest(_ sender: UIButton) {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSessionCategoryPlayAndRecord,
                with: .defaultToSpeaker)
        } catch {
            print("Failed to set audio session category.  Error: \(error)")
        }
        //let link = "https://dl.dropboxusercontent.com/apitl/1/AADiQoLhmNiA0S8Cgm4hF9tU39lg6nt4O1yHifybtm3gZTQmXeSO4RTiNgbJ15MLiGNltrbD0k66dYiDBp53ONN8WIc0sbM82IhvRr3td4aeC_OifHzcOVMY24jV4R73eFdwzc8TcZMaOhIZNQrxhRj2Qx3MobpkzE6bJ67Qq9raFb8U7bGo4qoHR8fRcV0XcZbW6ZR3_R5xACNN_8P1YnwqpXvCEa5qEi6FcZfmwqfums3otMz74Mfo06zC3u__UlgcZrLaCGc8EBX8ru5lZAU6"
        let link = "https://dl.dropboxusercontent.com/apitl/1/AAAYrLeo8uUsYoIwH1XJxh5hlqjz3U8wiqmfyi_aFPDpaW37hrFrOmx0uPQMtuPLMnlyNc_yjV9VihVaO0ZnmirNt7qlV4ap03kherOyyH4lM9Iib1-60Fxz4OquITQ5tlLRsIM_zu_3CwJ79uuz2RPicvjSluXT2Am48ocCWGu_OpImS3L4G9bhWZGEYD9vH9ap_n_h9il-99-uGmckRe-Vn1aFfX6YPeojFe0mGKNaShV0-57iyMKeOPdSVPk80qNgHJiRk4yO7TYIcX0ANMxNbAWrYNOrB9O10eVgZQYtLQ"
        if let url = URL(string: link) {
            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
            self.player = AVQueuePlayer(items: [playerItem])
            if let player = self.player {
                player.actionAtItemEnd = .advance
                //            player.addObserver(self, forKeyPath: "currentItem", options: [.new, .initial] , context: nil)
                player.play()
            } else {
                print("Failed to Start Player")
            }
        }
    }
    func logonIntoDropbox( ) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
