//
//  ColonyData.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 12/4/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation

enum COLONY_DATA_TYPE{
    case save,template;
}

func == (a:ColonyData,b:ColonyData)->Bool{
    if a.name == b.name && a.size == b.size && a.colony.Cells == b.colony.Cells{
        return true;
    }
    return false;
}

class ColonyData : NSObject, NSCoding{
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let templateArchive = DocumentsDirectory.appendingPathComponent("templates")
    static let colonyArchive = DocumentsDirectory.appendingPathComponent("colonies")
    
    var name:String;
    var size:Int;
    var colony:Colony;
    var currentTopX  = 0.0;
    var currentTopY  = 0.0;
    var currentCZoom = 20.0;
    
    var dataType:COLONY_DATA_TYPE;
    
    var bounds:(Int,Int){
        if size <= 1000{
            return (size,size);
        }else{
            return (-1,-1);
        }
       
    }
    
    init(name:String,size:Int,colony:Colony,_ save:Bool=true){
        self.name = name;
        self.size = size;
        self.colony = colony;
       
        if (!save){
            dataType = .template;
        }else{
            dataType = .save;
        }
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(name, forKey: "name");
        aCoder.encode(size, forKey: "size");
        aCoder.encode(colony.runLengthSave, forKey: "colony");
        print("Encoded!");
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        guard let name = aDecoder.decodeObject(forKey: "name") as? String else {
            print("Error : No name");
            return nil;
        }
        
        let size = Int(aDecoder.decodeInt64(forKey: "size"));
        
        guard let colony = aDecoder.decodeObject(forKey: "colony") as? String else {
            print("Error : No colony");
            return nil;
        }
        
        self.init(name:name,size:size,colony:Colony.interpret(fromRLE: colony)!);
        self.colony.size = size;
    }
}
