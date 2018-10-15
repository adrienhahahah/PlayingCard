//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by 邬铭扬 on 2018/9/27.
//  Copyright © 2018年 邬铭扬. All rights reserved.
//

import UIKit


@IBDesignable
class PlayingCardView: UIView
{
    @IBInspectable//为了让storyboard中的属性显示出来，每个var前声明，build后便会显示在storyboard中，但每个var必须明确类型
    var rank: Int = 9 {
        didSet { setNeedsDisplay(); setNeedsLayout() }
    }
    @IBInspectable
    var suit: String = "♠️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    @IBInspectable
    var isFaceUp: Bool = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    //此处，rank直接设置为Int，suit直接设置为String的原因是
    //The model had the rank and suit to be enum type.
    //Here, this is a view, it knows nothing of that model
    //it's a generic card drawing view, it knows nothing of that paticular model
    //it represents its rank and suit in a completely different way than the model, perfectly fine
    //the job to translate between model and view, of course !!!!!!!!!!!!!!!  THE Controller  !!!!!!!!!!!!
    
    
        
    
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize {
        didSet {
            setNeedsDisplay()
        }
    }
    
//    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
//        switch recognizer.state {
//        case .changed,.ended:
//            faceCardScale *= recognizer.scale
//            recognizer.scale = 1.0
//        default: break
//        }
//    }
//
    
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body) .withSize(fontSize)    // preferredFont(forTextStyle: UIFontTextStyle)是UIFont中的一个静态方法
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)             // 次行很重要，scaledFont（for：）将参数字体适配成用户在设置栏中设置的工量字体
        let paragraphStyle = NSMutableParagraphStyle()                              // 此处用mutable是为了下一行可以修改其alignment的属性，非mutable是不可修改的
        paragraphStyle.alignment = .center                                          // 将paragraphStyle设置为居中
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font])   // 将paragraphStyle和font字体作为dictionary
                                                                                                                // 生成NSAttributedString(不可修改）
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString + "\n" + suit, fontSize: cornerFontSize)
    }
    
    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var lowerRightCornerLabel = createCornerLabel()
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0                                                     // 此行设置label行数等于0，等同于label可以设置为任意行数
        addSubview(label)
        return label
    }
    
    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero  // 所以，为了让label.sizeToFit()正常工作，按照字符需要横向和垂直延伸，将size预设为CGSize.zero
        label.sizeToFit() // 此方法，棘手处在于，当先前设定了label的宽度，此方法将保留宽度设定，向垂直方向延伸
        label.isHidden = !isFaceUp //这就是需要configureCOrnerLabel()特别设立方法的缘故，当牌没有面朝上，即不进行绘画
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {                     //此方法将监测用户系统字体设置，在每次设置修改后重绘 ！！！！！！！！！！！！！
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    
    override func layoutSubviews() {                                                // 此方法仅由系统调用，我们调用此方法是通过setNeedsLayout()
        super.layoutSubviews()
        
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        
        configureCornerLabel(lowerRightCornerLabel)
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offsetBy(dx: -cornerOffset, dy: -cornerOffset)     // 将原点设置到牌的右下角，偏移CGRect的圆角偏移量
            .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)                        // 偏移CGRect的frame长宽偏移量
        lowerRightCornerLabel.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)                                            // 按照Rect的中点进行旋转
       
    }
    
    private func drawPips() {
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2,],[2,2,2,2,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) } )
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            //print("\(pipRect.size.height)")
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    
    override func draw(_ rect: CGRect) {                                            // 此方法仅由系统调用，我们调用此方法是通过setNeedsDisplay()
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString + suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
                
                // TODO :
                
            } else {
                
                drawPips()
            }
        } else {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
                
            }
        }
    }
 
    

}



extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.09
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.68
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String {
        switch rank{
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}


extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width / 2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width / 2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) ->CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
        
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}






