//
//  GridStore.swift
//  Mobile-Colonies
//
//  Created by Ethan on 12/1/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit

class ColonyStore {
    var allColonies = [ColonyData]()
    var count:Int {
        return allColonies.count;
    }
    
    @discardableResult func createColony(Data:ColonyData)-> Int{
        allColonies.append(Data)
        
        return self.count - 1;
    }
    
    func removeColony(_ Data: ColonyData){
        if let index = allColonies.index(of: Data){
            allColonies.remove(at: index)
        }
    }
    
    func moveColony(from fromIndex: Int, to toIndex: Int){
        if fromIndex == toIndex{
            return
        }
        
        let movedColony = allColonies[fromIndex]
        
        allColonies.remove(at: fromIndex)
        allColonies.insert(movedColony, at: toIndex)
    }
}

