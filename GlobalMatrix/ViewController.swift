//
//  ViewController.swift
//  NewSwiftCharts
//
//  Created by Ivan Schuetz on 26/12/2016.
//  Copyright © 2016 Ivan Schuetz. All rights reserved.
//

import UIKit


extension UIView {
    // Changes the anchor of view without changing its position. Returns translation in pt
    func setAnchorWithoutTranslation(anchor: CGPoint) -> CGPoint {
        let offsetAnchor = CGPoint(x: anchor.x - layer.anchorPoint.x, y: anchor.y - layer.anchorPoint.y)
        let offset = CGPoint(x: frame.width * offsetAnchor.x, y: frame.height * offsetAnchor.y)
        layer.anchorPoint = anchor
        transform = transform.translatedBy(x: offset.x, y: offset.y)
        return offset
    }
}



// The transform matrix to be applied to drawed lines in parent and to subview
var matrix = CGAffineTransform.identity
let superview = MySuperview()
let container = UIView()
let subview = UIView()

let domainPoint = CGPoint(x: 5, y: 5)

let xDomain: CGFloat = 10
let yDomain: CGFloat = 10

// Now "ranges" are derived directly from container size. For simplicity the start is included directly in toScreenPoint calculation, where it's needed.
var xScreenRange: CGFloat {
    return container.frame.width
}
var yScreenRange: CGFloat {
    return container.frame.height
}

func toScreenPoint(domainPoint: CGPoint) -> CGPoint {
    return CGPoint(x: domainPoint.x * xScreenRange / xDomain + container.frame.minX, y: domainPoint.y * yScreenRange / yDomain + container.frame.minY)
}

func toDomain(screenPoint: CGPoint) -> CGPoint {
    return CGPoint(x: screenPoint.x * xDomain / xScreenRange, y: screenPoint.y * yDomain / yScreenRange)
}

var screenPoint: CGPoint {
    return toScreenPoint(domainPoint: domainPoint)
}



class MySuperview: UIView {
    
    override func draw(_ rect: CGRect) {
        
        let transformed: CGPoint = CGPoint(x: screenPoint.x, y: screenPoint.y).applying(matrix)
        
        // Draw "cross" on superview
        let path = UIBezierPath()
        path.move(to: CGPoint(x: transformed.x, y: 0))
        path.addLine(to: CGPoint(x: transformed.x, y: 1000))
        path.close()
        UIColor.black.set()
        path.stroke()
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: 0, y: transformed.y))
        path2.addLine(to: CGPoint(x: 1000, y: transformed.y))
        path2.close()
        UIColor.black.set()
        path2.stroke()
    }
}

class ViewController: UIViewController {
    
    var subviewAnchorTranslation: CGPoint!
    var lastPanTranslation: CGPoint?
    
    var contentScalingFactor: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        superview.frame = view.bounds
        superview.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
        view.addSubview(superview)
        
        container.frame = containerFrame(minX: 100, minY: 50)
        container.backgroundColor = UIColor.green.withAlphaComponent(0.4)
        superview.addSubview(container)
        
        subview.frame = CGRect(x: -container.frame.minX, y: -container.frame.minY, width: superview.bounds.width, height: superview.bounds.height)
        subview.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        container.addSubview(subview)
        
        // Draw "cross" on subview (by adding subviews)
        let contentLine = UIView()
        contentLine.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        let contentLineWidth: CGFloat = 5
        contentLine.frame = CGRect(x: screenPoint.x - contentLineWidth / 2, y: 0, width: contentLineWidth, height: 1000)
        subview.addSubview(contentLine)
        let contentLine2 = UIView()
        contentLine2.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        contentLine2.frame = CGRect(x: 0, y: screenPoint.y - contentLineWidth / 2, width: 1000, height: contentLineWidth)
        subview.addSubview(contentLine2)
        
        // Set anchor point to (0, 0) to "sync" coordinate system with matrix
        // Also, store the translation which has to preserve position while changing anchor, to use it to define subview's matrix in applyMatrixToSubview
        subviewAnchorTranslation = subview.setAnchorWithoutTranslation(anchor: CGPoint(x: 0, y: 0))
        
//        addGesture() // test gesture recognizer - for now not used since not even programmatic gesture works
        
