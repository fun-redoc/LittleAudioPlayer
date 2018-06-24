//
//  SongsTableViewController.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 23.06.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import UIKit
import SwiftyDropbox
import AVFoundation



class SongsTableViewController: UITableViewController, AVAudioPlayerDelegate {

    var player: AVAudioPlayer?
    
    var album : String = ""
    var songs : [String] = [] {
        didSet {
            print(" songs did set \(songs)")
        }
    }
    
    var songQueue = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        print("SongsTableViewController:viewDidLoad \(songs)")

        var rightStopBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Stop", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.stopTapped))
        var rightPlayAllBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "PlayAll", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.playAllTapped))
        var rightPauseBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Pause", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.pauseTapped))
        var rightResumeBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Resume", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.resumeTapped))
        self.navigationItem.setRightBarButtonItems([rightStopBarButtonItem,rightPlayAllBarButtonItem, rightResumeBarButtonItem, rightPauseBarButtonItem ], animated: true)
        
        
    }
    
    @objc func stopTapped(sender:UIButton) {
        print("SongsTableViewController:stopTapped")
        player?.stop()
    }
    @objc func pauseTapped(sender:UIButton) {
        print("SongsTableViewController:stopTapped")
        player?.pause()
    }
    @objc func resumeTapped(sender:UIButton) {
        print("SongsTableViewController:stopTapped")
        player?.play()
    }
    @objc func playAllTapped(sender:UIButton) {
        print("SongsTableViewController:playAllTapped")
        songQueue = songs.map { $0.copy() } as! [String]
        if !songQueue.isEmpty {
            selectSongInTableView(song: songQueue[0])
            play(album: album, song: songQueue[0])
        }
    }
    
    func selectSongInTableView(song:String) {
        if let idx = songs.index(of: song) {
            let indexPath = IndexPath(row: idx, section: 0)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
            //self.tableView(self.tableView, didSelectRowAtIndexPath: indexPath)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")
        if !songQueue.isEmpty && songQueue.count > 0 {
            songQueue.remove(at: 0)
            if !songQueue.isEmpty && songQueue.count > 0 {
                selectSongInTableView(song: songQueue[0])
                play(album: album, song: songQueue[0])
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("SongsTableViewController:numberOfSections \(songs)")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.songs[indexPath.row]

        return cell
    }
    
    private func play(album:String, song:String, completion: (() -> Void)? = nil) {
        // TODO show progress
        if let client = DropboxClientsManager.authorizedClient {
            // Download to Data
            client.files.download(path: "/\(album)/\(song)")
                .response { response, error in
                    if let response = response {
                        let responseMetadata = response.0
                        print(responseMetadata)
                        let fileContents = response.1
                        print(fileContents)
                        do {
                            self.player = try AVAudioPlayer(data: response.1)
                            self.player?.prepareToPlay()
                            self.player?.rate = 1.0
                            self.player?.volume = 1.0
                            self.player?.delegate = self
                            self.player?.play()
                        } catch let e {
                            // couldn't load file :(
                            print("ERROR \(e.localizedDescription)")
                        }
                        
                    } else if let error = error {
                        print(error)
                    }
                }.response(completionHandler: { _, _ in
                    if let cfn = completion {
                        cfn()
                    }
                })
                .progress { progressData in
                    print(progressData)
            }
        }
    }
    
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
        play(album: album, song: song)
     }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
