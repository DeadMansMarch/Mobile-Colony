//
//  ViewController.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 11/15/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import UIKit

class GridViewController: UIViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {
    
    var leftController:ColonyListingController?;
    
    @IBOutlet var menu: UIButton!
    
    @IBOutlet var colonyName: UILabel!
    @IBOutlet var colonyX: UILabel!
    @IBOutlet var colonyY: UILabel!
    
    var settingsController:SettingsController?
    
    var currentColony:ColonyData? = ColonyData(name:"My First Colony",size:50,colony:Colony(size: 50));
    var colonyWidth:Double!;
    
    var colonyTopX:Double = 0.5; // current colony position (top left x is 0)
    var colonyTopY:Double = 0.5; // current colony position (top left y is 0)
    var colonyDrawZoom:Double = 20; // # of boxes on horizontal axis.
    
    var activeTemplate:ColonyData?;
    var activePosition:CGPoint?;
    var activeTemplateOrigin:Cell?;
    
    var templateMode = false;
    var templateModeCurrent = Set<Cell>();
    var lastInsertedCell:Cell? = nil;
    var inTempCache = [Cell:Bool]();
    var cacheLife  = 0;
    var minX = 0,maxX = 0, minY = 0, maxY = 0
    
    var displayUnboundCells = false;
    var wrapping = false;
    var drawgrid = false;
    
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
        if var colony = currentColony{
            colony.currentCZoom = colonyDrawZoom;
            leftController!.reSave(withData:colony);
        }
        
        templateMode = false;
        
