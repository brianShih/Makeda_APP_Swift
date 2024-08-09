//
//  animationHelper.swift
//  Makeda
//
//  Created by Brian on 2019/8/25.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import UIKit
import Foundation

class animationHelper: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey:
            UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        //let bounds = UIScreen.main.bounds
        //        toViewController.view.frame = CGRectOffset(finalFrameForVC, 0, bounds.size.height)
        //toViewController.view.frame = CGRect.offsetBy(0, -bounds.size.height)//CGRectoffs(finalFrameForVC, 0, -bounds.size.height)
            //CGRectOffset(finalFrameForVC, 0, -bounds.size.height)
        //CGRectOffset(finalFrameForVC, 0, -bounds.size.height)
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            fromViewController.view.alpha = 0.5
            toViewController.view.frame = finalFrameForVC
        }, completion: {
            finished in
            transitionContext.completeTransition(true)
            fromViewController.view.alpha = 1.0
        })
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
//            cell.transform = CGAffineTransformMakeTranslation(0, 0);
        }, completion: nil)
    }
}
