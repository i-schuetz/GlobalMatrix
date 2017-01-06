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


// The following variables are simplified ranges - all start with 0
let xDomain: CGFloat = 10
let yDomain: CGFloat = 10
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

func toSubViewScreenPoint(domainPoint: CGPoint) -> CGPoint {
    let globalScreenPoint = toScreenPoint(domainPoint: domainPoint)
    return CGPoint(x: globalScreenPoint.x - container.frame.minX, y: globalScreenPoint.y - container.frame.minY)
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
        
        subview.frame = container.bounds
        subview.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        container.addSubview(subview)
        
        // Draw "cross" on subview (by adding subviews)
        let contentLine = UIView()
        contentLine.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        let contentLineWidth: CGFloat = 5
        let containerScreenPoint = toSubViewScreenPoint(domainPoint: domainPoint)
        contentLine.frame = CGRect(x: containerScreenPoint.x - contentLineWidth / 2, y: 0, width: contentLineWidth, height: 1000)
        subview.addSubview(contentLine)
        let contentLine2 = UIView()
        contentLine2.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        contentLine2.frame = CGRect(x: 0, y: containerScreenPoint.y - contentLineWidth / 2, width: 1000, height: contentLineWidth)
        subview.addSubview(contentLine2)
        
        // Set anchor of "subview" to top left of "parent" to be in sync when appliying matrix
        updateSubviewAnchor()
        
        
        addGesture()
        
        
        
        // Frame change
        let xDelta: CGFloat = 150
        //        let scalingFactor = (xScreenRange - xDelta) / xScreenRange
        //        contentScalingFactor = CGPoint(x: scalingFactor, y: 1)
        changeContainerFrame(delta: CGPoint(x: xDelta, y: 0))
        //        print("scaling content view by: \(scalingFactor)")
        //        subview.transform = subview.transform.scaledBy(x: contentScalingFactor!.x, y: 1)
        
        // No-op zoom, until here it works!
        zoom(center: screenPoint, delta: CGPoint(x: 1, y: 1))
        //
        //        // BREAKS
        //        zoom(center: screenPoint, delta: CGPoint(x: 1.1, y: 1))
        
        
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
    
    func updateSubviewAnchor() {
        // Also, store the translation which has to preserve position while changing anchor, to use it to define subview's matrix in applyMatrixToSubview
        let origin = CGPoint.zero
        let p1x = origin.x - container.frame.origin.x
        let p1y = origin.y - container.frame.origin.y
        let originInContentViewCoords = CGPoint(x: p1x, y: p1y)
        subviewAnchorTranslation = CGPoint(x: originInContentViewCoords.x / container.frame.width, y: originInContentViewCoords.y / container.frame.height)
    }
    
    func containerFrame(minX: CGFloat, minY: CGFloat) -> CGRect {
        let newContainerWidth = view.frame.width - minX - 20
        let newContainerHeight = view.frame.height - minY - 20
        return CGRect(x: minX, y: minY, width: newContainerWidth, height: newContainerHeight)
    }
    
    func changeContainerFrame(delta: CGPoint) {
        let previousContentFrame = subview.frame
        
        container.frame = containerFrame(minX: container.frame.minX + delta.x, minY: container.frame.minY + delta.y)
        // Change dimensions of content view by total delta of container view
        subview.frame.size = CGSize(width: subview.frame.width - delta.x, height: subview.frame.height - delta.y)
        
        // Scale contents of content view
        let widthChangeFactor = subview.frame.width / previousContentFrame.width
        let heightChangeFactor = subview.frame.height / previousContentFrame.height
        contentScalingFactor = CGPoint(x: (contentScalingFactor?.x ?? 1) * widthChangeFactor, y: (contentScalingFactor?.y ?? 1) * heightChangeFactor)
        
        // Since resizing the container view changes its position (and thus also the position of the content view) relative to the chart view's origin, and we use the chart view's origin as anchor point, we have to update the anchor point.
        updateSubviewAnchor()
        
        let frameBeforeScale = subview.frame
        applyMatrixToSubview()
        subview.frame = frameBeforeScale
        
        
        //        superview.setNeedsDisplay()
    }
    
    func zoom(center: CGPoint, level: CGPoint) {
        matrix = matrix.translatedBy(x: center.x, y: center.y)
        matrix.a = level.x
        matrix.d = level.y
        matrix = matrix.translatedBy(x: -center.x, y: -center.y)
        
        superview.setNeedsDisplay()
        applyMatrixToSubview()
        
        // It should also work when this is enabled
        //        sometimesContainerFrameChanges()
    }
    
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
        
        // It should also work when this is enabled
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