        colonyTopX = colony.currentTopX;
        colonyTopY = colony.currentTopY;
        colonyDrawZoom = colony.currentCZoom;
        self.evolveSpeedSlider.value = 0;
        self.evolveSpeedChanged(self.evolveSpeedSlider);
        self.currentColony = colony;
        updateColonyName();
        updateColonyXY();
    }
    
    func unloadColony(){
        self.currentColony = nil;
        
        self.evolveSpeedSlider.value = 0;
        self.evolveSpeedChanged(self.evolveSpeedSlider);
        
        self.colonyTopX = 0;
        self.colonyTopY = 0;
        self.colonyName.text = "No Colony Loaded";
        self.colonyX.text = "";
        self.colonyY.text = "";
        redraw();
    }
    
    func updateColonyName(){
        self.colonyName.text = currentColony!.name;
    }
    
    func updateColonyXY(){
        colonyX.text = "X: \(Int(floor(colonyTopX)))";
        colonyY.text = "Y: \(Int(floor(colonyTopY)))";
    }
    
    func UpdateEvolveSpeed(){
        evolveSpeedLabel.text = "x\(evolveSpeed)";
    }
    
    @IBAction func evolveSpeedChanged(_ sender: Any) {
        if templateMode{
            evolveSpeedSlider.value = 0;
            return;
        }
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
        
        var xcell = ((Double(x-10)) / size) + 1 + colonyTopX
        var ycell = ((Double(y-10)) / size) + 1 + colonyTopY
        
        if xcell < 0{
            xcell = -1 * ceil(abs(xcell))
        }
        
        if ycell < 0{
            ycell = -1 * ceil(abs(ycell))
        }
        return Cell(
            Int(xcell),
            Int(ycell)
        );
    }
    
    func updateTemplateRanges(_ cell: Cell){
        inTempCache.removeAll();
        cacheLife = 0;
        let first = templateModeCurrent.count == 0;
        
        if first{
            lastInsertedCell = nil;
        }
        
        if cell.X < minX || first{
            minX = cell.X;
        }
        if cell.X > maxX || first{
            maxX = cell.X
        }
    
        if cell.Y < minY || first{
            minY = cell.Y
        }
        if cell.Y > maxY || first{
            maxY = cell.Y
        }
        
        if let last = lastInsertedCell{
            if abs(cell.X - last.X) >= 1 || (abs(cell.Y - last.Y) >= 1){
                if (cell.X - last.X != 0){
                    let slope = Double(cell.Y - last.Y) / Double(cell.X - last.X)
                    let yInt  = Double(cell.Y) - (slope * Double(cell.X))
                    
                    let lowerCoor = (last.X > cell.X) ? cell.X : last.X;
                    let upperCoor = (last.X > cell.X) ? last.X : cell.X
                    let getYForX = {
                        return Int(ceil(($0 * slope) + yInt))
                    }
                    
                    for i in stride(from:Double(lowerCoor),to:Double(upperCoor),by:0.05){
                        templateModeCurrent.insert(Cell(Int(i),getYForX(i)));
                    }
                }else{
                    let lowerCoor = (last.Y > cell.Y) ? cell.Y : last.Y;
                    let upperCoor = (last.Y > cell.Y) ? last.Y : cell.Y
                    for i in lowerCoor...upperCoor{
                        templateModeCurrent.insert(Cell(cell.X,i));
                    }
                }
            }
        }
        lastInsertedCell = cell;
        templateModeCurrent.insert(cell);
    }
    
    func cellInDrawnTemplate(_ cell: Cell)->Bool{
        if (inTempCache[cell] != nil){
            return true;
        }else if !inTempCache.isEmpty && cacheLife > 0{
            return false;
        }
        
        print("wasnt cached");
        
        if cell.X > maxX || cell.Y > maxY || cell.X < minX || cell.Y < minY{
            return false;
        }
        //Given X,Y of cell, minX,minY,maxX,maxY of templateModeCurrent line set,
        //cast ray from minX,Y to X,Y, count distinct boundary changes -> xBC.
        //cast ray from X,minY to X,Y, count distinct boundary changes -> yBC
        //if both xBC and yBC are odd and non-zero, the cell is within polygon.
        let ray1 = templateModeCurrent.filter({ $0.Y == cell.Y }).filter{ $0.X <= cell.X }.map{ $0.X }
        let ray2 = templateModeCurrent.filter({ $0.X == cell.X }).filter{ $0.Y <= cell.Y }.map{ $0.Y }
        
        func cast(_ list:[Int])->Int{
            var last = 0;
            
            return list.sorted().reduce(0,{
                let readLast = last;
                last = $1
                return $0 + ((readLast == 0 || readLast+1 != $1) ? 1 : 0)
            });
        }
        
        let inDrawnTemplate = cast(ray1) % 2 != 0 && cast(ray2) % 2 != 0
        if (inDrawnTemplate){
            inTempCache[cell] = true;
        }
        return inDrawnTemplate;
    }
    
    func outOfBounds(_ truex:Double,_ truey:Double)->Bool{
        if getSetting(for: "prettywrap"){
            return false;
        }
        return currentColony!.bounds.0 > 0 && currentColony!.bounds.1 > 0 &&
            (Int(truex) > currentColony!.bounds.0 || Int(truey) > currentColony!.bounds.1 || truex < 0 || truey < 0)
    }
    
    func onBounds(_ truex:Double, _ truey:Double)->Bool{
        return
            (truex == Double(currentColony!.bounds.0) - 1 && truey <= Double(currentColony!.bounds.1) - 1 && truey > 0) ||
            (truey == Double(currentColony!.bounds.1) - 1 && truex <= Double(currentColony!.bounds.0) - 1 && truex > 0) ||
            (truex == 0 && truey <= Double(currentColony!.bounds.1) - 1 && truey > 0) ||
            (truey == 0 && truex <= Double(currentColony!.bounds.0) - 1 && truex > 0)
    }
    
    func readyTemplate(_ template: ColonyData,_ sender : UILongPressGestureRecognizer){
        //print("ready!");
        activeTemplate = template;
        activePosition = sender.location(in:self.view);
        redraw();
    }
    
    func passTemplateTransform(_ sender: UILongPressGestureRecognizer,_ ending:Bool=false){
        guard let template = activeTemplate else{
            print("no template");
            return;
        }
        
        activePosition = sender.location(in:self.view)
        if (ending){
            let cell = activeTemplateOrigin!
            let union = currentColony!.colony.Cells.union(template.colony.Cells.map{
                Cell($0.X+cell.X,$0.Y+cell.Y,size:currentColony!.colony.size)
            });
            currentColony!.colony.Cells = union;
            activeTemplate = nil;
        }
        redraw();
    }
    
    var defaults = [
        "visibility":false,
        "prettywrap":true
    ]
    
    func getSetting(for tag:String)->Bool{
        return (settingsController?.settings[tag] ?? defaults[tag] ?? false)
    }
    
    func superpos(){ //This will be executed in the view's drawing methods.
        let topx = self.colonyTopX;
        let topy = self.colonyTopY;
        let zoom = self.colonyDrawZoom;
        
        let size = ((colonyWidth - 20) - Double(zoom - 1)) / Double(zoom)
        
        let btx = (topx - floor(topx)) * size;
        let bty = (topy - floor(topy)) * size;
        
        let scaledSize = (Double(colonyBacking.bounds.width),Double(colonyBacking.bounds.height))
        let scaledZero = (10-btx+(size*(0 - floor(topx) - 1)),10-bty+(size*(0 - floor(topy) - 1)));
        
        let draw = ceil(scaledSize.0 / size) + 1
        
        guard currentColony != nil else{
            //Draw "Select or Create a different colony"?
            return;
        }
        
        let scaledMaxX = 0 - floor(topx) + Double(currentColony!.bounds.0);
        let scaledMaxY = 0 - floor(topy) + Double(currentColony!.bounds.1);
        let scaledMax:(Double,Double) = (
            10-btx+(size*(scaledMaxX)),
            10-bty+(size*(scaledMaxY))
        );
        
        let visibility = getSetting(for:"visibility");
        let prettywrap = getSetting(for:"prettywrap");
        let drawgrid = getSetting(for:"drawgrid");
        
        if visibility{
            let path = UIBezierPath(rect: CGRect(x:0,y:0,width:scaledSize.0,height:scaledSize.1));
            UIColor.black.setFill();
            path.fill();
        }
        
        
        if (currentColony!.size <= 1000 && !prettywrap){
            UIColor.black.setFill();
            if visibility{
                UIColor.white.setFill();
            }
            if (scaledZero.0 > 0){
                let path = UIBezierPath(rect: CGRect(x:0,y:0,width:scaledZero.0,height:scaledSize.1));
                
                path.fill();
            }
            
            if (scaledZero.1 > 0){
                let path = UIBezierPath(rect: CGRect(x:0,y:0,width:scaledSize.0,height:scaledZero.1));
                path.fill();
            }
            
            if (scaledMax.0 < scaledSize.0){
                let path = UIBezierPath(rect: CGRect(x:scaledMax.0,y:0,width:scaledSize.0 - scaledMax.0,height:scaledSize.1));
                path.fill();
            }
            
            if (scaledMax.1 < scaledSize.1){
                let path = UIBezierPath(rect: CGRect(x:0,y:scaledMax.1,width:scaledSize.0,height:scaledSize.1 - scaledMax.1));
                path.fill();
            }
        }
        
        func drawCell(_ localX:Int,_ localY:Int)->UIBezierPath{
            let cell = CGRect(
                x:10-btx+(size*Double(localX-1)),
                y:10-bty+(size*Double(localY-1)),
                width: size, height:size);
            return UIBezierPath(rect: cell);
        }
        
        func modifyPath(_ path:UIBezierPath,living:Bool,_ truex:Double,_ truey:Double){
            let current = Cell(Int(truex),Int(truey));
            if visibility{
                UIColor.black.setStroke();
            }else{
                UIColor.white.setStroke();
            }
            if living{
                UIColor.blue.setFill();
                if (templateMode && !cellInDrawnTemplate(current)){
                    UIColor.lightGray.setFill();
                }
                if (visibility && !templateMode){
                    UIColor.white.setFill();
                }
                path.fill();
            }else if !living && !templateMode{
                UIColor.black.setStroke();
            }else if templateMode && templateModeCurrent.contains(current){
                UIColor.green.setFill();
                path.fill();
            }
            
            path.lineWidth = (visibility ? 1 : 2);
            if colonyDrawZoom < 300{
                path.stroke();
            }
        }
        
        var toDraw = currentColony!.colony.Cells.filter{
            $0.X >= Int(floor(topx))-2 && $0.Y >= Int(floor(topy))-2 && $0.X < Int(floor(topx) + draw) && $0.Y < Int(floor(topy) + draw)
        }
        
        toDraw.forEach({
            let truex = Double($0.X)
            let truey = Double($0.Y)
            
            let x = Int(truex) - Int(floor(topx))
            let y = Int(truey) - Int(floor(topy))
            
            let path = drawCell(x,y);
            
            modifyPath(path,living:true,truex,truey)
        });
        
        cacheLife += 1;
        
        if (templateMode){
            toDraw = templateModeCurrent
            toDraw.forEach{
                let truex = Double($0.X)
                let truey = Double($0.Y)
                
                let x = Int(truex) - Int(floor(topx))
                let y = Int(truey) - Int(floor(topy))
                
                let path = drawCell(x,y)
                
                UIColor.green.setFill();
                path.fill();
            }
        }
        
        if let template = activeTemplate, !templateMode{
            let origin = activePosition!;
            let cX = 10 + Double(origin.x) - remainder(Double(origin.x),size);
            let cY = 10 + Double(origin.y) - remainder(Double(origin.y),size)
            
            activeTemplateOrigin = convert(x:Int(cX),y:Int(cY)).transform(-1,-2);
            let startX = Double(activeTemplateOrigin!.X) - colonyTopX;
            let startY = Double(activeTemplateOrigin!.Y) - colonyTopY;

            if startX < draw && startY < draw{
                let toDraw = template.colony.Cells.filter{
                    $0.X >= Int(floor(topx))-2 && $0.Y >= Int(floor(topy))-2 && $0.X < Int(floor(topx) + draw) && $0.Y < Int(floor(topy) + draw)
                }
                
                toDraw.forEach{
                    let truex  = $0.X + activeTemplateOrigin!.X
                    let truey = $0.Y + activeTemplateOrigin!.Y
                    
                    let x = Int(truex) - Int(floor(topx))
                    let y = Int(truey) - Int(floor(topy))
                    
                    let path = drawCell(x,y);
                    
                    UIColor.white.setStroke();
                    UIColor.orange.setFill();
                    path.lineWidth = 2;
                    path.stroke();
                    path.fill();
                }
                
            }
        }
    }
    
    func redraw(){
        colonyBacking.setNeedsDisplay();
    }
    
    @IBAction func zoom(_ sender: UIPinchGestureRecognizer) {
        guard currentColony != nil else{
            return;
        }
        
        if sender.view != nil {
            let newScale = colonyDrawZoom / Double(sender.scale);
            let center = sender.location(in: self.view);
            let ratio = (
                Double(center.x) / Double(colonyBacking.bounds.width),
                Double(center.y) / Double(colonyBacking.bounds.height)
            );
            
            let zoom = self.colonyDrawZoom;
            
            if newScale <= 250 && newScale >= 2 || getSetting(for:"visibility") && newScale <= 700 && newScale >= 2{
                colonyTopX += (zoom * ratio.0 * Double(sender.scale - 1))
                colonyTopY += (zoom * ratio.1 * Double(sender.scale - 1))
                
                colonyDrawZoom = newScale;
            }else if newScale > 700 && getSetting(for:"visibility"){
                colonyDrawZoom = 700;
            }else if newScale > 250{
                colonyDrawZoom = 250;
            }else{
                colonyDrawZoom = 2;
            }
            
            sender.scale = 1;
            updateColonyXY()
            redraw();
        }
    }

    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        guard currentColony != nil else{
            return;
        }
        
        let zoom = self.colonyDrawZoom;
        let size = ((colonyWidth - 20) - Double(zoom - 1)) / Double(zoom)
        
        let translation = sender.translation(in: self.colonyBacking);
        colonyTopX -= Double(translation.x) / size
        colonyTopY -= Double(translation.y) / size
        updateColonyXY()
        sender.setTranslation(CGPoint.zero, in: self.colonyBacking)
        redraw();
    }
    
    @IBAction func singleToggle(_ sender: UITapGestureRecognizer) {
        guard currentColony != nil else{
            return;
        }
        let location = sender.location(in: colonyBacking)
        let cell = convert(x:Int(location.x),y:Int(location.y));
        if templateMode{
            updateTemplateRanges(cell);
        }else{
            currentColony!.colony.toggleCellAlive(X:cell.X,Y:cell.Y)
        }
       
        redraw();
    }
    
    var toggled = Set<Cell>();
    
    @IBAction func multiToggle(_ sender: UIPanGestureRecognizer){
        guard currentColony != nil else{
            return;
        }
        
        if (sender.state == .ended){
            toggled.removeAll();
            return;
        }else if sender.state == .began{
            lastInsertedCell = nil;
        }
        
        let location = sender.location(in: colonyBacking);
        let cell = convert(x:Int(location.x),y:Int(location.y));
        guard (!toggled.contains(cell)) else{
            return;
        }
        if (templateMode){
            updateTemplateRanges(cell);
        }else{
            currentColony!.colony.toggleCellAlive(X:cell.X,Y:cell.Y)
            toggled.insert(cell)
        }
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
    
    func getName(_ prompt: String?,_ callback:@escaping (String)->()){
        let alert = UIAlertController(title: prompt ?? "Make Template", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (field:UITextField) in
            field.placeholder = "Enter Name";
        })
        
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { x in
            let name = alert.textFields![0].text
            callback(name ?? "");
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func publish(_ sender: Any) {
    }
    
    @IBAction func save(_ sender: Any){
        if (templateMode){
            let alert = UIAlertController(title: "Save Template?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Save To User Templates", style: .default, handler: { x in
                self.getName("Enter Template Name",{ x in
                    if (x != ""){
                        self.templateMode = false;
                        self.redraw();
                        
                        let templateData = ColonyData(name:x,size:0,colony:Colony());
                        
                        for x in self.minX ... self.maxX{ //This might not be most efficient way...
                            for y in self.minY...self.maxY{
                                if (self.cellInDrawnTemplate(Cell(x,y)) && self.currentColony!.colony.isCellAlive(X: x, Y: y)){
                                    templateData.colony.setCellAlive(X: x, Y: y)
                                }
                            }
                        }
                        
                        self.leftController!.addNewUTemplate(withData: templateData)
                    }else{
                        self.save(sender)
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "Do Not Save", style: .destructive, handler: { x in
                self.templateMode = false;
                self.redraw();
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert,animated: true,completion: nil);
        }else{
            templateMode = true;
            templateModeCurrent.removeAll();
            redraw();
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else{
            return;
        }
        
        let controller = segue.destination
        controller.popoverPresentationController!.delegate = self
        controller.preferredContentSize = CGSize(width: 300, height: 500)
        
        let pop = (controller.popoverPresentationController!);
        
        switch(id){
        case "settings":
            
            if self.settingsController != nil{
                (controller as! SettingsController).settings = self.settingsController!.settings;
            }
            self.settingsController = controller as! SettingsController;
            self.settingsController!.linkedDrawController = self;
            pop.sourceRect = publish.bounds.offsetBy(dx: 13, dy: 2)
            pop.backgroundColor = UIColor.black;

            break;
        case "upload":
            pop.sourceRect = publish.bounds.offsetBy(dx: 0, dy: -10)
            pop.backgroundColor = UIColor.black;
            break;
        default:
            break;
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        //do som stuff from the popover
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (currentColony!.name == "My First Colony"){
            leftController?.addNewSave(withData: currentColony!);
        }
        
        ControllerView.layer.cornerRadius = 10;
        self.splitViewController!.toggleMasterView();
        
        updateColonyXY();
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
    
}


