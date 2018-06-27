//
//  FoldersTableViewController.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 23.06.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FoldersTableViewController: UITableViewController {
    
    var albums = [String]()


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            var loaded_albums = [String]()
            if let client = DropboxClientsManager.authorizedClient {
                // List contents of app folder
                client.files.listFolder(path: "", recursive: false).response { response, error in
                    // TODO show progress indicator!
                    if let result = response {
                        print("Folder contents:")
                        for entry in result.entries {
                            if entry is Files.FolderMetadata {
                                print("Folder \(entry.name)")
                                loaded_albums.append(entry.name)
                            }
                        }
                    } else {
                        print("Error: \(error!)")
                    }
                    }.response(completionHandler:   {_, _ in
                        self!.albums = loaded_albums
                        dispatchGroup.leave()
                    }
                )
            }
            dispatchGroup.wait()
            DispatchQueue.main.async {
                self!.tableView.reloadData()
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
        return 1 
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("in sections number of albums \(self.albums.count)")
        return self.albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)

        // Configure the cell...
        print("cell with value \(self.albums[indexPath.row])")
        cell.textLabel?.text = self.albums[indexPath.row]

        return cell
    }
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
     */

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
            if let  songsTableViewController = segue.destination as? SongsTableViewController {
                songsTableViewController.album = album
            }
        }
    }

}
