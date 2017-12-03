//
//  Grid.swift
//  Mobile-Colonies
//
//  Created by Ethan on 12/1/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit

class Grid: NSObject{
    var name: String
    var size: Int
    let dateCreated: Date
    var colony: Colony
    
    init(name: String, size: Int){
        self.name = name
        self.size = size
        self.dateCreated = Date()
        self.colony = Colony()
        
        super.init()
    }
    
    convenience init(random: Bool = false){
        if random{
            let adjectives = ["Fluffy", "Rusty", "Shiny"]
            let nouns = ["Bear", "Spork", "Mac"]
            
            var idx = arc4random_uniform(UInt32(adjectives.count))
            let randomAdjective = adjectives[Int(idx)]
            
            idx = arc4random_uniform(UInt32(nouns.count))
            let randomNoun = nouns[Int(idx)]
            
            let randomName = "\(randomAdjective) \(randomNoun)"
            let randomSize = Int(arc4random_uniform(60))
            
            self.init(name: randomName, size: randomSize)
        } else {
            self.init(name: "", size: 0)
        }
    }
}

