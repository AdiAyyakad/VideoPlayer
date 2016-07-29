//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/15/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var player: PlayerView!

    var url: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayer()
    }

}

// MARK: - Setup

extension ViewController {

    func setupPlayer() {
        url = NSBundle.mainBundle().URLForResource("SmallRocky", withExtension: "mp4")
        player.addContentURL(url)
        player.play()
    }

}