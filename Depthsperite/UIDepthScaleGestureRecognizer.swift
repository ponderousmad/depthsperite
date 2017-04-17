//
//  UIDepthScaleGestureRecognizer.swift
//  Depthsperite
//
//  Created by Adrian Smith on 2017-04-17.
//  Copyright © 2017 Adrian Smith. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class UIDepthScaleGestureRecognizer : UIGestureRecognizer {
    
    let leftEdge : CGFloat = 0.25
    let rightEdge : CGFloat = 0.75
    
    private func touchLocation(_ touches: Set<UITouch>) -> CGPoint? {
        if let window = view?.window, touches.count > 1 {
            if let pos = touches.first?.location(in: window) {
                return CGPoint(x: pos.x / window.bounds.width,
                               y: pos.y / window.bounds.height)
            }
        }
        return nil
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if let pos = touchLocation(touches) {
            if pos.x < leftEdge || pos.x > rightEdge {
                state = .began
                return;
                
            }
        }
        state = .failed
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .failed {
            return
        }
        
        if let window = view?.window {
            if let loc = touches.first?.location(in: window) {
                if (loc.x > window.bounds.width * 0.5) {
                }
            }
        }
    }
}
