import UIKit

class CircularProgressView: UIView {
    
    var progress: Double = 0 {
        didSet {
            if progress == 0 {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                progressLayer.strokeEnd = CGFloat(progress)
                CATransaction.commit()
            } else {
                progressLayer.strokeEnd = CGFloat(progress)
            }
        }
    }
    
    var circlesColor: UIColor = UIColor.clear {
        didSet {
            outerCircleLayer.strokeColor = circlesColor.cgColor
            innerCircleLayer.strokeColor = circlesColor.cgColor
            middleCircleLayer.strokeColor = circlesColor.cgColor
        }
    }
    
    fileprivate var initialized = false
    fileprivate var previousBounds = CGRect.zero
    
    fileprivate let progressLayer = CAShapeLayer()
    fileprivate let innerCircleLayer = CAShapeLayer()
    fileprivate let outerCircleLayer = CAShapeLayer()
    fileprivate let middleCircleLayer = CAShapeLayer()
    
    fileprivate let endAngle = CGFloat(-M_PI / 2)
    fileprivate let startAngle = CGFloat(3 * M_PI / 2)
    
    fileprivate var outerRadius : CGFloat = 0.0
    fileprivate var innerRadius : CGFloat = 0.0
    fileprivate var middleRadius : CGFloat = 0.0
    
    fileprivate var intervalSize : CGFloat = 0.0
    internal var circleWidth : CGFloat = 0.0
    fileprivate var progressWidth : CGFloat = 0.0
    
    fileprivate let progressColor = UIColor.white
    fileprivate let clockwise = false
    fileprivate var circlesCenter : CGPoint = CGPoint.zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds != previousBounds {
            previousBounds = bounds
            calculateVariables()
        }
    }
    
    fileprivate func calculateVariables() {
        let size = min(bounds.width, bounds.height) / 2
        circlesCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        
        circleWidth = size * 0.02
        progressWidth = size * 0.1
        intervalSize = size * 0.05
        
        outerRadius = size - circleWidth / 2
        middleRadius = size - circleWidth - intervalSize - progressWidth / 2
        innerRadius = size - 1.5 * circleWidth - progressWidth - 2 * intervalSize
        
        fillLayer(progressLayer, strokeEnd: CGFloat(progress), color: progressColor, width: progressWidth, radius: middleRadius, lineCap: kCALineCapRound)
        fillLayer(outerCircleLayer, strokeEnd: 1.0, color: circlesColor, width: circleWidth, radius: outerRadius, lineCap: kCALineCapButt)
        fillLayer(middleCircleLayer, strokeEnd: 1.0, color: circlesColor, width: circleWidth, radius: middleRadius, lineCap: kCALineCapButt)
        fillLayer(innerCircleLayer, strokeEnd: 1.0, color: circlesColor, width: circleWidth, radius: innerRadius, lineCap: kCALineCapButt)
        
        if !initialized {
            layer.addSublayer(outerCircleLayer)
            layer.addSublayer(middleCircleLayer)
            layer.addSublayer(innerCircleLayer)
            layer.addSublayer(progressLayer)
            initialized = true
        }
    }
    
    fileprivate func fillLayer(_ shapeLayer: CAShapeLayer, strokeEnd: CGFloat, color: UIColor, width: CGFloat, radius: CGFloat, lineCap: String) {
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = width
        shapeLayer.lineCap = lineCap
        shapeLayer.strokeEnd = strokeEnd
        shapeLayer.path = UIBezierPath(arcCenter: circlesCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise).cgPath
    }
    
    func start() {
        outerCircleLayer.isHidden = true
        innerCircleLayer.isHidden = true
        middleCircleLayer.isHidden = false
        middleCircleLayer.removeAllAnimations()
    }
    
    func pause() {
        outerCircleLayer.isHidden = true
        innerCircleLayer.isHidden = true
        middleCircleLayer.isHidden = false
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1
        animation.repeatCount = HUGE
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        middleCircleLayer.add(animation, forKey: nil)
    }
    
    func stop() {
        middleCircleLayer.removeAllAnimations()
        outerCircleLayer.isHidden = false
        innerCircleLayer.isHidden = false
        middleCircleLayer.isHidden = true
    }
}
