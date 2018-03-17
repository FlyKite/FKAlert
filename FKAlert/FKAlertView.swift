//
//  FKAlertView.swift
//  OOContacts
//
//  Created by 风筝 on 2018/3/16.
//  Copyright © 2018年 Doge Studio. All rights reserved.
//

import UIKit
import SnapKit

class FKAlertView: UIView, FKAnimatedAlertView {
    
    var title: String? {
        didSet {
            self.updateTitle()
        }
    }
    
    var message: String? {
        didSet {
            self.updateMessage()
        }
    }
    
    private(set) var actions: [FKAlertAction] = []
    
    private var destructiveActions: [FKAlertAction] = []
    private var defaultActions: [FKAlertAction] = []
    private var cancelAction: FKAlertAction?
    
    var dismiss: (() -> Void)?
    
    private struct Constant {
        static let titleViewColor = UIColor(red: 76 / 255.0,
                                            green: 81 / 255.0,
                                            blue: 161 / 255.0,
                                            alpha:1)
        static let titleColor = UIColor(red: 250 / 255.0,
                                        green: 250 / 255.0,
                                        blue: 250 / 255.0,
                                        alpha:1)
        static let messageColor = UIColor(red: 3 / 255.0,
                                          green: 3 / 255.0,
                                          blue: 3 / 255.0,
                                          alpha:1)
        static let separatorColor = UIColor(red: 221 / 255.0,
                                            green: 221 / 255.0,
                                            blue: 221 / 255.0,
                                            alpha:1)
        static let animationDuration: TimeInterval = 0.25
        static let yOffset: CGFloat = -50
        static let cornerRadius: CGFloat = 4
        static let separatorHeight: CGFloat = 1 / UIScreen.main.scale
        static let actionViewHeight: CGFloat = 52
        static let maxHorizontalActionCount = 2
    }
    
    // MARK: Views
    private let titleView = FKAlertTitleView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let separatorLine = UIView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = Constant.cornerRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize.zero
        
        self.titleView.addSubview(self.titleLabel)
        self.addSubview(self.titleView)
        self.addSubview(self.messageLabel)
        self.addSubview(self.separatorLine)
        self.scrollView.addSubview(self.stackView)
        self.addSubview(self.scrollView)
        
