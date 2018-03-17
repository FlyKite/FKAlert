//
//  FKActionSheet.swift
//  OOContacts
//
//  Created by 风筝 on 2018/3/16.
//  Copyright © 2018年 Doge Studio. All rights reserved.
//

import UIKit

class FKActionSheet: UIView, FKAnimatedAlertView {
    
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
    
    var actions: [FKAlertAction] = []
    
    private var destructiveActions: [FKAlertAction] = []
    private var defaultActions: [FKAlertAction] = []
    private var cancelAction: FKAlertAction?
    
    var dismiss: (() -> Void)?
    
    private struct Constant {
        static let titleColor = UIColor(red: 76 / 255.0,
                                        green: 81 / 255.0,
                                        blue: 161 / 255.0,
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
        static let actionViewHeight: CGFloat = 45
    }
    
    // MARK: Views
    private let sheetContainer = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let separatorLine = UIView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let cancelActionView = UIView()

    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.sheetContainer.backgroundColor = UIColor.white
        self.sheetContainer.layer.cornerRadius = Constant.cornerRadius
        self.sheetContainer.layer.shadowColor = UIColor.black.cgColor
        self.sheetContainer.layer.shadowOpacity = 0.2
        self.sheetContainer.layer.shadowRadius = Constant.cornerRadius
        self.sheetContainer.layer.shadowOffset = CGSize.zero
        
        self.sheetContainer.addSubview(self.titleLabel)
        self.sheetContainer.addSubview(self.messageLabel)
        self.sheetContainer.addSubview(self.separatorLine)
        self.scrollView.addSubview(self.stackView)
        self.sheetContainer.addSubview(self.scrollView)
        self.addSubview(self.sheetContainer)
        self.addSubview(self.cancelActionView)
        
        self.titleLabel.isHidden = true
        self.titleLabel.font = UIFont.systemFont(ofSize: 17)
        self.titleLabel.textColor = Constant.titleColor
        self.titleLabel.textAlignment = .center
        
        self.messageLabel.isHidden = true
        self.messageLabel.font = UIFont.systemFont(ofSize: 14)
        self.messageLabel.textColor = Constant.messageColor
        
        self.separatorLine.backgroundColor = Constant.separatorColor
        self.separatorLine.isHidden = true
        
        self.stackView.axis = .vertical
        self.stackView.alignment = .fill
        self.stackView.distribution = .equalSpacing
        
