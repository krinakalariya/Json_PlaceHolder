//
//  Extenstion.swift
//  PracticleTask
//
//  Created by krina kalariya on 26/04/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showToast(toastMessage: String, duration: CGFloat, bottomSpace: CGFloat = 70) {
        DispatchQueue.main.async {
            if toastMessage.isEmpty {
                return
            }
            // View to blur bg and stopping user interaction
            let bgView = UIView(frame: self.view.frame)
            bgView.tag = 555

            // Label For showing toast text
            let lblMessage = PaddingLabel()
            lblMessage.topInset = 4
            lblMessage.bottomInset = 4
            lblMessage.rightInset = 4
            lblMessage.leftInset = 4

            lblMessage.numberOfLines = 0
            lblMessage.lineBreakMode = .byWordWrapping
            lblMessage.textColor = .white
            lblMessage.backgroundColor = .black
            lblMessage.textAlignment = .center
            lblMessage.text = toastMessage

            // calculating toast label frame as per message content
            let maxSizeTitle: CGSize = CGSize(width: self.view.bounds.size.width - 16, height: self.view.bounds.size.height)
            let expectedSizeTitle: CGSize = lblMessage.sizeThatFits(maxSizeTitle)

            lblMessage.frame = CGRect(x: self.view.frame.minX + 10, y: self.view.frame.maxY - bottomSpace, width: expectedSizeTitle.width + 16, height: expectedSizeTitle.height + 16)
            lblMessage.center.x = self.view.center.x

            lblMessage.layer.cornerRadius = 8
            lblMessage.layer.masksToBounds = true
            bgView.addSubview(lblMessage)
            self.view.bringSubviewToFront(bgView)
            self.view.addSubview(bgView)

            lblMessage.alpha = 0

            UIView.animateKeyframes(withDuration: TimeInterval(duration), delay: 0, options: [], animations: {
                lblMessage.alpha = 1
            }, completion: {
                _ in
                UIView.animate(withDuration: TimeInterval(duration), delay: 8, options: [], animations: {
                    lblMessage.alpha = 0
                    bgView.alpha = 0
                })
                bgView.removeFromSuperview()
            })
        }
    }
}

@IBDesignable class PaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

//MARK: Setup loading View
@IBDesignable
class SpinnerView : UIView {
    
    override var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.fillColor = nil
        layer.strokeColor = UIColor.purple.cgColor
        layer.lineWidth = 4
        setPath()
    }
    
    override func didMoveToWindow() {
        animate()
    }
    
    private func setPath() {
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }
    
    struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }
    
    class var poses: [Pose] {
        get {
            return [
                Pose(0.0, 0.000, 0.7),
                Pose(0.6, 0.500, 0.5),
                Pose(0.6, 1.000, 0.3),
                Pose(0.6, 1.500, 0.1),
                Pose(0.2, 1.875, 0.1),
                Pose(0.2, 2.250, 0.3),
                Pose(0.2, 2.625, 0.5),
                Pose(0.2, 3.000, 0.7),
            ]
        }
    }
    
    func animate() {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let poses = type(of: self).poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        
        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(pose.length)
        }
        
        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        
        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
        
        animateStrokeHueWithDuration(duration: totalSeconds * 5)
    }
    
    func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = CAAnimationCalculationMode.linear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
    
    func animateStrokeHueWithDuration(duration: CFTimeInterval) {
        let count = 36
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.keyTimes = (0 ... count).map { NSNumber(value: CFTimeInterval($0) / CFTimeInterval(count)) }
        animation.values = (0 ... count).map {_ in
            UIColor.black.cgColor
        }
        animation.duration = duration
        animation.calculationMode = CAAnimationCalculationMode.linear
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
}
extension UIView {
    
    func addDropShadow(_ shadowRadius : Int = 2,shadowOpacity : Int = 1) {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = CGFloat(shadowRadius)
        layer.shadowOpacity = Float(shadowOpacity)
        layer.masksToBounds = false
    }
    
}
