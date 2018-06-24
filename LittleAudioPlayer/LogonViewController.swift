//
//  LogonViewController.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 24.06.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import UIKit
import SwiftyDropbox

class LogonViewController: UIViewController {

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
