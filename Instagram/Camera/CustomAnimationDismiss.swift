//
//  CustomAnimationDismiss.swift
//  Instagram
//
//  Created by Sovorn on 10/4/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

class CustomAnimationDismiss: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {return}
        containView.addSubview(toView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