        self.cancelActionView.backgroundColor = UIColor.white
        self.cancelActionView.layer.cornerRadius = Constant.cornerRadius
        self.cancelActionView.layer.shadowColor = UIColor.black.cgColor
        self.cancelActionView.layer.shadowOpacity = 0.2
        self.cancelActionView.layer.shadowRadius = Constant.cornerRadius
        self.cancelActionView.layer.shadowOffset = CGSize.zero
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-26)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(0)
        }
        self.messageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-26)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(0)
        }
        self.separatorLine.snp.makeConstraints { (make) in
            make.top.equalTo(self.messageLabel.snp.bottom)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(Constant.separatorHeight)
        }
        self.scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.separatorLine.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
        self.stackView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(0)
        }
        self.sheetContainer.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        self.cancelActionView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(self.sheetContainer.snp.bottom).offset(0)
            make.height.equalTo(0)
        }
    }
    
    private func updateTitle() {
        if let title = self.title, title.count > 0 {
            self.titleLabel.isHidden = false
            self.titleLabel.text = title
            self.titleLabel.snp.remakeConstraints({ (make) in
                make.left.equalToSuperview().offset(26)
                make.right.equalToSuperview().offset(-26)
                make.top.equalToSuperview().offset(0)
                make.height.equalTo(54)
            })
            self.messageLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(self).offset(26)
                make.right.equalTo(self).offset(-26)
                make.top.equalTo(self.titleLabel.snp.bottom)
            })
        } else {
            self.titleLabel.isHidden = true
            self.titleLabel.snp.remakeConstraints({ (make) in
                make.left.equalToSuperview().offset(26)
                make.right.equalToSuperview().offset(-26)
                make.top.equalToSuperview().offset(0)
                make.height.equalTo(0)
            })
            self.messageLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(self).offset(26)
                make.right.equalTo(self).offset(-26)
                make.top.equalTo(self).offset(18)
            })
        }
        self.updateSeparatorLine()
        self.layoutIfNeeded()
    }
    
    private func updateMessage() {
        if let message = self.message, message.count > 0 {
            self.messageLabel.isHidden = false
            self.messageLabel.text = message
        } else {
            self.messageLabel.isHidden = true
        }
        self.updateSeparatorLine()
        self.layoutIfNeeded()
    }
    
    private func updateSeparatorLine() {
        let hasHeader = !self.titleLabel.isHidden || !self.messageLabel.isHidden
        self.separatorLine.snp.remakeConstraints({ (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(Constant.separatorHeight)
            if !self.messageLabel.isHidden {
                make.top.equalTo(self.messageLabel.snp.bottom).offset(18)
            } else if !self.titleLabel.isHidden {
                make.top.equalTo(self.titleLabel.snp.bottom).offset(-Constant.separatorHeight)
            } else {
                make.top.equalToSuperview().offset(-Constant.separatorHeight)
            }
        })
        if hasHeader {
            if self.actions.count > 1 {
                self.separatorLine.isHidden = false
            } else if self.actions.count == 1 && self.cancelAction == nil {
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
                make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(15)
                make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-15)
                make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(20)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-7)
            } else {
                make.left.equalTo(view.snp.left).offset(15)
                make.right.equalTo(view.snp.right).offset(-15)
                make.top.greaterThanOrEqualTo(view.snp.top).offset(20)
                make.bottom.equalTo(view.snp.bottom).offset(-7)
            }
        }
    }
    
    func addAction(_ action: FKAlertAction) {
        if action.style == .cancel {
            if self.cancelAction != nil {
                fatalError("Cancel action already exists.")
            }
            // Insert cancelAction
            self.actions.append(action)
            self.cancelAction = action
            let appearance = FKActionSheetActionAppearance.appearance(for: action)
            let actionView = FKAlertActionView(action, appearance: appearance)
            actionView.delegate = self
            self.cancelActionView.addSubview(actionView)
            self.cancelActionView.snp.remakeConstraints { (make) in
                make.bottom.left.right.equalTo(self)
                make.top.equalTo(self.sheetContainer.snp.bottom).offset(7)
                make.height.equalTo(45)
            }
            actionView.snp.makeConstraints({ (make) in
                make.top.left.right.bottom.equalToSuperview()
            })
            return
        }
        
        let appearance = FKActionSheetActionAppearance.appearance(for: action)
        let actionView = FKAlertActionView(action, appearance: appearance)
        actionView.delegate = self
        
        /// Count of actions not includes cancelAction
        var actionsCount = self.actions.count - (self.cancelAction == nil ? 0 : 1)
        
        var index: Int
        if action.style == .destructive {
            index = self.destructiveActions.count
            self.destructiveActions.append(action)
        } else {
            index = actionsCount
            self.defaultActions.append(action)
        }
        
        if index == actionsCount {
            // Show last separator when insert action to last
            let separator = self.stackView.arrangedSubviews.last as? FKActionSheetActionViewSeparator
            separator?.isHidden = false
            separator?.snp.remakeConstraints({ (make) in
                make.height.equalTo(Constant.separatorHeight)
            })
        }
        
        // Insert Separator
        let separator = FKActionSheetActionViewSeparator()
        let separatorIndex = index * 2
        self.stackView.insertArrangedSubview(separator, at: separatorIndex)
        separator.isHidden = index == actionsCount
        separator.snp.makeConstraints({ (make) in
            make.height.equalTo(index == self.actions.count ? 0 : Constant.separatorHeight)
        })
        
        self.stackView.insertArrangedSubview(actionView, at: index * 2)
        actionView.snp.makeConstraints { (make) in
            make.height.equalTo(Constant.actionViewHeight)
        }
        
        self.actions.append(action)
        actionsCount += 1
        
        let stackViewHeight = (Constant.actionViewHeight + Constant.separatorHeight) * CGFloat(actionsCount) - Constant.separatorHeight
        
        self.scrollView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.separatorLine.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(stackViewHeight).priority(500)
        }
        self.stackView.snp.remakeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(stackViewHeight)
        }
        self.updateSeparatorLine()
        self.layoutIfNeeded()
    }
    
    func performPresentingAnimation() {
        guard let view = self.superview else {
            return
        }
        self.snp.remakeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(15)
                make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-15)
            } else {
                make.left.equalTo(view.snp.left).offset(15)
                make.right.equalTo(view.snp.right).offset(-15)
            }
            make.top.equalTo(view.snp.bottom).offset(20)
        }
        view.layoutIfNeeded()
        UIView.animate(withDuration: Constant.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.snp.remakeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(15)
                    make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-15)
                    make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(20)
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-7)
                } else {
                    make.left.equalTo(view.snp.left).offset(15)
                    make.right.equalTo(view.snp.right).offset(-15)
                    make.top.greaterThanOrEqualTo(view.snp.top).offset(20)
                    make.bottom.equalTo(view.snp.bottom).offset(-7)
                }
            }
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func performDismissingAnimation() {
        guard let view = self.superview else {
            return
        }
        UIView.animate(withDuration: Constant.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.snp.remakeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(15)
                    make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-15)
                } else {
                    make.left.equalTo(view.snp.left).offset(15)
                    make.right.equalTo(view.snp.right).offset(-15)
                }
                make.top.equalTo(view.snp.bottom).offset(20)
            }
            view.layoutIfNeeded()
        }, completion: nil)
    }

}

