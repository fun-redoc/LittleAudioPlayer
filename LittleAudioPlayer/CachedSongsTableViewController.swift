//
//  CachedSongsTableViewController.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 08.07.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import UIKit
import AVFoundation

class CachedSongsTableViewController: UITableViewController {
    
    var album:String = ""
    var songs:[Song] = []
    
    let player = AVPlayer()
    
    var playAllBarButtonItem:UIBarButtonItem?
    var playNextButtonItem:UIBarButtonItem?
    var playPrevButtonItem:UIBarButtonItem?
    var playPauseButtonItem:UIBarButtonItem?
    var playResumeButtonItem:UIBarButtonItem?

    
    private(set) var  byteCountFormatter =  ByteCountFormatter() {
        didSet {
            byteCountFormatter.allowedUnits = .useMB
            byteCountFormatter.countStyle = .file
        }
    }
    
    private func playSong(_ player:AVPlayer, _ song:Song) {
        DispatchQueue.main.async {
            if let url = song.url {
                let playerItem = AVPlayerItem(url: url)
                player.replaceCurrentItem(with: playerItem)
                player.automaticallyWaitsToMinimizeStalling = false
                player.play()
            }
        }
    }


    private func getSongs() {
        guard let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("failed to deterim document directory")
            return
        }
        let albumPath = documentsDirectoryURL.appendingPathComponent(album).standardizedFileURL
        var isDir:ObjCBool = true
        if FileManager.default.fileExists(atPath: albumPath.path, isDirectory: &isDir) {
            guard isDir.boolValue == true else {
                print("album Folder \(album) is not a directory")
                return
            }
            do {
                let files = try FileManager.default.contentsOfDirectory(at: albumPath, includingPropertiesForKeys: [.fileSizeKey], options: [])
                for (i,file) in files.enumerated() {
                    let fileSizeInBytes = (try? FileManager.default.attributesOfItem(atPath: file.path)[.size] as? NSNumber)??.uint64Value ?? 0
                    let song = Song(album: album, title: file.lastPathComponent, idx: i, url: file, size: fileSizeInBytes)
                    songs.append(song)
                }
            } catch {
                print(error)
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main) {
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
                    let indexPath = me.tableView.indexPathForSelectedRow
                    let myCell = me.tableView.cellForRow(at: indexPath!)
                    DispatchQueue.main.async { [weak self] in
                        if let me = self, let row = indexPath?.row, let size = me.songs[row].size {
                            myCell?.detailTextLabel?.text = me.byteCountFormatter.string(fromByteCount: Int64(size))
                        }
                        me.nextSong()
                    }
                }
        })

        
        playAllBarButtonItem = UIBarButtonItem(title: "PlayAll", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CachedSongsTableViewController.playAllTapped))
        playAllBarButtonItem?.isEnabled = true

        
        getSongs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cachedSongCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = songs[indexPath.row].title
        if let size = songs[indexPath.row].size {
            cell.detailTextLabel?.text = byteCountFormatter.string(fromByteCount: Int64(size))
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
        playSong(player, song)
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
    
    // MARK: - Player Actions
    @objc func playAllTapped(sender:UIButton) {
        selectFirst()
    }
    @objc func nextTapped(sender:UIButton) {
        nextSong()
    }
    @objc func pauseTapped(sender:UIButton) {
        player.pause()
    }
    @objc func resumeTapped(sender:UIButton) {
        player.play()
    }

    
    // MARK: - Helpers
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
