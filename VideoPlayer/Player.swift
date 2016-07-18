//
//  Player.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/15/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit
import AVFoundation

public class Player: UIView {

    private var avPlayerLayer = AVPlayerLayer()
    private var player = AVPlayer()
    private var overlayView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public convenience init(frame: CGRect, contentURL url: NSURL) {
        self.init(frame: frame)

        setupContentURL(url)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    public override func layoutSubviews() {
        avPlayerLayer.frame = bounds
        overlayView.frame = bounds
    }

}

// MARK: - Public Setup

public extension Player {

    func setup() {
        setupPlayer()
        createOverlayView()
        addTouchObservers()
    }

    func createOverlayView() {

        overlayView = UIView(frame: bounds)
        overlayView.backgroundColor = .lightGrayColor()
        overlayView.layer.opacity = 0.5

    }

    func setupPlayer() {
        avPlayerLayer.player = player
        avPlayerLayer.frame = bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        layer.addSublayer(avPlayerLayer)
    }

    func addTouchObservers() {

        let singleFingerTap = UIGestureRecognizer(target: self, action: #selector(didTouchUpInsideView))

    }

    func setupContentURL(url: NSURL) {
        player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url))
        play()
    }

}

// MARK: - Private actions

extension Player {

    func didTouchUpInsideView() {

    }

}

// MARK: - Public Actions

public extension Player {

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

}