        self.titleView.backgroundColor = Constant.titleViewColor
        self.titleView.isHidden = true
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 16)
        self.titleLabel.textColor = Constant.titleColor
        self.titleLabel.textAlignment = .center
        
        self.messageLabel.font = UIFont.systemFont(ofSize: 14)
        self.messageLabel.textColor = Constant.messageColor
        self.messageLabel.isHidden = true
        
        self.separatorLine.backgroundColor = Constant.separatorColor
        self.separatorLine.isHidden = true
        
        self.stackView.axis = .horizontal
        self.stackView.alignment = .fill
        self.stackView.distribution = .equalSpacing
        
        self.titleView.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(self)
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleView).offset(26)
            make.right.equalTo(self.titleView).offset(-26)
            make.top.equalTo(self.titleView).offset(18)
            make.bottom.equalTo(self.titleView).offset(-14)
        }
        self.messageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(26)
            make.right.equalTo(self).offset(-26)
            make.top.equalTo(self.titleView.snp.bottom).offset(18)
        }
        self.separatorLine.snp.makeConstraints { (make) in
            make.top.equalTo(self.messageLabel.snp.bottom)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(Constant.separatorHeight)
        }
        self.scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.separatorLine.snp.bottom)
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(0)
        }
        self.stackView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(0)
        }
    }
    
    private func updateTitle() {
        if let title = self.title, title.count > 0 {
            self.titleView.isHidden = false
            self.titleLabel.text = title
            self.messageLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(self).offset(26)
                make.right.equalTo(self).offset(-26)
                make.top.equalTo(self.titleView.snp.bottom).offset(18)
            })
        } else {
            self.titleView.isHidden = true
            self.messageLabel.snp.remakeConstraints({ (make) in
                make.left.equalToSuperview().offset(26)
                make.right.equalToSuperview().offset(-26)
                make.top.equalToSuperview().offset(18)
            })
        }
        self.updateSeparator()
        self.layoutIfNeeded()
    }
    
    private func updateMessage() {
        if let message = self.message, message.count > 0 {
            self.messageLabel.isHidden = false
            self.messageLabel.text = message
            self.separatorLine.isHidden = self.actions.count == 0
        } else {
            self.messageLabel.isHidden = true
            self.separatorLine.isHidden = true
        }
        self.updateSeparator()
        self.layoutIfNeeded()
    }
    
    private func updateSeparator() {
        self.separatorLine.snp.remakeConstraints({ (make) in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(Constant.separatorHeight)
            if !self.messageLabel.isHidden {
                make.top.equalTo(self.messageLabel.snp.bottom).offset(18)
            } else if !self.titleView.isHidden {
                make.top.equalTo(self.titleView.snp.bottom).offset(-Constant.separatorHeight)
            } else {
                make.top.equalToSuperview().offset(-Constant.separatorHeight)
            }
        })
        if !self.messageLabel.isHidden {
            if self.actions.count > 0 {
                self.separatorLine.isHidden = false
            } else {
                self.separatorLine.isHidden = true
            }
        } else {
            self.separatorLine.isHidden = true
        }
    }
    
    func add(to view: UIView) {
        view.addSubview(self)
        
        self.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.center.equalTo(view.safeAreaLayoutGuide.snp.center).offset(Constant.yOffset).priority(400)
                make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(30)
                make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-30)
                make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(20)
                make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.center.equalTo(view.snp.center).offset(Constant.yOffset).priority(400)
                make.left.equalTo(view.snp.left).offset(30)
                make.right.equalTo(view.snp.right).offset(-30)
                make.top.greaterThanOrEqualTo(view.snp.top).offset(20)
                make.bottom.lessThanOrEqualTo(view.snp.bottom).offset(-20)
            }
        }
    }
    
    func addAction(_ action: FKAlertAction) {
        if self.cancelAction != nil && action.style == .cancel {
            fatalError("Cancel action already exists.")
        }
        if let message = self.message, message.count > 0 {
            self.separatorLine.isHidden = false
        }
        
        let appearance = FKAlertViewActionAppearance.appearance(for: action)
        let actionView = FKAlertActionView(action, appearance: appearance)
        actionView.delegate = self
        
        var index: Int
        switch action.style {
        case .destructive:
            index = self.destructiveActions.count
            self.destructiveActions.append(action)
        case .default:
            index = (self.destructiveActions.count + self.defaultActions.count)
            self.defaultActions.append(action)
        case .cancel:
            index = (self.destructiveActions.count + self.defaultActions.count)
            self.cancelAction = action
        }
        
        if self.actions.count == Constant.maxHorizontalActionCount {
            // Change axis to vertical when third action was inserted
            self.stackView.axis = .vertical
            for view in self.stackView.arrangedSubviews {
                if let separator = view as? FKAlertActionViewSeparator {
                    separator.snp.remakeConstraints({ (make) in
                        make.height.equalTo(Constant.separatorHeight)
                    })
                } else if let actionView = view as? FKAlertActionView {
                    actionView.snp.remakeConstraints({ (make) in
                        make.height.equalTo(Constant.actionViewHeight)
                    })
                }
            }
        }
        
        if index == self.actions.count {
            // Show last separator when insert action to last
            let separator = self.stackView.arrangedSubviews.last as? FKAlertActionViewSeparator
            separator?.isHidden = false
            separator?.snp.remakeConstraints({ (make) in
                if self.actions.count < Constant.maxHorizontalActionCount {
                    make.width.equalTo(Constant.separatorHeight)
                } else {
                    make.height.equalTo(Constant.separatorHeight)
                }
            })
        }
        // Insert Separator
        let separator = FKAlertActionViewSeparator()
        let separatorIndex = index * 2
        self.stackView.insertArrangedSubview(separator, at: separatorIndex)
        separator.isHidden = index == self.actions.count
        separator.snp.makeConstraints({ (make) in
            if self.actions.count < Constant.maxHorizontalActionCount {
                make.width.equalTo(index == self.actions.count ? 0 : Constant.separatorHeight)
            } else {
                make.height.equalTo(index == self.actions.count ? 0 : Constant.separatorHeight)
            }
        })
        
        self.stackView.insertArrangedSubview(actionView, at: index * 2)
        actionView.snp.makeConstraints { (make) in
            if self.actions.count < Constant.maxHorizontalActionCount {
                make.width.equalTo(self.stackView).multipliedBy(0.5).offset(Constant.separatorHeight / 2)
            } else {
                make.height.equalTo(Constant.actionViewHeight)
            }
        }
        
        self.actions.append(action)
        
        if self.actions.count > Constant.maxHorizontalActionCount {
            self.scrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(self.separatorLine.snp.bottom)
                make.left.right.bottom.equalTo(self)
                make.height.equalTo((Constant.actionViewHeight + Constant.separatorHeight) * CGFloat(self.actions.count) - Constant.separatorHeight).priority(500)
            }
            self.stackView.snp.remakeConstraints { (make) in
                make.top.left.right.bottom.equalTo(self.scrollView)
                make.width.equalTo(self.scrollView)
                make.height.equalTo((Constant.actionViewHeight + Constant.separatorHeight) * CGFloat(self.actions.count) - Constant.separatorHeight)
            }
        } else {
            self.scrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(self.separatorLine.snp.bottom)
                make.left.right.bottom.equalTo(self)
                make.height.equalTo(Constant.actionViewHeight).priority(500)
            }
            self.stackView.snp.remakeConstraints { (make) in
                make.top.left.right.bottom.equalTo(self.scrollView)
                make.width.equalTo(self.scrollView)
                make.height.equalTo(Constant.actionViewHeight)
            }
        }
        self.layoutIfNeeded()
    }
    
    func performPresentingAnimation() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.3
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = Constant.animationDuration
        scaleAnimation.fillMode = kCAFillModeBoth
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.add(scaleAnimation, forKey: "scale")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.duration = Constant.animationDuration
        opacityAnimation.fillMode = kCAFillModeBoth
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.add(opacityAnimation, forKey: "opacity")
    }
    
    func performDismissingAnimation() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.9
        scaleAnimation.duration = Constant.animationDuration
        scaleAnimation.fillMode = kCAFillModeBoth
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.add(scaleAnimation, forKey: "scale")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = Constant.animationDuration
        opacityAnimation.fillMode = kCAFillModeBoth
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.add(opacityAnimation, forKey: "opacity")
    }
    
}

