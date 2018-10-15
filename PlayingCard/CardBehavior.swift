//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by 邬铭扬 on 2018/10/12.
//  Copyright © 2018年 邬铭扬. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior : UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior : UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 0.9                                                               //elasticity:  弹性，设置为1.0值时，将在碰撞时不损失能量，而大于1时会获得能量而越弹越快
        behavior.resistance = 0.0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let(x, y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi/2).arc4random
            case let(x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi - (CGFloat.pi / 2).arc4random
            case let(x, y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi / 2).arc4random
            case let(x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi + (CGFloat.pi / 2).arc4random
            default:
                push.angle = (2 * CGFloat.pi).arc4random
            }
        }
//        push.angle = (2*CGFloat.pi).arc4random                                                      //下面写了个extension来完成CGFloat范围内取随机数
        push.magnitude = CGFloat(1.0) //+ CGFloat(2.0).arc4random
        push.action = { [unowned push, weak self] in            //不使用unowned来修饰self的原因是，当某些情况下CardBehavior从堆中移除时，程序不会在此处崩溃
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {                                       //99.99%的情况下，客制的Behavior构造器需要重写，将所有需要的Behavoir作为ChildBehavoir加入客制的CardBehavoir
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
}
