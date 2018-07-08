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

    let player: AVPlayer = AVPlayer()
    
    
    var album : String = ""
    var songs : [Song] = [] 
//    var songMap = [URL:Song]()
    
    var rightPlayAllBarButtonItem:UIBarButtonItem?
    
//    deinit {
//        player.removeObserver(self, forKeyPath: "finishedSong")
//    }
    
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
                    let path = "/\(me.album)"
                    enter(dispatchGroup)
                    client.files.listFolder(path: path, recursive: false).response {response, error in
                        // TODO show progress indicator!
                        if let result = response {
                            for entry in result.entries {
                                if entry is Files.FileMetadata && entry.name.hasSuffix(".mp3"){
                                    me.songs.append(Song(album:me.album, title:entry.name, idx:me.songs.count))
                                }
                            }
                        } else {
                            print("Error: \(error!)")
                        }
                    }.response(completionHandler: {_,_ in
                        leave(dispatchGroup)
                    })

                    // wait until all url are loaded asynchronously
                    dispatchGroup.wait()

                    self?.player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main) {
                        [weak self] time in
                        guard let strongSelf = self else { return }
                        let timeInS = CMTimeGetSeconds(time)
                        let timeHrs = Int(timeInS / (60*60))
                        let timeMin = Int(timeInS / 60) % 60
                        let timeSec = Int(timeInS) % 60
                        let timeString = String(format: "%02d:%02d:%02d", timeHrs, timeMin, timeSec)
                        let durationInS = CMTimeGetSeconds((strongSelf.player.currentItem?.duration)!)
                        var timeLabel:String
                        if !durationInS.isNaN {
                            let durationHrs = Int(durationInS / (60*60))
                            let durationMin = Int(durationInS / 60) % 60
                            let durationSec = Int(durationInS) % 60
                            
                            let durationString = String(format: "%02d:%02d:%02d", durationHrs, durationMin, durationSec)
                            timeLabel = "\(timeString) / \(durationString)"
                        } else {
                            timeLabel = "\(timeString)"
                        }
        
                        if UIApplication.shared.applicationState == .active {
                            let indexPath = strongSelf.tableView.indexPathForSelectedRow
                            let myCell = strongSelf.tableView.cellForRow(at: indexPath!)
                            myCell?.detailTextLabel?.text = timeLabel
                        } else {
                            print("Background: \(timeString)")
                        }
                    }
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                        object: nil,
                        queue: nil,
                        using: {[weak self] notification in
                            print("song played to the end")
                            if let me = self {
                                DispatchQueue.main.async {
                                    me.nextSong()
                                }
                            }
                    })
                    DispatchQueue.main.async {[weak self] in
                        if let me = self {
                            me.tableView.reloadData()
                            me.rightPlayAllBarButtonItem?.isEnabled = true
                        }
                    }
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @objc func nextTapped(sender:UIButton) {
        print("SongsTableViewController:nextTapped")
        nextSong()
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
        selectFirst()
        
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
        playSong(song)
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
    
    private func playSong(_ song:Song) {
        if let client = DropboxClientsManager.authorizedClient {
                client.files.getTemporaryLink(path: song.path())
                    .response(completionHandler:  {[weak self]
                        response, error in //print("Temp Link \(response?.link)")
                        if let me = self, let response = response {
                            let link = response.link
                            let url = URL(string:link)
                            if let url = url {
                                song.setUrl(url)
                                DispatchQueue.main.async {
                                    // see also https://github.com/neekeetab/CachingPlayerItem/issues/7
                                    let playerItem = CachingPlayerItemWithSong(withSong: song)
                                    playerItem.delegate = self
                                    me.player.replaceCurrentItem(with: playerItem)
                                    // playing moved to CachingPlayerItemDelegate:playerItemReadyToPlay
                                }
                            } else {
                                // TODO user Error Messages
                                print("ERROR cound noct fecht song")
                            }
                        } else {
                            print("ERROR getting temporary link for \(song)")
                        }
                    })
        }
    }

    private func selectFirst() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
        self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: indexPath)
    }

    
    private func nextSong() {
        if let oldIndexPath = self.tableView.indexPathForSelectedRow {
            if self.songs.count-1 > oldIndexPath.row {
                let indexPath = IndexPath(row: oldIndexPath.row+1, section: 0)
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: indexPath)
            }
        }
    }
}

func createAlbumFolderAndThan(_ name:String, continuation:(_ path:URL)->Void) {
    guard let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("failed to deterim document directory")
        return
    }
    let newDirectoryPath = documentsDirectoryURL.appendingPathComponent(name).standardizedFileURL
    var isDir:ObjCBool = true
    if FileManager.default.fileExists(atPath: newDirectoryPath.path, isDirectory: &isDir) {
        guard isDir.boolValue == true else {
            print("cannot create folder, a file withthe same name already exists")
            return
        }
    } else {
        do {
            try FileManager.default.createDirectory(at: newDirectoryPath, withIntermediateDirectories: false, attributes:nil)
        } catch {
            print("failed to create album folder, got \(error)")
            return
        }
    }
    continuation(newDirectoryPath)
}


extension SongsTableViewController:CachingPlayerItemDelegate {
    
    /// Is called when the media file is fully downloaded.
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("finished downloading, ready to save")
        DispatchQueue.global(qos: .background).async {
            if let playerItemWithSong = playerItem as? CachingPlayerItemWithSong {
                createAlbumFolderAndThan(playerItemWithSong.song.album) { (path:URL) in
                    print("saving song under \(path)")
                    do {
                        try data.write(to: path.appendingPathComponent(playerItemWithSong.song.title))
                        print("successfully saved \(playerItemWithSong.song)")
                    } catch {
                        print("failed to save \(playerItemWithSong.song), due to \(error)")
                    }
                }
            } else {
                print("failed to cast player item")
                return
            }
        }
    }

    /// Is called every time a new portion of data is received.
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        // TODO show download progress
        //print("\(bytesDownloaded)/\(bytesExpected)")
    }
    
    /// Is called after initial prebuffering is finished, means
    /// we are ready to play.
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        print("playerItemReadyToPlay")
        player.automaticallyWaitsToMinimizeStalling = false
        player.play()
    }
    
    /// Is called when the data being downloaded did not arrive in time to
    /// continue the playback.
//    func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
//
//    }
    
    /// Is called on downloading error.
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print(error)
    }
    
}

class CachingPlayerItemWithSong:CachingPlayerItem {
    private(set) var song:Song
    init(withSong song:Song) {
        assert(song.url != nil)
        self.song = song
        super.init(url: song.url!)
    }
}
