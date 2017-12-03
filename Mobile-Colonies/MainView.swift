//
//  MainView.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 11/27/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import UIKit

class ColonyView: UIView{
    var superposed:UIViewController?
    func superposition(of: UIViewController){
        superposed = of;
    }
    
    func repose(){
        setNeedsDisplay();
    }
    
    override func draw(_ rect: CGRect){
        if let superpose = superposed{
            (superpose as! DetailViewController).colony_width = Double(self.bounds.width);
            (superpose as! DetailViewController).superpos();
        }
    }
    
}