fileprivate class FKAlertTitleView: UIView {
    
    private let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    override var backgroundColor: UIColor? {
        get {
            if let cgColor = self.backgroundLayer.fillColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            self.backgroundLayer.fillColor = newValue?.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(self.backgroundLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 4, height: 4))
        self.backgroundLayer.path = path.cgPath
    }
    
}

extension FKAlertView: FKAlertActionViewDelegate {
    
    func backgroundPathInContainer(for actionView: FKAlertActionView) -> UIBezierPath {
        let frame = self.convert(actionView.bounds, from: actionView)
        let offsetOverHeight = self.physicalPixel(frame.maxY) - self.physicalPixel(self.bounds.maxY)
        if offsetOverHeight >= 0 {
            var bounds = frame
            bounds.size.height = self.bounds.maxY - frame.origin.y
            bounds.origin.y = 0
            bounds.origin.x = 0
            var corners: UIRectCorner = []
            if frame.origin.x == 0 {
                corners = .bottomLeft
            }
            if frame.maxX == self.bounds.maxX {
                corners = [corners, .bottomRight]
            }
            return UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: Constant.cornerRadius, height: Constant.cornerRadius))
        } else if offsetOverHeight >= -Constant.cornerRadius {
            var bounds = frame
            bounds.origin.y = 0
            bounds.size.height = self.bounds.maxY - frame.origin.y - Constant.cornerRadius
            let arc: CGFloat = asin((frame.height - bounds.height) / Constant.cornerRadius)
            let path = UIBezierPath(rect: bounds)
            let cornerPath = UIBezierPath()
            cornerPath.move(to: CGPoint(x: 0, y: bounds.maxY))
            cornerPath.addArc(withCenter: CGPoint(x: Constant.cornerRadius, y: bounds.maxY),
                              radius: Constant.cornerRadius,
                              startAngle: CGFloat.pi,
                              endAngle: CGFloat.pi - arc,
                              clockwise: false)
            cornerPath.addLine(to: CGPoint(x: bounds.width - Constant.cornerRadius * sin(arc), y: frame.height))
            cornerPath.addArc(withCenter: CGPoint(x: bounds.maxX - Constant.cornerRadius, y: bounds.maxY),
                              radius: Constant.cornerRadius,
                              startAngle: arc,
                              endAngle: 0,
                              clockwise: false)
            path.append(cornerPath)
            return path
        } else {
            return UIBezierPath(rect: actionView.bounds)
        }
    }
    
    func actionViewClicked(_ actionView: FKAlertActionView) {
        self.dismiss?()
    }
    
    private func physicalPixel(_ logicPixel: CGFloat) -> CGFloat {
        return round(UIScreen.main.scale * logicPixel)
    }
    
}

