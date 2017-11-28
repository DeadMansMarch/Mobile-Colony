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
    
    var colony_topx:Double = 0; // current colony position (top left x is 0)
    var colony_topy:Double = 0; // current colony position (top left y is 0)
    var colony_box_zoom:Double = 20; // # of boxes on horizontal axis.
    
    var cache = [Cell : UIBezierPath]();
    
    @IBOutlet var evolve_speed: UISlider!
    @IBOutlet var evolve_speed_txt: UILabel!
    var evl_speed:Double = 0;
    var thread_kill = Set<Double>();
    var evl_threaded = false;
    
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
        let last_speed = evl_speed;
        
        if position <= 10{
            evl_speed = round(Double(position)) / 10
        }else{
            evl_speed = floor(Double(position) - 9)
        }
        
        if evl_speed > 0 && !evl_threaded || last_speed < evl_speed{
            thread_kill.insert(last_speed);
            evl_threaded = true;
            let queue = DispatchQueue.global();
            queue.async{
                while self.evl_speed > 0{
                    let cspeed = self.evl_speed;
                    usleep(UInt32(1000000 / self.evl_speed))
                    if (!self.thread_kill.contains(cspeed) && self.evl_speed != 0.0){
                        OperationQueue.main.addOperation{
                            self.current_colony.evolve();
                            self.redraw();
                        }
                    }else{
                        OperationQueue.main.addOperation{
                            self.thread_kill.remove(cspeed)
                        }
                        
                        break;
                    }
                    
                }
                self.evl_threaded = false;
            }
        }
        update_evl_speed();
    }
    
    func convert(x:Int,y:Int)->Cell{
        let zoom = self.colony_box_zoom;
        let size = ((colony_width - 20) - Double(zoom - 1)) / Double(zoom)
        
        let xcell = ((Double(x-10)) / size) + 1 + colony_topx
        let ycell = ((Double(y-10)) / size) + 1 + colony_topy
        return Cell(
            X: Int(xcell),
            Y: Int(ycell)
        );
    }
    
    func superpos(){ //This will be executed in the view's drawing methods.
        let topx = self.colony_topx;
        let topy = self.colony_topy;
        let zoom = self.colony_box_zoom;
        
        let size = ((colony_width - 20) - Double(zoom - 1)) / Double(zoom)
        print(size)
        for x in -2...Int(ceil(zoom))+Int(zoom / 5){
            for y in -2...Int(ceil(zoom))+Int(zoom / 10){
                let truex = Double(x) + floor(topx);
                let truey = Double(y) + floor(topy);
                
                let btx = (topx - floor(topx)) * size;
                let bty = (topy - floor(topy)) * size;
                let cell = CGRect(
                            x:10-btx+(size*Double(x-1)),
                            y:10-bty+(size*Double(y-1)),
                            width: size, height:size);
                
                let path:UIBezierPath = UIBezierPath(rect: cell);
                UIColor.black.setStroke();
                if truex < 1 || truey < 1{
                    UIColor.red.setStroke();
                    UIColor.red.setFill()
                    path.fill()
                }else if current_colony.isCellAlive(X: Int(truex), Y: Int(truey)){
                    UIColor.blue.setFill()
                    path.fill()
                }
                
                path.lineWidth = 2;
                path.stroke();
            }
            
        }
    }
    
    func redraw(){
        colony_backing.setNeedsDisplay();
    }
    
    @IBAction func zoom(_ sender: UIPinchGestureRecognizer) {
        print(sender);
        if let view = sender.view {
            let newScale = colony_box_zoom * Double(sender.scale);
            if newScale <= 100 && newScale >= 2{
                colony_box_zoom = newScale;
            }else if newScale > 100{
                colony_box_zoom = 100;
            }else{
                colony_box_zoom = 2;
            }
            
            sender.scale = 1;
            redraw();
        }
    }
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view);
        colony_topx += Double(translation.x) / 500;
        colony_topy += Double(translation.y) / 500;
        update_colony_xy(x:Int(floor(colony_topx)),y:Int(floor(colony_topy)))
        redraw();
    }
    
    @IBAction func singleToggle(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: colony_backing)
        let cell = convert(x:Int(location.x),y:Int(location.y));
        print(cell)
        current_colony.toggleCellAlive(X:cell.X,Y:cell.Y)
        redraw();
    }
    
    var toggled = Set<Cell>();
    
    @IBAction func multiToggle(_ sender: UIPanGestureRecognizer){
        if (sender.state == .ended){
            toggled.removeAll();
            return;
        }
        
        let location = sender.location(in: colony_backing);
        let cell = convert(x:Int(location.x),y:Int(location.y));
        guard (!toggled.contains(cell)) else{
            return;
        }
        
        current_colony.toggleCellAlive(X:cell.X,Y:cell.Y)
        toggled.insert(cell)
        redraw();
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

