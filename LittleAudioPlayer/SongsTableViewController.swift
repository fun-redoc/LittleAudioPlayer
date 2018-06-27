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

func enter(_ dg:DispatchGroup) {
    print("enter")
    dg.enter()
}
func leave(_ dg:DispatchGroup) {
    print("leave")
    dg.leave()
}


class SongsTableViewController: UITableViewController {

    let player: AVQueuePlayer = AVQueuePlayer()
    
    
    var album : String = ""
    var songs : [Song] = [] 
    var songMap = [URL:Song]()
    
    var rightPlayAllBarButtonItem:UIBarButtonItem?
    
    deinit {
        player.removeObserver(self, forKeyPath: "currentItem")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        print("SongsTableViewController:viewDidLoad \(album)")
        
        let rightStopBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.nextTapped))
        rightPlayAllBarButtonItem = UIBarButtonItem(title: "PlayAll", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.playAllTapped))
        rightPlayAllBarButtonItem?.isEnabled = false
        let rightPauseBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Pause", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.pauseTapped))
        let rightResumeBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Resume", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.resumeTapped))
        self.navigationItem.setRightBarButtonItems([rightStopBarButtonItem,rightPlayAllBarButtonItem!, rightResumeBarButtonItem, rightPauseBarButtonItem ], animated: true)

        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSessionCategoryPlayAndRecord,
                with: .defaultToSpeaker)
        } catch {
            print("Failed to set audio session category.  Error: \(error)")
        }
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            if let me = self {
                let dispatchGroup = DispatchGroup()
                if let client = DropboxClientsManager.authorizedClient {
                    print("pos 1")
                    let path = "/\(me.album)"
                    print("pos 1a")
                    enter(dispatchGroup)
                    client.files.listFolder(path: path, recursive: false).response {[weak self] response, error in
                        print("pos 2")
                        // TODO show progress indicator!
                        if let me = self, let result = response {
                            print("Folder contents:")
                            for entry in result.entries {
                                if entry is Files.FileMetadata && entry.name.hasSuffix(".mp3"){
                                    me.songs.append(Song(album:me.album, title:entry.name, idx:me.songs.count))
                                }
                            }
                        } else {
                            print("Error: \(error!)")
                        }
                        }.response(completionHandler: {[weak self] _,_ in
                            print("pos 3")
                            if let me = self {
                                me.fillQueuePlayer(dispatchGroup)
                            }
                            leave(dispatchGroup)
                        }
                    )
                }
                
                print("bfore wait")
                dispatchGroup.wait()
                print("after wait")
                dispatchGroup.enter()
                DispatchQueue.main.async {[weak self] in
                    if let me = self {
                        for song in me.songs {
                            if let url = song.url {
                                print("adding player item for \(song)")
                                let playerItem = AVPlayerItem(url: url)
                                if me.player.items().count > 0 {
                                    if me.player.canInsert(playerItem, after: me.player.items().last) {
                                        me.player.insert(playerItem, after: me.player.items().last)
                                    } else {
                                        print("cannot insert 1")
                                    }
                                } else {
                                    print("player \(me.player)")
                                    if me.player.canInsert(playerItem, after: nil) {
                                        me.player.insert(playerItem, after: nil)
                                    } else {
                                        print("cannot insert 2")
                                    }
                                }
                                assert(me.player.items().count > 0)
                                assert(me.player.items().last != nil)
                                print("added player item for \(song)")
                            }
                        }
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.wait()
                //            self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 100), queue: DispatchQueue.main) {
                //                [weak self] time in
                //                guard let strongSelf = self else { return }
                //                let timeString = String(format: "%02.2f", CMTimeGetSeconds(time))
                //
                //                if UIApplication.shared.applicationState == .active {
                //                    // TODO
                //                    //strongSelf.timeLabel.text = timeString
                //                } else {
                //                    print("Background: \(timeString)")
                //                }
                //            }
                dispatchGroup.enter()
                DispatchQueue.main.async {[weak self] in
                    self?.tableView.reloadData()
                    dispatchGroup.leave()
                }
                dispatchGroup.wait()
                self?.player.addObserver(self!, forKeyPath: "currentItem", options: [.new, .initial] , context: nil)
                DispatchQueue.main.async {[weak self] in
                    self?.rightPlayAllBarButtonItem?.isEnabled = true
                }

            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem", let player = object as? AVQueuePlayer,
            let currentItem = player.currentItem?.asset as? AVURLAsset {
            print("current Item")
            let url  = currentItem.url
            if let song = self.songMap[url] {
                selectSongInTableView(song: song)
            }
        }
    }
    
    
    // MARK: - Actions
    @objc func nextTapped(sender:UIButton) {
        print("SongsTableViewController:nextTapped")
        player.advanceToNextItem()
    }
    @objc func pauseTapped(sender:UIButton) {
        print("SongsTableViewController:pauseTapped")
        player.pause()
    }
    @objc func resumeTapped(sender:UIButton) {
        print("SongsTableViewController:resumeTapped")
        player.play()
    }
    @objc func playAllTapped(sender:UIButton) {
        print("SongsTableViewController:playAllTapped")
        player.play()
    }
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("SongsTableViewController:numberOfSections")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("SongsTableViewController:numberOfRowsInSection")
        // #warning Incomplete implementation, return the number of rows
        return self.songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.songs[indexPath.row].title

        return cell
    }
    

     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
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
    
    // MARK: - private Functions
    
    private func fillQueuePlayer(_ dispatchGroup:DispatchGroup) {
        if let client = DropboxClientsManager.authorizedClient {
                for song in self.songs {
                    enter(dispatchGroup)
                        client.files.getTemporaryLink(path: song.path())
                            .response(completionHandler:  {[weak self]
                                response, error in //print("Temp Link \(response?.link)")
                                if let me = self, let response = response {
                                    let link = response.link
                                    let url = URL(string:link)
                                    if let url = url {
                                            song.setUrl(url)
                                            me.songMap[url] = song
                                            //                                        DispatchQueue.main.async {
                                            //                                            self.postContentAdded()
                                            //                                        }
                                    }
                                    leave(dispatchGroup)
                                } else {
                                    leave(dispatchGroup)
                                    print("ERROR getting temporary link for \(song)")
                                }
                            })
            }
        }
    }
    
    func selectSongInTableView(song:Song) {
        print("selectSongInTableView song no \(songs.count) , row \(song.idx)")
        let indexPath = IndexPath(row: song.idx, section: 0)
        DispatchQueue.main.async {[weak self] in
            self?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
        }
    }



}
