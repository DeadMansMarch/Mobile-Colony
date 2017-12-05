//
//  colony.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 11/27/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation

struct Cell: CustomStringConvertible{
    let X:Int;
    let Y:Int;
    
    var description: String {
        return String(self.X) + ":" + String(self.Y);
    }
    
    func transform(_ x:Int,_ y:Int)->Cell{
        return Cell(X:self.X + x,Y:self.Y + y);
    }
}

class ColonyInterpretor{
    static func interpret(name:String,fromDiagram colony:String)->ColonyData?{
        var base = ColonyData(name:name,size:0,colony:Colony());
        
        let lines = colony.split(separator: "\n").map{ String($0) };
        
        let width  = lines.map{ $0.count }.max()!;
        let height = lines.count;
        
        base.size = max(width, height);
        
        for (yIndex,line) in lines.enumerated(){
            for (xIndex,character) in line.enumerated(){
                if character == "*"{
                    base.colony.setCellAlive(X:xIndex + 1,Y:yIndex + 1)
                }
            }
        }
        
        return base;
    }
}

struct Bound : CustomStringConvertible{
    let lBound : Cell;
    let rBound : Cell;
    
    var description:String{
        return "Lower Left Bound : \(lBound), Upper Right Bound : \(rBound)"
    }
}

func == (lhs: Cell, rhs: Cell) -> Bool {
    return lhs.X == rhs.X && lhs.Y == rhs.Y;
}

extension Cell: Hashable{
    var hashValue: Int{ return X.hashValue ^ Y.hashValue &* 16777619 }
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
        let xWidth = Cells.max(by:{ (a,b) in
            if a.X < b.X{
                return true;
            }
            return false;
        })?.X
        let yHeight = Cells.max(by:{ (a,b) in
            if a.Y < b.Y{
                return true;
            }
            return false;
        })?.Y
        
        guard let height = yHeight, let width = xWidth else{
            return "error";
        }
        
        var text = "";
        for x in 0...abs(height){ //Reverses description.
            for y in 0...abs(width){
                text += (self.isCellAlive(X: y, Y: x) ? "*" : "-");
            }
            text += "\n";
        }
        
        return text;
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