fileprivate class FKAlertActionViewSeparator: UIView {
    
    private struct Constant {
        static let separatorColor = UIColor(red: 221 / 255.0,
                                            green: 221 / 255.0,
                                            blue: 221 / 255.0,
                                            alpha: 1)
        static let separatorHeight: CGFloat = 1 / UIScreen.main.scale
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let separator = UIView()
        separator.backgroundColor = Constant.separatorColor
        self.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(self).offset(-40).priority(500)
            make.width.greaterThanOrEqualTo(Constant.separatorHeight)
            make.height.equalTo(self).offset(-22).priority(500)
            make.height.greaterThanOrEqualTo(Constant.separatorHeight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate struct FKAlertViewActionAppearance {
    
    static func appearance(for action: FKAlertAction) -> FKAlertActionViewAppearance {
        switch action.style {
        case .default: return FKAlertViewDefaultAppearance()
        case .cancel: return FKAlertViewCancelAppearance()
        case .destructive: return FKAlertViewDestructiveAppearance()
        }
    }
    
    struct FKAlertViewDestructiveAppearance: FKAlertActionViewAppearance {
        let textColor: UIColor = UIColor(red: 255 / 255.0,
                                         green: 71 / 255.0,
                                         blue: 71 / 255.0,
                                         alpha:1)
        let backgroundColor: UIColor = UIColor.clear
        let hilightedBackgroundColor: UIColor = UIColor(white: 221 / 255.0, alpha: 1)
        let font: UIFont = UIFont.systemFont(ofSize: 15)
    }
    
    struct FKAlertViewDefaultAppearance: FKAlertActionViewAppearance {
        let textColor: UIColor = UIColor(red: 76 / 255.0,
                                         green: 81 / 255.0,
                                         blue: 161 / 255.0,
                                         alpha:1)
        let backgroundColor: UIColor = UIColor.clear
        let hilightedBackgroundColor: UIColor = UIColor(white: 221 / 255.0, alpha: 1)
        let font: UIFont = UIFont.systemFont(ofSize: 15)
    }
    
    struct FKAlertViewCancelAppearance: FKAlertActionViewAppearance {
        let textColor: UIColor = UIColor(red: 76 / 255.0,
                                         green: 81 / 255.0,
                                         blue: 161 / 255.0,
                                         alpha:1)
        let backgroundColor: UIColor = UIColor.clear
        let hilightedBackgroundColor: UIColor = UIColor(white: 221 / 255.0, alpha: 1)
        let font: UIFont = UIFont.boldSystemFont(ofSize: 15)
    }
    
}
