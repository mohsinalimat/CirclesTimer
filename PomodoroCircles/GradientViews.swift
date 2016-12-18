import UIKit

class GradientView: UIView {

    fileprivate var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initGradient()
    }
    
    fileprivate func initGradient() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gradientLayer.colors = Utils.gradientColors
        gradientLayer.frame = CGRect.zero
        backgroundColor = Utils.backgroundColor
    }
}

class GradientTableView: UITableView {
    
    fileprivate var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initGradient()
    }
    
    fileprivate func initGradient() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gradientLayer.colors = Utils.gradientColors
        gradientLayer.frame = CGRect.zero
        backgroundColor = Utils.backgroundColor
    }
}
