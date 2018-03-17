//
//  FKAlertActionView.swift
//  OOContacts
//
//  Created by 风筝 on 2018/3/16.
//  Copyright © 2018年 Doge Studio. All rights reserved.
//

import UIKit

protocol FKAlertActionViewDelegate: NSObjectProtocol {
    func backgroundPathInContainer(for actionView: FKAlertActionView) -> UIBezierPath
    func actionViewClicked(_ actionView: FKAlertActionView)
}

protocol FKAlertActionViewAppearance {
    
    var textColor: UIColor { get }
    
    var backgroundColor: UIColor { get }
    var hilightedBackgroundColor: UIColor { get }
    
    var font: UIFont { get }
    
}

class FKAlertActionView: UIView {
    
    let action: FKAlertAction
    
    weak var delegate: FKAlertActionViewDelegate?
    
    private var appearance: FKAlertActionViewAppearance!
    
    private let backgroundLayer = CAShapeLayer()
    private let label = UILabel()
    
    private struct Constant {
        static let destructiveColor = UIColor(red: 255 / 255.0,
                                              green: 71 / 255.0,
                                              blue: 71 / 255.0,
                                              alpha:1)
        static let normalColor = UIColor(red: 76 / 255.0,
                                         green: 81 / 255.0,
                                         blue: 161 / 255.0,
                                         alpha:1)
        static let cancelColor = UIColor(red: 76 / 255.0,
                                         green: 81 / 255.0,
                                         blue: 161 / 255.0,
                                         alpha:1)
        static let hilightedBackgroundColor = UIColor(red: 221 / 255.0,
                                                      green: 221 / 255.0,
                                                      blue: 221 / 255.0,
                                                      alpha:1)
        static let destructiveFont = UIFont.systemFont(ofSize: 15)
        static let normalFont = UIFont.systemFont(ofSize: 15)
        static let cancelFont = UIFont.boldSystemFont(ofSize: 15)
    }
    
    init(_ action: FKAlertAction, appearance: FKAlertActionViewAppearance) {
        self.action = action
        self.appearance = appearance
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 52))
        self.setupViews()
    }
    
    private override init(frame: CGRect) {
        self.action = FKAlertAction(title: nil, style: .default)
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.layer.addSublayer(self.backgroundLayer)
        
        self.label.text = self.action.title
        self.label.font = self.appearance.font
        self.label.textColor = self.appearance.textColor
        self.addSubview(self.label)
        self.label.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualToSuperview()
            make.center.equalTo(self)
        }
        
        self.setBackgroundColor(false, duration: 0.01)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundLayer.path = self.delegate?.backgroundPathInContainer(for: self).cgPath
    }
    
    private var isTouchInside = true
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.isTouchInside = true
        self.setBackgroundColor(true, duration: 0.05)
        self.backgroundLayer.path = self.delegate?.backgroundPathInContainer(for: self).cgPath
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        let isTouchInside = self.bounds.contains(location)
        if isTouchInside != self.isTouchInside {
            self.isTouchInside = isTouchInside
            self.setBackgroundColor(isTouchInside, duration: 0.05)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.setBackgroundColor(false, duration: 0.25)
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        if self.bounds.contains(location) {
            self.delegate?.actionViewClicked(self)
            self.action.handler?(self.action)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.setBackgroundColor(false, duration: 0.25)
    }
    
    private func setBackgroundColor(_ highlighted: Bool, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "fillColor")
        animation.toValue = highlighted
            ? self.appearance.hilightedBackgroundColor.cgColor
            : self.appearance.backgroundColor.cgColor
        animation.duration = duration
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false
        self.backgroundLayer.add(animation, forKey: "")
    }
    
}
