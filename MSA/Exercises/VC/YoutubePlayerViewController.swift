//
//  YoutubePlayerViewController.swift
//  MSA
//
//  Created by Nik on 27.04.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class YoutubePlayerViewController: UIViewController {

    @IBOutlet weak var playerView: WKYTPlayerView!
    var youtubeID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerView.load(withVideoId: youtubeID)
    }  
}
