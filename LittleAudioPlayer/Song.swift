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
    init(album:String, title:String, idx:Int) {
        self.title = title
        self.idx = idx
        self.album = album
    }
    func path() -> String {
        return "/\(album)/\(title)"
    }
    func setUrl(_ url:URL) {
        self.url = url
    }
}
