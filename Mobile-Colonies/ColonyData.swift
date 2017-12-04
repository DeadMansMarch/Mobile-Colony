//
//  ColonyData.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 12/4/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation

struct ColonyData{
    var name:String;
    var size:Int;
    var colony:Colony;
    
    var bounds:(Int,Int){
        return (size,size);
    }
    
    init(name:String,size:Int,colony:Colony){
        self.name = name;
        self.size = size;
        self.colony = colony;
    }
}
