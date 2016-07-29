//
//  OverlayView.swift
//  VideoPlayer
//
//  Created by Ayyakad, Aditya on 7/29/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit

class OverlayView: UIView {

    var playPauseButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
    var textLabel = UILabel()

    private let font: UIFont = .systemFontOfSize(30)
    private var textLabelFrame: CGRect { return CGRect(origin: .zero, size: CGSize(width: bounds.width, height: 75)) }

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initWithCoder not implemented")
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews {
            // if the subview is not hidden and the point is inside the subview, then pass on the point
            if !subview.hidden && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }

}

// MARK: - Setup

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
        textLabel.text = "Not Set"
        
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
