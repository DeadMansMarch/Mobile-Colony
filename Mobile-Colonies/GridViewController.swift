//
//  ViewController.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 11/15/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import UIKit

class GridViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var gridName: UILabel!
    @IBOutlet var gridSize: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var sizeField: UITextField!
    
    var grid: Grid? {
        didSet (newGrid) {
            self.refreshUI()
        }
    }
    
    @IBOutlet var menu: UIButton!
    
    @IBOutlet var colonyName: UILabel!
    @IBOutlet var colonyX: UILabel!
    @IBOutlet var colonyY: UILabel!
    
    var currentColony:ColonyData? = ColonyData(name:"Untitled Colony",size:50,colony:Colony());
    var colonyWidth:Double!;
    
    var colonyTopX:Double = 0; // current colony position (top left x is 0)
    var colonyTopY:Double = 0; // current colony position (top left y is 0)
    var colonyDrawZoom:Double = 20; // # of boxes on horizontal axis.
    
    var displayUnboundCells = false;
    var wrapping = false;
    
    var cache = [Cell : UIBezierPath]();
    
    @IBOutlet var evolveSpeedSlider: UISlider!
    @IBOutlet var evolveSpeedLabel: UILabel!
    var evolveSpeed:Double = 0;
    var threadKill = Set<Double>();
    var threaded = false;
    
    @IBOutlet var publish: UIButton!
    @IBOutlet var save: UIButton!
    @IBOutlet var settings: UIButton!
    
    @IBOutlet var colonyBacking: UIView!
    
    @IBOutlet var ControllerView: UIView!
    
    func loadColony(colony:ColonyData){
        self.currentColony = colony;
        updateColonyName()
    }
    
    func updateColonyName(){
        self.colonyName.text = currentColony!.name;
    }
    
    func updateColonyXY(x:Int, y:Int){
        colonyX.text = "X: \(x)";
        colonyY.text = "Y: \(y)";
    }
    
    func UpdateEvolveSpeed(){
        evolveSpeedLabel.text = "x\(evolveSpeed)";
    }
    
    @IBAction func evolveSpeedChanged(_ sender: Any) {
        let position = evolveSpeedSlider.value;
        let lastSpeed = evolveSpeed;
    
        if position <= 10{
            evolveSpeed = round(Double(position)) / 10
        }else{
            evolveSpeed = floor(Double(position) - 9)
        }
        
        if evolveSpeed > 0 && !threaded || lastSpeed < evolveSpeed{
            threadKill.insert(lastSpeed);
            threaded = true;
            let queue = DispatchQueue.global();
            queue.async{
                while self.evolveSpeed > 0{
                    let cspeed = self.evolveSpeed;
                    usleep(UInt32(1000000 / self.evolveSpeed))
                    if (!self.threadKill.contains(cspeed) && self.evolveSpeed != 0.0){
                        OperationQueue.main.addOperation{
                            self.currentColony!.colony.evolve();
                            self.redraw();
                        }
                    }else{
                        OperationQueue.main.addOperation{
                            self.threadKill.remove(cspeed)
                        }
                    
                        break;
                    }
                    
                }
                self.threaded = false;
            }
        }
        UpdateEvolveSpeed();
        
    }
    
    func convert(x:Int,y:Int)->Cell{
        let zoom = self.colonyDrawZoom;
        let size = ((colonyWidth - 20) - Double(zoom - 1)) / Double(zoom)
        
        let xcell = ((Double(x-10)) / size) + 1 + colonyTopX
        let ycell = ((Double(y-10)) / size) + 1 + colonyTopY
        return Cell(
            X: Int(xcell),
            Y: Int(ycell)
        );
    }
    
    func outOfBounds(_ truex:Double,_ truey:Double)->Bool{
        return currentColony!.bounds.0 > 0 && currentColony!.bounds.1 > 0 &&
            (Int(truex) > currentColony!.bounds.0 || Int(truey) > currentColony!.bounds.1 || truex < 0 || truey < 0)
    }
    
    func onBounds(_ truex:Double, _ truey:Double)->Bool{
        return
            (truex - 1 == Double(currentColony!.bounds.0) && truey <= 1 + Double(currentColony!.bounds.1) && truey > -1) ||
            (truey - 1 == Double(currentColony!.bounds.1) && truex <= Double(currentColony!.bounds.0) && truex > -1) ||
            (truex == -1 && truey <= Double(currentColony!.bounds.1) + 1 && truey > -2) ||
            (truey == -1 && truex <= Double(currentColony!.bounds.0) + 1 && truex > -1)
    }
    
    func superpos(){ //This will be executed in the view's drawing methods.
        let topx = self.colonyTopX;
        let topy = self.colonyTopY;
        let zoom = self.colonyDrawZoom;
        
        let size = ((colonyWidth - 20) - Double(zoom - 1)) / Double(zoom)
        
        let btx = (topx - floor(topx)) * size;
        let bty = (topy - floor(topy)) * size;
        
        let draw = Double(Int(ceil(zoom))+Int(zoom / 5));
        let scaledSize = (Double(colonyBacking.bounds.width),Double(colonyBacking.bounds.height))
        let scaledZero = (10-btx+(size*(0 - floor(topx) - 1)),10-bty+(size*(0 - floor(topy) - 1)));
        
        let scaledMaxX = 0 - floor(topx) + Double(currentColony!.bounds.0);
        let scaledMaxY = 0 - floor(topy) + Double(currentColony!.bounds.1);
        let scaledMax:(Double,Double) = (
            10-btx+(size*(scaledMaxX)),
            10-bty+(size*(scaledMaxY))
        );
        
        if scaledZero.0 > scaledSize.0 || scaledMax.0 <= 0 || scaledZero.1 > scaledSize.1  || scaledMax.1 <= 0 {
            let path = UIBezierPath(rect: self.colonyBacking.bounds);
            UIColor.black.setFill();
            path.fill();
            return;
        }
        
        if (scaledZero.0 > 0){
            let path = UIBezierPath(rect: CGRect(x:0,y:0,width:scaledZero.0,height:scaledSize.1));
            UIColor.black.setFill();
            path.fill();
        }
        
        if (scaledZero.1 > 0){
            let path = UIBezierPath(rect: CGRect(x:0,y:0,width:scaledSize.0,height:scaledZero.1));
            UIColor.black.setFill();
            path.fill();
        }
        
        if (scaledMax.0 < scaledSize.0){
            let path = UIBezierPath(rect: CGRect(x:scaledMax.0,y:0,width:scaledSize.0 - scaledMax.0,height:scaledSize.1));
            UIColor.black.setFill();
            path.fill();
        }
        
        if (scaledMax.1 < scaledSize.1){
            let path = UIBezierPath(rect: CGRect(x:0,y:scaledMax.1,width:scaledSize.0,height:scaledSize.1 - scaledMax.1));
            UIColor.black.setFill();
            path.fill();
        }
        
        for x in -2...Int(draw){
            for y in -2...Int(draw){
                let truex = Double(x) + floor(topx);
                let truey = Double(y) + floor(topy);
                if currentColony!.colony.isCellAlive(X: Int(truex), Y: Int(truey)) && !outOfBounds(truex, truey){
                    let cell = CGRect(
                        x:10-btx+(size*Double(x-1)),
                        y:10-bty+(size*Double(y-1)),
                        width: size, height:size);
                    
                    let path:UIBezierPath = UIBezierPath(rect: cell);
                    UIColor.white.setStroke();
                    if !wrapping{
                        UIColor.blue.setFill();
                        path.fill();
                    }else{
                        
                    }

                    path.lineWidth = 2;
                    path.stroke();
                }
            }
        }
        print("drawn");
    }
    
    func redraw(){
        colonyBacking.setNeedsDisplay();
    }
    
    @IBAction func zoom(_ sender: UIPinchGestureRecognizer) {
        print("zoomed");
        if sender.view != nil {
            let newScale = colonyDrawZoom / Double(sender.scale);
            let center = sender.location(in: self.view);
            let ratio = (
                Double(center.x) / Double(colonyBacking.bounds.width),
                Double(center.y) / Double(colonyBacking.bounds.height)
            );
            
            let zoom = self.colonyDrawZoom;
            
            if newScale <= 100 && newScale >= 2{
                colonyTopX = colonyTopX + (zoom * ratio.0 * Double(sender.scale - 1))
                colonyTopY = colonyTopY + (zoom * ratio.1 * Double(sender.scale - 1))
                
                colonyDrawZoom = newScale;
            }else if newScale > 100{
                colonyDrawZoom = 100;
            }else{
                colonyDrawZoom = 2;
            }
            
            sender.scale = 1;
            updateColonyXY(x:Int(floor(colonyTopX)),y:Int(floor(colonyTopY)))
            redraw();
        }
    }
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        print("pan");
        let translation = sender.translation(in: self.colonyBacking);
        colonyTopX -= Double(translation.x) / 25
        colonyTopY -= Double(translation.y) / 25
        updateColonyXY(x:Int(floor(colonyTopX)),y:Int(floor(colonyTopY)))
        sender.setTranslation(CGPoint.init(x: 0, y: 0), in: self.colonyBacking)
        redraw();
    }
    
    @IBAction func singleToggle(_ sender: UITapGestureRecognizer) {
        print("tapped");
        let location = sender.location(in: colonyBacking)
        let cell = convert(x:Int(location.x),y:Int(location.y));
        print(cell)
        currentColony!.colony.toggleCellAlive(X:cell.X,Y:cell.Y)
        redraw();
    }
    
    var toggled = Set<Cell>();
    
    @IBAction func multiToggle(_ sender: UIPanGestureRecognizer){
        if (sender.state == .ended){
            toggled.removeAll();
            return;
        }
        
        let location = sender.location(in: colonyBacking);
        let cell = convert(x:Int(location.x),y:Int(location.y));
        guard (!toggled.contains(cell)) else{
            return;
        }
        
        currentColony!.colony.toggleCellAlive(X:cell.X,Y:cell.Y)
        toggled.insert(cell)
        redraw();
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            if (!otherGestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.classForCoder())){
                return true;
            }
            return false;
    }
    
    @IBAction func toggleMenu(_ sender: UIButton){
        self.splitViewController!.toggleMasterView();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ControllerView.layer.cornerRadius = 10;
        self.splitViewController!.toggleMasterView();
        
        updateColonyXY(x: 0, y: 0);
        UpdateEvolveSpeed();
        
        colonyBacking.layer.zPosition = 2;
        ControllerView.layer.zPosition = 3;
        
        (colonyBacking as! ColonyView).superposition(of:self);
        updateColonyName();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return(true)
    }
    
    func refreshUI() {
        if (grid != nil){
            gridName?.text = grid!.name
            gridSize?.text = String(grid!.size)
            nameField?.text = grid!.name
            sizeField?.text = String(grid!.size)
            currentColony!.colony = grid!.colony
            redraw()
        }
    }
}

extension GridViewController: GridSelectionDelegate{
    func gridSelected(newGrid: Grid) {
        grid = newGrid
    }
}