extension FKActionSheet: FKAlertActionViewDelegate {
    
    func backgroundPathInContainer(for actionView: FKAlertActionView) -> UIBezierPath {
        if actionView.action.style == .cancel {
            return UIBezierPath(roundedRect: self.cancelActionView.bounds, cornerRadius: 4)
        }
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

fileprivate class FKActionSheetActionViewSeparator: UIView {
    
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
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-30).priority(500)
            make.height.equalTo(Constant.separatorHeight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate struct FKActionSheetActionAppearance {
    
    static func appearance(for action: FKAlertAction) -> FKAlertActionViewAppearance {
        switch action.style {
        case .default: return FKActionSheetDefaultAppearance()
        case .cancel: return FKActionSheetCancelAppearance()
        case .destructive: return FKActionSheetDestructiveAppearance()
        }
    }
    
    struct FKActionSheetDestructiveAppearance: FKAlertActionViewAppearance {
        let textColor: UIColor = UIColor(red: 255 / 255.0,
                                         green: 71 / 255.0,
                                         blue: 71 / 255.0,
                                         alpha:1)
        let backgroundColor: UIColor = UIColor.clear
        let hilightedBackgroundColor: UIColor = UIColor(white: 221 / 255.0, alpha: 1)
        let font: UIFont = UIFont.systemFont(ofSize: 16)
    }
    
    struct FKActionSheetDefaultAppearance: FKAlertActionViewAppearance {
        let textColor: UIColor = UIColor(white: 3 / 255.0, alpha: 1)
        let backgroundColor: UIColor = UIColor.clear
        let hilightedBackgroundColor: UIColor = UIColor(white: 221 / 255.0, alpha: 1)
        let font: UIFont = UIFont.systemFont(ofSize: 16)
    }
    
    struct FKActionSheetCancelAppearance: FKAlertActionViewAppearance {
        let textColor: UIColor = UIColor.white
        let backgroundColor: UIColor = UIColor(red: 76 / 255.0,
                                               green: 81 / 255.0,
                                               blue: 161 / 255.0,
                                               alpha:1)
        let hilightedBackgroundColor: UIColor = UIColor(red: 76 / 255.0,
                                                        green: 81 / 255.0,
                                                        blue: 161 / 255.0,
                                                        alpha:0.8)
        let font: UIFont = UIFont.boldSystemFont(ofSize: 16)
    }
    
}
