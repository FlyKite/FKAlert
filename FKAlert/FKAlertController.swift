//
//  FKAlertController.swift
//  OOContacts
//
//  Created by 风筝 on 2018/3/16.
//  Copyright © 2018年 Doge Studio. All rights reserved.
//

import UIKit

open class FKAlertAction: NSObject { // TODO: implement NSCopying
    
    public enum ActionStyle {
        case `default`
        case cancel
        case destructive
    }
    
    open private(set) var title: String?
    
    open private(set) var style: ActionStyle
    
    /// Defaults to true
    open var isEnabled: Bool
    
    var handler: ((FKAlertAction) -> Void)?
    
    init(title: String?, style: ActionStyle, handler: ((FKAlertAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.isEnabled = true
        self.handler = handler
        super.init()
    }
    
}

open class FKAlertController: UIViewController {
    
    public enum AlertStyle {
        case actionSheet
        case alert
    }

    init(title: String?, message: String?, preferredStyle: AlertStyle) {
        self.preferredStyle = preferredStyle
        switch preferredStyle {
        case .actionSheet: self.alertView = FKActionSheet()
        case .alert: self.alertView = FKAlertView()
        }
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.transitioningDelegate = self
        
        self.title = title
        self.message = message
        
        weak var weakSelf = self
        self.alertView.dismiss = {
            weakSelf?.dismiss(animated: true, completion: nil)
        }
    }
    
    open func addAction(_ action: FKAlertAction) {
        self.alertView.addAction(action)
    }
    
    open var actions: [FKAlertAction] {
        get {
            return self.alertView.actions
        }
    }
    
    // TODO: TODO: preferredAction
    open var preferredAction: FKAlertAction?
    
    
    // TODO: TODO: addTextField(configurationHandler:)
    open func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        
    }
    
    open private(set) var textFields: [UITextField]?
    
    open override var title: String? {
        get {
            return super.title
        }
        set {
            super.title = newValue
            self.alertView.title = newValue
        }
    }
    
    open var message: String? {
        get {
            return self.alertView.message
        }
        set {
            self.alertView.message = newValue
        }
    }
    
    
    // TODO: TODO: preferredStyle
    open let preferredStyle: AlertStyle
    
    // MARK:- Private fields
    
    private var alertView: FKAnimatedAlertView
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertView.add(to: self.view)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isBeingPresented {
            self.alertView.performPresentingAnimation()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isBeingDismissed {
            self.alertView.performDismissingAnimation()
        }
    }

}

protocol FKAnimatedAlertView: NSObjectProtocol {
    
    var title: String? { get set }
    var message: String? { get set }
    var actions: [FKAlertAction] { get }
    var dismiss: (() -> Void)? { get set }
    
    func add(to view: UIView)
    func addAction(_ action: FKAlertAction)
    func performPresentingAnimation()
    func performDismissingAnimation()
    
}

extension FKAlertController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = FKAlertControllerAnimatedTransition()
        transition.isPresenting = true
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = FKAlertControllerAnimatedTransition()
        transition.isPresenting = false
        return transition
    }
    
}

class FKAlertControllerAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    var isPresenting = true
    
    private struct Constant {
        static let duration: TimeInterval = 0.25
        static let backgroundColor = UIColor(white: 0, alpha: 0.2)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constant.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let alertView = transitionContext.view(forKey: self.isPresenting ? .to: .from) else {
            return
        }
        
        let container = transitionContext.containerView
        container.addSubview(alertView)
        
        alertView.backgroundColor = self.isPresenting
            ? UIColor.clear
            : Constant.backgroundColor
        UIView.animate(withDuration: Constant.duration, delay: 0, options: .curveEaseInOut, animations: {
            alertView.backgroundColor = self.isPresenting
                ? Constant.backgroundColor
                : UIColor.clear
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
    
}
