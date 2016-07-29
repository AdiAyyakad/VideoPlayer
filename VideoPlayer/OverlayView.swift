//
//  OverlayView.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/29/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit

class OverlayView: UIView {

    var isVisible: Bool {
        return !hidden
    }

    var playPauseButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
    var textLabel = UILabel()

    private let scrubberHeight: CGFloat = 80
    private let font: UIFont = .systemFontOfSize(30)
    private var textLabelFrame: CGRect {
        return CGRect(origin: .zero, size: CGSize(width: bounds.width, height: scrubberHeight/2))
    }
    private var scrubberFrame: CGRect {
        return CGRect(x: 0, y: bounds.maxY-scrubberHeight, width: bounds.width, height: scrubberHeight)
    }

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initWithCoder not implemented")
    }

    override func layoutSubviews() {

        textLabel.frame = textLabelFrame
        
    }

}

// MARK: - Private Setup

private extension OverlayView {

    func setup() {

        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        hidden = true

        setupImageView()
        setupTextLabel()

    }

    func setupImageView() {

        playPauseButton.tintColor = .whiteColor()
        changeImage(UIImage(assetIdentifier: .Play))

        playPauseButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        playPauseButton.contentMode = .Center
        playPauseButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        playPauseButton.userInteractionEnabled = true

        addSubview(playPauseButton)

    }

    func setupTextLabel() {

        textLabel.frame = textLabelFrame
        textLabel.textAlignment = .Center
        textLabel.font = font
        textLabel.textColor = .whiteColor()
        
        addSubview(textLabel)

    }

}

// MARK: - Actions

extension OverlayView {

    func changeImage(image: UIImage?) {
        playPauseButton.setImage(image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }

    func show() {
        hidden = false
    }

    func hide() {
        hidden = true
    }

}
