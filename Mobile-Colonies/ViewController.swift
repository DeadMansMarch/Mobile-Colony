//
//  ViewController.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 11/15/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var menu: UIButton!
    
    @IBOutlet var colony_x: UILabel!
    @IBOutlet var colony_y: UILabel!
    
    let colony_topx = 0; // current colony position (top left x is 0)
    let colony_topy = 0; // current colony position (top left y is 0)
    let colony_box_zoom = 20; // # of boxes on horizontal axis.
    
    var cache = [Cell : UIBezierPath]();
    
    @IBOutlet var evolve_speed: UISlider!
    @IBOutlet var evolve_speed_txt: UILabel!
    var evl_speed:Double = 0;
    
    @IBOutlet var publish: UIButton!
    @IBOutlet var save: UIButton!
    @IBOutlet var settings: UIButton!
    
    @IBOutlet var colony_backing: UIView!
    
    var colony_width:Double!;

    
    let current_colony = Colony();
    var visualize: ColonyView!;
    
    func update_colony_xy(x:Int, y:Int){
        colony_x.text = "X: \(x)";
        colony_y.text = "Y: \(y)";
    }
    
    func update_evl_speed(){
        evolve_speed_txt.text = "x\(evl_speed)";
    }
    
    @IBAction func evolve_speed_change(_ sender: Any) {
        let position = evolve_speed.value;
        
        if position <= 10{
            evl_speed = round(Double(position)) / 10
        }else{
            evl_speed = floor(Double(position) - 9)
        }
        
        update_evl_speed();
    }
    
    func superpos(){ //This will be executed in the view's drawing methods.
        let topx = self.colony_topx;
        let topy = self.colony_topy;
        let zoom = self.colony_box_zoom;
        
        let spacing = 200.0 / Double(zoom);
        let size = ((colony_width - 20) - (spacing * Double(zoom - 1))) / Double(zoom)
        print(size)
        for x in 1...zoom{
            for y in 1...zoom{
                let truex = x + topx;
                let truey = x + topy;
                
                let cell = CGRect(x: 10 + ((spacing + size) * Double(x - 1)), y:10 + ((spacing + size) * Double(y - 1)), width: size, height:size);
                let path:UIBezierPath = UIBezierPath(rect: cell);
                UIColor.black.setStroke();
                path.lineWidth = 4;
                path.stroke();
                
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update_colony_xy(x: 0, y: 0);
        update_evl_speed();
        
        colony_backing.layer.zPosition = 1;
        
        (colony_backing as! ColonyView).superposition(of:self);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

