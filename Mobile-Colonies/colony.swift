//
//  colony.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 11/27/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation

protocol Cell: Hashable{
    var X: Int {get}
    var Y: Int {get}
}

extension Cell{
    var hashValue: Int{
        return(X.hashValue ^ Y.hashValue &* 16777619)
    }
}

struct nonWrapCell: Cell{
    let X:Int;
    let Y:Int;
    
    init(_ xCoor: Int, _ yCoor: Int){
        X = xCoor
        Y = yCoor
    }
    
    var hashValue: Int{
        return(X.hashValue ^ Y.hashValue &* 16777619)
    }
}

struct WrapCoor: Cell{
    let X: Int
    let Y: Int
    
    init(_ xCoor: Int, _ yCoor: Int, size: Int){
        X = xCoor % size
        Y = yCoor % size
    }
    
    var hashValue: Int{
        return(X.hashValue ^ Y.hashValue &* 16777619)
    }
}

struct Bound : CustomStringConvertible{
    let lBound : Cell;
    let rBound : Cell;
    
    var description:String{
        return "Lower Left Bound : \(lBound), Upper Right Bound : \(rBound)"
    }
}

func == <T: Cell>(lhs: T, rhs: T) -> Bool {
    return lhs.X == rhs.X && lhs.Y == rhs.Y;
}

class Colony: CustomStringConvertible{
    
    var Cells = Set<Cell>();
    var numberLivingCells:Int{ return Cells.count; }
    
    init(){
    }
    
    func setCellAlive(X: Int, Y: Int){ Cells.insert(Cell(X:X,Y:Y)) }
    
    func setCellDead(X: Int, Y: Int){ Cells.remove(Cell(X:X,Y:Y)) }
    
    func toggleCellAlive(X:Int,Y:Int){
        if isCellAlive(X:X,Y:Y){
            setCellDead(X:X,Y:Y);
        }else{
            setCellAlive(X: X, Y: Y);
        }
    }
    
    func isCellAlive(X: Int, Y: Int)-> Bool{
        return Cells.contains(Cell(X:X,Y:Y))
    }
    
    func resetColony(){ Cells.removeAll(); }
    
    var description: String{
        return "";
    }
    
    //Gets # of cells surrounding given coord.
    private func crowd(X:Int, Y:Int)->Int{
        var Alive = 0;
        Alive += isCellAlive(X: X - 1,Y:Y + 1) ? 1:0;
        Alive += isCellAlive(X: X,Y:Y + 1) ? 1:0;
        Alive += isCellAlive(X: X + 1,Y:Y + 1) ? 1:0;
        Alive += isCellAlive(X: X - 1,Y:Y) ? 1:0;
        Alive += isCellAlive(X: X + 1,Y:Y) ? 1:0;
        Alive += isCellAlive(X: X - 1,Y:Y - 1) ? 1:0;
        Alive += isCellAlive(X: X,Y:Y - 1) ? 1:0;
        Alive += isCellAlive(X: X + 1,Y:Y - 1) ? 1:0;
        return Alive;
    }
    
    func willLive(C:Cell)->Bool{
        let isAlive = isCellAlive(X: C.X,Y:C.Y);
        let Surround = crowd(X: C.X,Y:C.Y)
        if (isAlive){
            if Surround == 2 || Surround == 3{
                return true;
            }
        }else{
            if Surround == 3{
                return true;
            }
        }
        return false;
    }
    
    func evolve(){
        var queueList = Set<Cell>();
        
        Cells.forEach({
            for x in $0.X - 1 ... $0.X + 1{
                for y in $0.Y - 1 ... $0.Y + 1{
                    queueList.insert(Cell(X:x,Y:y));
                }
            }
        })
        
        Cells = Set<Cell>(queueList.filter(willLive))
    }
}
