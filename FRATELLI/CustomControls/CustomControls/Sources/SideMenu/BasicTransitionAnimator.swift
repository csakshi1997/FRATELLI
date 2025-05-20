//
//  TransitionAnimator.swift
//  SideMenu
//
//  Created by chaman
//  Copyright © 2021 chaman. All rights reserved.
//

import UIKit

// A Simple transition animator can be configured with animation options.
public class BasicTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let animationOptions: UIView.AnimationOptions
    let duration: TimeInterval

    /// Initialize a new animator with animation options and duration.
    ///
    /// - Parameters:
    ///   - options: animation options
    ///   - duration: animation duration
    public init(options: UIView.AnimationOptions = .transitionCrossDissolve, duration: TimeInterval = 0.4) {
        self.animationOptions = options
        self.duration = duration
    }

    // MARK: UIViewControllerAnimatedTransitioning

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
                return
        }

        transitionContext.containerView.addSubview(toViewController.view)

        let duration = transitionDuration(using: transitionContext)

        UIView.transition(from: fromViewController.view,
                          to: toViewController.view,
                          duration: duration,
                          options: animationOptions,
                          completion: { (_) in
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
