//
//  Song.swift
//  LittleAudioPlayer
//
//  Created by roland1 on 25.06.18.
//  Copyright © 2018 rsh. All rights reserved.
//

import Foundation

class Song {
    var album:String
    var title:String
    var url: URL?
    var idx:Int
    var size:UInt64?
    init(album:String, title:String, idx:Int) {
        self.title = title
        self.idx = idx
        self.album = album
    }
    init(album:String, title:String, idx:Int, url:URL, size:UInt64) {
        self.title = title
        self.idx = idx
        self.album = album
        self.size = size
        self.url = url
    }
    func path() -> String {
        return "/\(album)/\(title)"
    }
    func setUrl(_ url:URL) {
        // TODO remenber the time
        self.url = url
    }
    var description:String {
        return "Album: \(album), Song: \(title)"
    }
}
