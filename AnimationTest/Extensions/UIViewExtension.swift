//
//  UIViewExtension.swift
//  AnimationTest
//
//  Created by Argentino Ducret on 24/01/2018.
//  Copyright © 2018 wolox. All rights reserved.
//

import Foundation
import UIKit

enum Position {
    case back
    case front
}

class MixedAnimation {
    var transformations: [CGAffineTransform] = []
    var actions: [() -> ()] = []
    let duration: TimeInterval
    let view: UIView
    
    init(view: UIView, duration: TimeInterval) {
        self.duration = duration
        self.view = view
    }
    
    // MARK: - Transforms
    
    func transformIdentity() -> MixedAnimation {
        transformations.append(CGAffineTransform.identity)
        return self
    }
    
    func transform(translationX: CGFloat, translationY: CGFloat) -> MixedAnimation {
        transformations.append(CGAffineTransform(translationX: translationX, y: translationY))
        return self
    }
    
    func transform(rotationAngle: CGFloat) -> MixedAnimation {
        let angleInRadians = (rotationAngle * CGFloat.pi) / 180.0;
        transformations.append(CGAffineTransform(rotationAngle: angleInRadians))
        return self
    }
    
    func transform(scaleX: CGFloat, scaleY: CGFloat) -> MixedAnimation {
        transformations.append(CGAffineTransform(scaleX: scaleX, y: scaleY))
        return self
    }
    
    // MARK: - Actions
    
    func action(positionX: CGFloat, positionY: CGFloat) -> MixedAnimation {
        actions.append {
            self.view.center = CGPoint(x: positionX, y: positionY)
        }
        
        return self
    }
    
    func action(translateX: CGFloat, translateY: CGFloat) -> MixedAnimation {
        actions.append {
            self.view.center = CGPoint(x: self.view.center.x + translateX, y: self.view.center.y + translateY)
        }
        return self
    }
    
    func action(scaleX: CGFloat, scaleY: CGFloat) -> MixedAnimation {
        actions.append {
            let center = self.view.center
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width * scaleX,
                                     height: self.view.frame.height * scaleY)
            self.view.center = center
        }
        return self
    }
    
    func action(alpha: CGFloat) -> MixedAnimation {
        actions.append({
            self.view.alpha = alpha
        })
        return self
    }
    
    func action(moveTo position: Position) -> MixedAnimation {
        actions.append({
            switch position {
            case .back:
                self.view.superview?.sendSubview(toBack: self.view)
            case .front:
                self.view.superview?.bringSubview(toFront: self.view)
            }
        })
        return self
    }
    
    func startAnimation(completion: ((Bool) -> Void)? = { _ in }) {
        UIView.animate(withDuration: duration, animations: {
            if self.transformations.count > 0 {
                self.view.transform = self.transformations[0]
                for i in 1..<self.transformations.count {
                    self.view.transform = self.view.transform.concatenating(self.transformations[i])
                }
            }
            self.actions.forEach { $0() }
        }, completion: completion)
    }
    
}

class SimpleAnimation {
    var animations: [Any] = []
    let view: UIView
    var completion: ((Bool) -> ())? = .none
    
    init(view: UIView) {
        self.view = view
    }
 
    // MARK: - Transforms
    
    func transformIdentity(withDuration duration: TimeInterval) -> SimpleAnimation {
        animations.append((CGAffineTransform.identity, duration))
        return self
    }
    
    func transform(withDuration duration: TimeInterval, translationX: CGFloat, translationY: CGFloat) -> SimpleAnimation {
        animations.append((CGAffineTransform(translationX: translationX, y: translationY), duration))
        return self
    }
    
    func transform(withDuration duration: TimeInterval, rotationAngle: CGFloat) -> SimpleAnimation {
        let angleInRadians = (rotationAngle * CGFloat.pi) / 180.0;
        animations.append((CGAffineTransform(rotationAngle: angleInRadians), duration))
        return self
    }
    
    func transform(withDuration duration: TimeInterval, scaleX: CGFloat, scaleY: CGFloat) -> SimpleAnimation {
        animations.append((CGAffineTransform(scaleX: scaleX, y: scaleY), duration))
        return self
    }
    
    // MARK: Actions
    
    func action(withDuration duration: TimeInterval, positionX: CGFloat, positionY: CGFloat) -> SimpleAnimation {
        let action = {
            self.view.center = CGPoint(x: positionX, y: positionY)
        }
        animations.append((action, duration))
        return self
    }
    
