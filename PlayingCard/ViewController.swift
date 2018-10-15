//
//  ViewController.swift
//  PlayingCard
//
//  Created by 邬铭扬 on 2018/9/27.
//  Copyright © 2018年 邬铭扬. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var cardViews: [PlayingCardView]!
    
    private var deck = PlayingCardDeck()
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
//    lazy var collisionBehavior : UICollisionBehavior = {
//        let behavior = UICollisionBehavior()
//        behavior.translatesReferenceBoundsIntoBoundary = true
//        animator.addBehavior(behavior)
//        return behavior
//    }()
//
//    lazy var itemBehavior : UIDynamicItemBehavior = {
//        let behavior = UIDynamicItemBehavior()
//        behavior.allowsRotation = false
//        behavior.elasticity = 1.0                                                               //elasticity:  弹性，设置为1.0值时，将在碰撞时不损失能量，而大于1时会获得能量而越弹越快
//        behavior.resistance = 0.0
//        animator.addBehavior(behavior)
//        return behavior
//    }()
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1) / 2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehavior.addItem(cardView)
//            collisionBehavior.addItem(cardView)                                                         //一旦执行了addItem方法到behavoir中，加入的item（即UIView）将马上应用behavoir中的设定
//            itemBehavior.addItem(cardView)
            
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1}
    }
    
    private var faceUpCardViewsMatched: Bool {
        return faceUpCardViews.count == 2 &&
        faceUpCardViews[0].suit == faceUpCardViews[1].suit &&
        faceUpCardViews[0].rank == faceUpCardViews[1].rank
    }
    
    var lastChosenCardView: PlayingCardView?
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
//                print("\(cardViews.filter{ !$0.isHidden }.count )")
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(with: chosenCardView,
                                  duration: 0.6,
                                  options: [.transitionFlipFromRight],
                                  animations: {
                                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                                  },
                                  completion: { finished in
                                    let cardsToAnimate = self.faceUpCardViews
                                    if self.faceUpCardViewsMatched {
                                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6,
                                                                                       delay: 0.0,
                                                                                       options: [],
                                                                                       animations: {
                                                                                        cardsToAnimate.forEach {
                                                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                                                                        }
                                                                                        },
                                                                                        completion: { position in
                                                                                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6,
                                                                                                                                           delay: 0.0,
                                                                                                                                           options: [],
                                                                                                                                           animations: {
                                                                                                                                            cardsToAnimate.forEach {
                                                                                                                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                                                                                                                $0.alpha = 0.0
                                                                                                                                            }
                                                                                                                                            },
                                                                                                                                           completion: {
                                                                                                                                                position in
                                                                                                                                            cardsToAnimate.forEach{
                                                                                                                                                $0.isHidden = true
                                                                                                                                                $0.alpha = 1.0
                                                                                                                                                $0.transform = .identity
                                                                                                                                            }
                                                                                                                                            }
                                                                                                                                            )
                                                                                                    }
                                                                                        )
                                    } else if cardsToAnimate.count == 2 {
                                        if chosenCardView == self.lastChosenCardView {
                                        cardsToAnimate.forEach { cardView in
                                            UIView.transition(with: cardView,
                                                              duration: 0.6,
                                                              options: [.transitionFlipFromRight],
                                                              animations: { cardView.isFaceUp = false },
                                                              completion: {finished in
                                                                self.cardBehavior.addItem(cardView)
                                                              }
                                                              )
                                        }
                                        }
                                    } else {
                                        if !chosenCardView.isFaceUp {
                                            self.cardBehavior.addItem(chosenCardView)
                                        }
                                    }
                })
            }
        default:
            break
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch preferredInterfaceOrientationForPresentation {
        case .landscapeLeft, .landscapeRight:
            print("landscape")
        case .portrait:
            changeLayoutFromLandScapeToPortrait()
            print("protrait normal")
        case .portraitUpsideDown:
            print("upsidedown")
        default: break
        }
        view.setNeedsDisplay()
        view.setNeedsLayout()
    }

    func changeLayoutFromLandScapeToPortrait() {
        for cardView in cardViews {
            if(!cardView.isHidden) {
                if(cardView.frame.origin.x > view.bounds.maxX) {
                    let formerOriginY = cardView.frame.origin.y
                    cardView.frame.origin.y = cardView.frame.origin.x
                    cardView.frame.origin.x = formerOriginY
                }
            }
        }
    }
    
    
    //    @IBOutlet weak var playingCardView: PlayingCardView!{
    //        didSet{
    //            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
    //            swipe.direction = [.left, .right]
    //            playingCardView.addGestureRecognizer(swipe)
    //            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(playingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy: )))
    //            playingCardView.addGestureRecognizer(pinch)
    //        }
    //    }
    //
    //    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
    //        switch sender.state {
    //        case .ended:
    //            playingCardView.isFaceUp = !playingCardView.isFaceUp
    //        default:
    //            break
    //        }
    //
    //    }
    //
    //
    //
    //
    //    @objc func nextCard() {                 //触摸识别器的工作机制是在Objective-C中实现的，所以上述的selector中用到的nextCard方法需要在声明前加上 @objc来暴露给Objective-C
    //        if let card = deck.draw() {
    //            playingCardView.rank = card.rank.order
    //            playingCardView.suit = card.suit.rawValue
    //        }
    //    }
    
}






extension CGFloat {
    var arc4random: CGFloat {
        if self > 0.0 {
            return CGFloat(arc4random_uniform(UInt32(self * 1000))) / CGFloat(UInt32(1000))
        }else if self == 0.0 {
            return self
        }else {
            return -( CGFloat(arc4random_uniform(UInt32( (-self) * 1000))) / CGFloat(UInt32(1000)) )
        }
    }
}