        // Frame change
        let xDelta: CGFloat = 150
        changeContainerFrame(delta: CGPoint(x: xDelta, y: 0))
        // No-op zoom, works!
        zoom(center: screenPoint, delta: CGPoint(x: 1, y: 1))
        
        // BREAKS
        zoom(center: screenPoint, delta: CGPoint(x: 1.1, y: 1))
        
        
        
        
        //        zoom(center: screenPoint, delta: CGPoint(x: 1.2, y: 1.2))
        //        translate(delta: CGPoint(x: 70, y: 70))
        //        ////zoom(center: screenPoint, delta: CGPoint(x: 2.1, y: 2))
        //        zoom(center: CGPoint(x: 200, y: 200), delta: CGPoint(x: 2.1, y: 2))
        //        zoom(center: CGPoint(x: 50, y: 70), delta: CGPoint(x: 0.7, y: 0.6))
        //        translate(delta: CGPoint(x: -10, y: 0))
        //
        //
        //        let xDelta2: CGFloat = -90
        ////        let scalingFactor2 = (xScreenRange - xDelta2) / xScreenRange
        ////        contentScalingFactor = CGPoint(x: scalingFactor2 * scalingFactor, y: 1)
        //        changeContainerFrame(delta: CGPoint(x: xDelta2, y: 0))
        ////        print("scaling content view by: \(scalingFactor2)")
        ////        subview.transform = subview.transform.scaledBy(x: contentScalingFactor!.x, y: 1)
        //
        //
        //        zoom(center: screenPoint, delta: CGPoint(x: 1.2, y: 1))
        //        zoom(center: CGPoint(x: 60, y: 70), delta: CGPoint(x: 1.5, y: 1.5))
        //        translate(delta: CGPoint(x: -760, y: -490))
        //
        ////        changeContainerFrame(delta: CGPoint(x: 90, y: 50))
        ////
        ////        zoom(center: CGPoint(x: 200, y: 170), delta: CGPoint(x: 1.1, y: 1.1))
        ////
        ////
        ////        changeContainerFrame(delta: CGPoint(x: -190, y: -150))
        ////
        ////
        ////        zoom(center: CGPoint(x: 200, y: 170), delta: CGPoint(x: 1.1, y: 1.1))
        ////        translate(delta: CGPoint(x: -240, y: -250))
    }
    
    func containerFrame(minX: CGFloat, minY: CGFloat) -> CGRect {
        let newContainerWidth = view.frame.width - minX - 20
        let newContainerHeight = view.frame.height - minY - 20
        return CGRect(x: minX, y: minY, width: newContainerWidth, height: newContainerHeight)
    }
    
    func changeContainerFrame(delta: CGPoint) {
        
        
        let xScalingFactor = (xScreenRange - delta.x) / xScreenRange
        let yScalingFactor = (yScreenRange - delta.y) / yScreenRange
        contentScalingFactor = CGPoint(x: xScalingFactor * (contentScalingFactor?.x ?? 1), y: yScalingFactor * (contentScalingFactor?.y ?? 1))
        
        
        
        
        // experiments - try to keep the offset of subview proportional to previous one
        let subviewOffset = CGPoint(x: 0 - subview.frame.minX, y: 0 - subview.frame.minY)
        let scaledSubviewOffset = CGPoint(x: subviewOffset.x * xScalingFactor, y: subviewOffset.y * yScalingFactor)
        print("subview offset: \(subviewOffset), scaledSubviewOffset: \(scaledSubviewOffset)")
        
        container.frame = containerFrame(minX: container.frame.minX + delta.x, minY: container.frame.minY + delta.y)
        
        //subview.frame = CGRect(x: subview.frame.minX - delta.x, y: subview.frame.minY - delta.y, width: subview.frame.width, height: subview.frame.height)
        subview.frame = CGRect(x: 0 - scaledSubviewOffset.x, y: 0 - scaledSubviewOffset.y, width: subview.frame.width, height: subview.frame.height)
        print("changed container frame, new: \(container.frame), subview frame is now: \(subview.frame)")
        
        
        

        
        
        
        superview.setNeedsDisplay()
        applyMatrixToSubview()
        
        
        
        //        container.frame = containerFrame(minX: container.frame.minX + delta.x, minY: container.frame.minY + delta.y)
        //        subview.frame = CGRect(x: subview.frame.minX - delta.x, y: subview.frame.minY - delta.y, width: subview.frame.width, height: subview.frame.height)
        //        print("changed container frame, new: \(container.frame)")
    }
    
    func zoom(center: CGPoint, level: CGPoint) {
        matrix = matrix.translatedBy(x: center.x, y: center.y)
        matrix.a = level.x
        matrix.d = level.y
        matrix = matrix.translatedBy(x: -center.x, y: -center.y)
        
        superview.setNeedsDisplay()
        applyMatrixToSubview()
        
        //        sometimesContainerFrameChanges()
    }
    
    // Simulate random container size changes during zoom / pan 
    // For now not used
    var lastSign = false
    func sometimesContainerFrameChanges() {
        if arc4random_uniform(20) == 1 {
            let sign = lastSign
            //            let deltaX: CGFloat = CGFloat(arc4random_uniform(100)) * (sign ? -1 : 1)
            let deltaX: CGFloat = 100 * (sign ? -1 : 1)
            changeContainerFrame(delta: CGPoint(x: deltaX, y: 0))
            print("After changing container frame by: \(deltaX), frame is: \(container.frame)")
            lastSign = !lastSign
        }
    }
    
    func zoom(center: CGPoint, delta: CGPoint) {
        zoom(center: center, level: CGPoint(x: matrix.a * delta.x, y: matrix.d * delta.y))
    }
    
    func applyMatrixToSubview() {
        let m = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: subviewAnchorTranslation.x, ty: subviewAnchorTranslation.y)
        subview.transform = matrix.concatenating(m)
        subview.transform = subview.transform.scaledBy(x: contentScalingFactor?.x ?? 1, y: contentScalingFactor?.y ?? 1)
    }
    
    func translate(delta: CGPoint) {
        matrix.tx = matrix.tx + delta.x
        matrix.ty = matrix.ty + delta.y
        
        superview.setNeedsDisplay()
        applyMatrixToSubview()
        
        //        sometimesContainerFrameChanges()
    }
    
    func addGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.onPan(_:)))
        view.addGestureRecognizer(pan)
        let zoom = UIPinchGestureRecognizer(target: self, action: #selector(onPinch(_:)))
        view.addGestureRecognizer(zoom)
    }
    
    private var currentPinchCenter: CGPoint?
    
    
    @objc func onPinch(_ sender: UIPinchGestureRecognizer) {
        
        guard sender.numberOfTouches > 1 else {return}
        
        switch sender.state {
        case .began:
            let center = sender.location(in: view)
            currentPinchCenter = center
        default: break
        }
        
        let center = currentPinchCenter ?? sender.location(in: view)
        
        let x = abs(sender.location(in: view).x - sender.location(ofTouch: 1, in: view).x)
        let y = abs(sender.location(in: view).y - sender.location(ofTouch: 1, in: view).y)
        
        // calculate scale x and scale y
        let (absMax, absMin) = x > y ? (abs(x), abs(y)) : (abs(y), abs(x))
        let minScale = (absMin * (sender.scale - 1) / absMax) + 1
        let (deltaX, deltaY) = x > y ? (sender.scale, minScale) : (minScale, sender.scale)
        
        zoom(center: CGPoint(x: center.x, y: center.y), delta: CGPoint(x: deltaX, y: deltaY))
        
        
        sender.scale = 1.0
    }
    
    
    
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began:
            lastPanTranslation = nil
            
        case .changed:
            
            let trans = sender.translation(in: view)
            
            let deltaX = lastPanTranslation.map{trans.x - $0.x} ?? trans.x
            let deltaY = lastPanTranslation.map{trans.y - $0.y} ?? trans.y
            
            lastPanTranslation = trans
            
            translate(delta: CGPoint(x: deltaX, y: deltaY))
            
        case .ended: break
        case .cancelled: break;
        case .failed: break;
        case .possible: break;
        }
    }
}
