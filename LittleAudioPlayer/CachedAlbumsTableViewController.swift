//
//  CachedAlbumsTableViewController.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 08.07.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import UIKit

class CachedAlbumsTableViewController: UITableViewController {
    
    var albums:[String] = []
    
    var documentsDirectoryURL:URL?
    
    
    private(set) var  byteCountFormatter =  ByteCountFormatter() {
        didSet {
            byteCountFormatter.allowedUnits = .useMB
            byteCountFormatter.countStyle = .file
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
//        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
//            if let me = self,
              if let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                // check if the url is a directory
                var bool: ObjCBool = false
                if FileManager.default.fileExists(atPath: documentsDirectoryURL.path, isDirectory: &bool),bool.boolValue  {
                    print("url is a folder url")
                    // lets get the folder files
                    do {
                        let files = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: [.fileSizeKey], options: [])
                        for file in files {
                            albums.append(file.lastPathComponent)
                        }
                    } catch {
                        print(error)
                    }
                }
              }
//        }
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
        return albums.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumRow", for: indexPath)

        // Configure the cell...
        let album = albums[indexPath.row]
        cell.textLabel?.text = albums[indexPath.row]
        if let documentsDirectoryURL = documentsDirectoryURL {
            DispatchQueue.global(qos: .default).async {
                do {
                    let albumPath = documentsDirectoryURL.appendingPathComponent(album).standardizedFileURL
                    let files = try FileManager.default.contentsOfDirectory(at: albumPath, includingPropertiesForKeys: [.fileSizeKey], options: [])
                    var fileSizeInBytes:UInt64 = 0
                    for file in files {
                        fileSizeInBytes += (try? FileManager.default.attributesOfItem(atPath: file.path)[.size] as? NSNumber)??.uint64Value ?? 0
                        DispatchQueue.main.async {[weak self] in
                            if let byteCountFormater = self?.byteCountFormatter {
                                let sizeString = byteCountFormater.string(fromByteCount: Int64(fileSizeInBytes))
                                cell.detailTextLabel?.text = "songs: \(files.count), size: \(sizeString)"
                            } else {
                                cell.detailTextLabel?.text = "songs: \(files.count)"
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }

        return cell
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let senderCell = sender as? UITableViewCell, let album = senderCell.textLabel?.text {
            if let  songsTableViewController = segue.destination as? CachedSongsTableViewController {
                songsTableViewController.album = album
            }
        }
    }

}
