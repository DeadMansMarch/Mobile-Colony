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
    if a.bounds == b.bounds && a.size == b.size && a.colony.Cells == b.colony.Cells{
        return true;
    }
    return false;
}

struct ColonyData : Equatable{
    var name:String;
    var size:Int;
    var colony:Colony;
    var currentTopX  = 0.0;
    var currentTopY  = 0.0;
    var currentCZoom = 20.0;
    
    var dataType:COLONY_DATA_TYPE;
    
    var bounds:(Int,Int){
        return (size,size);
    }
    
    init(name:String,size:Int,colony:Colony,_ save:Bool=true){
        self.name = name;
        self.size = size;
        self.colony = colony;
       
        if (!save){
            dataType = .template
        }else{
            dataType = .save;
        }
    }
}
