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
    private var isPlaying = false
    private var isOverlayVisible = false {
        didSet {
            if !isOverlayVisible {
                sleep(2)
            }
        }
    }

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

        overlayView.addSubview(UIImageView(frame: overlayView.bounds))
        addSubview(overlayView)
        sendSubviewToBack(overlayView)

    }

    func setupPlayer() {
        avPlayerLayer.player = player
        avPlayerLayer.frame = bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        layer.addSublayer(avPlayerLayer)
    }

    func addTouchObservers() {

        overlayView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(didTapOverlay)) )

    }

    func setupContentURL(url: NSURL) {
        player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url))
    }

    func showImage(named: String) {
        var imageView: UIImageView? = nil

        for subview in overlayView.subviews {
            if let imageSubview = subview as? UIImageView {
                imageView = imageSubview
            }
        }

        if imageView == nil {
            print("Error in addImage")
            return
        }

        imageView?.image = UIImage(named: named)
    }

}

// MARK: - Private actions

extension Player {

    // Executes play/pause
    func didTapOverlay() {

        print("Tapped overlay view")
        isPlaying ? pause() : play()
        isPlaying ? showImage("pause") : showImage("play")
        isOverlayVisible ? sendSubviewToBack(overlayView) : bringSubviewToFront(overlayView)

    }

    override public func sendSubviewToBack(view: UIView) {

        if view == overlayView {
            isOverlayVisible = false
        }

        super.sendSubviewToBack(view)

    }

    override public func bringSubviewToFront(view: UIView) {

        if view == overlayView {
            isOverlayVisible = true
        }

        super.bringSubviewToFront(view)
    }

}

// MARK: - Public Actions

public extension Player {

    func play() {
        isPlaying = true
        player.play()
    }

    func pause() {
        isPlaying = false
        player.pause()
    }

}