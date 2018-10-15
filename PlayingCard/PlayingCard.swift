//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by 邬铭扬 on 2018/9/27.
//  Copyright © 2018年 邬铭扬. All rights reserved.
//

import Foundation


struct PlayingCard: CustomStringConvertible                 //CustomStringConvertible协议为了在工作台打印此变量时更加美观，自定义打印内容
{
    var description: String {return "\(suit) : \(rank)"}
    
    var suit: Suit
    var rank: Rank
    
//    init(suit: Suit, rank: Rank){
//
//    }
    
   
    
    
    enum Suit: String, CustomStringConvertible{
        
        //在限定了枚举型的rawValue之后，struct自带属性var rawValue;
        var description: String {return rawValue}
        
        
        //此处Suit的raw value类型定死为String
        case spades = "♠️"
        case hearts = "♥️"
        case diamonds = "♣️"
        case clubs = "♦️"
        
        static var all = [Suit.spades, .hearts, .diamonds, .clubs]
    }
    
    enum Rank: CustomStringConvertible {
        var description: String {
            switch self {
            case .ace: return "A"
            case .face(let kind): return kind
            case .numeric(let pips): return String(pips)
            }
        }
        
        
        case ace
        case face(String)
        case numeric(Int)
        
        var order: Int{
            switch self{
            case .ace: return 1
            case .numeric(let pips): return pips
            case .face(let kind) where kind == "J": return 11
            case .face(let kind) where kind == "Q": return 12
            case .face(let kind) where kind == "K": return 13
            default: return 0
            }
        }
        
        static var all: [Rank] {
            var allRanks = [Rank.ace]
            for pips in 2...10 {
                allRanks += [Rank.numeric(pips)]
            }
            allRanks += [Rank.face("J"),.face("Q"),.face("K")]
            
            return allRanks
        }
    }
    
    
}
