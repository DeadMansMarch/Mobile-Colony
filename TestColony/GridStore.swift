//
//  ItemStore.swift
//  TestColony
//
//  Created by Ethan on 11/19/17.
//  Copyright © 2017 TheSucc. All rights reserved.
//

import Foundation
import UIKit

class GridStore {
    var allGrids = [Grid]()
    var count = 1
    
    @discardableResult func createGrid()-> Grid{
        let newGrid = Grid(name: "Grid \(count)", size: 60, id: count - 1)
        count += 1
        
        allGrids.append(newGrid)
        
        return(newGrid)
    }
    
    func removeGrid(_ grid: Grid){
        if let index = allGrids.index(of: grid){
            allGrids.remove(at: index)
        }
    }
    
    func moveGrid(from fromIndex: Int, to toIndex: Int){
        if fromIndex == toIndex{
            return
        }
        
        let movedGrid = allGrids[fromIndex]
        
        allGrids.remove(at: fromIndex)
        
        allGrids.insert(movedGrid, at: toIndex)
    }
}