    func action(withDuration duration: TimeInterval, translateX: CGFloat, translateY: CGFloat) -> SimpleAnimation {
        let action = {
            self.view.center = CGPoint(x: self.view.center.x + translateX, y: self.view.center.y + translateY)
        }
        animations.append((action, duration))
        return self
    }
    
    func action(withDuration duration: TimeInterval, scaleX: CGFloat, scaleY: CGFloat) -> SimpleAnimation {
        let action = {
            let center = self.view.center
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width * scaleX,
                                     height: self.view.frame.height * scaleY)
            self.view.center = center
        }
        animations.append((action, duration))
        return self
    }
    
    func action(withDuration duration: TimeInterval, alpha: CGFloat) -> SimpleAnimation {
        let action = {
            self.view.alpha = alpha
        }
        animations.append((action, duration))
        return self
    }
    
    func action(withDuration duration: TimeInterval, moveTo position: Position) -> SimpleAnimation {
        let action = {
            switch position {
            case .back:
                self.view.superview?.sendSubview(toBack: self.view)
            case .front:
                self.view.superview?.bringSubview(toFront: self.view)
            }
        }
        animations.append((action, duration))
        return self
    }
    
    func startAnimation(completion: ((Bool) -> Void)? = { _ in }) {
        self.completion = completion
        if animations.count > 0 {
            var animationsCopy = animations
            let animation = animationsCopy.remove(at: 0)
            recursiveAnimation(animation: animation, animations: animationsCopy)
        }
    }
    
    fileprivate func recursiveAnimation(animation: Any, animations: [Any]) {
        var mutableAnimations = animations
        if let (transform, duration) = animation as? (CGAffineTransform, TimeInterval) {
            UIView.animate(withDuration: duration, animations: {
                self.view.transform = transform
            }) { finished in
                if mutableAnimations.count > 0 {
                    let nextAnimation = mutableAnimations.remove(at: 0)
                    self.recursiveAnimation(animation: nextAnimation, animations: mutableAnimations)
                } else {
                    self.completion?(finished)
                }
            }
        } else if let (action, duration) = animation as? (() -> (), TimeInterval) {
            UIView.animate(withDuration: duration, animations: {
                action()
            }) { finished in
                if mutableAnimations.count > 0 {
                    let nextAnimation = mutableAnimations.remove(at: 0)
                    self.recursiveAnimation(animation: nextAnimation, animations: mutableAnimations)
                } else {
                    self.completion?(finished)
                }
            }
        }
    }
    
}

class ChainedAnimation {
    let view: UIView
    let loop: Bool
    let completion: () -> ()
    var simpleAnimations: [Any] = []
    
    private var currentAnimation = 0
    
    init(view: UIView, loop: Bool = false, completion: @escaping () -> () = { }) {
        self.view = view
        self.loop = loop
        self.completion = completion
    }
    
    func add(animation: MixedAnimation) -> ChainedAnimation {
        simpleAnimations.append(animation)
        return self
    }
    
    func add(animation: SimpleAnimation) -> ChainedAnimation {
        simpleAnimations.append(animation)
        return self
    }
    
    func startAnimation() {
        if let mixedAnimation = simpleAnimations[currentAnimation] as? MixedAnimation {
            mixedAnimation.startAnimation(completion: animationCompletion)
        } else if let simpleAnimation = simpleAnimations[currentAnimation] as? SimpleAnimation {
            simpleAnimation.startAnimation(completion: animationCompletion)
        }
    }
    
    private func animationCompletion(completed: Bool) {
        currentAnimation += 1
        if currentAnimation >= simpleAnimations.count {
            currentAnimation = 0;
            completion()
            if !loop {
                return
            }
        }
        
        if let mixedAnimation = simpleAnimations[currentAnimation] as? MixedAnimation {
            mixedAnimation.startAnimation(completion: animationCompletion)
        } else if let simpleAnimation = simpleAnimations[currentAnimation] as? SimpleAnimation {
            simpleAnimation.startAnimation(completion: animationCompletion)
        }
    }
    
}

extension UIView {
    
    func simpleAnimation() -> SimpleAnimation {
        return SimpleAnimation(view: self)
    }
    
    func mixedAnimation(withDuration duration: TimeInterval) -> MixedAnimation {
        return MixedAnimation(view: self, duration: duration)
    }
    
    func chainedAnimation(loop: Bool = false, completion: @escaping () -> () = { }) -> ChainedAnimation {
        return ChainedAnimation(view: self, loop: loop, completion: completion)
    }
    
}
