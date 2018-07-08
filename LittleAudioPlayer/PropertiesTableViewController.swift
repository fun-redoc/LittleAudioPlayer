//
//  PropertiesTableViewController.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 08.07.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import UIKit

class PropertiesTableViewController: UITableViewController {
    
    private(set) var  byteCountFormatter =  ByteCountFormatter() {
        didSet {
            byteCountFormatter.allowedUnits = .useMB
            byteCountFormatter.countStyle = .file
        }
    }

    @IBOutlet weak var cacheCountAndSizeLabale: UILabel!
    @IBAction func deleteAllCachesAction(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        DispatchQueue.global(qos: .userInteractive).async {[weak self] in
            if let me = self {
                me.getAllCachedFilesCountAndSizeAndThen { (size:UInt64, count:Int) in
                    DispatchQueue.main.async { [weak self] in
                        if let me = self {
                            // TODO make label tamplate instead hard coded
                            me.cacheCountAndSizeLabale.text = "Count \(count), Size \(me.byteCountFormatter.string(fromByteCount: Int64(size)))"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getAllCachedFilesCountAndSizeAndThen(_ continuation: (_ size:UInt64, _ count:Int)->Void) {
        // TODO gather all files
//        var size:UInt64 = 0
//        var count:Int = 0
        
        guard let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("failed to deterim document directory")
            return
        }
        if let fileEnumerator = FileManager.default.enumerator(at: documentsDirectoryURL, includingPropertiesForKeys: [.fileSizeKey]) {
            let (size, count) = fileEnumerator.reduce((UInt64(0), Int(0))) {
                (acc, file) in
                if let file = file as? URL {
                    let fileSizeInBytes = (try? FileManager.default.attributesOfItem(atPath: file.path)[.size] as? NSNumber)??.uint64Value ?? 0
                    return (acc.0 + fileSizeInBytes, acc.1 + 1)
                } else {
                    return acc
                }
            }
            continuation(size, count)
        }
    }

}
