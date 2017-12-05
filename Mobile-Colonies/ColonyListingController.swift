//
//  MasterViewController.swift
//  Mobile-Colonies
//
//  Created by Ethan on 12/2/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit


class ColonyListingController:UITableViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate{
    var colonies = ColonyStore();
    var usertemplates = ColonyStore();
    var templates = ColonyStore();
    
    var currentColony: ColonyData?;
    
    var gameController: GridViewController?;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int{
        if (section == 0){
            return colonies.allColonies.count;
        }else if section == 1{
            return usertemplates.allColonies.count
        }else{
            return templates.allColonies.count;
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Colonies";
        }else if section == 1{
            return "User Templates"
        }else{
            return "System Templates"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "GridCell", for: indexPath) as! GridCell
        if (indexPath.section == 0){
            let colony = colonies.allColonies[indexPath.row]
            
            cell.nameL.text = colony.name
            if colony.size <= 1000{
                cell.sizeL.text = "\(colony.size)x\(colony.size)"
            }else{
                cell.sizeL.text = "InfxInf"
            }
        }else if indexPath.section == 1{
            let colony = usertemplates.allColonies[indexPath.row]
                
            cell.nameL.text = colony.name
            cell.sizeL.text = ""
        }else{
            let colony = templates.allColonies[indexPath.row]
            
            cell.nameL.text = colony.name
            cell.sizeL.text = ""
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0){
            let selectedColony = self.colonies.allColonies[indexPath.row]
            
            currentColony = selectedColony;
            gameController?.loadColony(colony: selectedColony)
            gameController?.redraw();
        }else{
            
        }
        
        
    }
    
    func addNewSave(withData:ColonyData){
        let newColony = colonies.createColony(Data:withData)
        
        let indexPath = IndexPath(row: newColony, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func addNewUTemplate(withData:ColonyData){
        let newColony = usertemplates.createColony(Data:withData)
        
        let indexPath = IndexPath(row: newColony, section: 1)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func addNewTemplate(withData:ColonyData){
        let newColony = templates.createColony(Data:withData)
        
        let indexPath = IndexPath(row: newColony, section: 2)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func reSave(withData:ColonyData){
        let ind = colonies.allColonies.index(of: withData);
        guard let index = ind else{
            return;
        }
        colonies.allColonies[index] = withData;
    }
    
    @IBAction func toggleEditingMode(_ sender: UIBarButtonItem){
        if isEditing{
            sender.title = "Edit";
            
            setEditing(false, animated: false)
        } else {
            sender.title = "Done";
            setEditing(true, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section > 1{
            return false;
        }
        return true;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let colony = colonies.allColonies[indexPath.row]
            
            
            let alert = UIAlertController(
                title: "Delete \(colony.name)?",
                message: "Are you sure you want to delete this item?",
                preferredStyle: .alert);
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                self.colonies.removeColony(colony)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                if (Optional(colony) == self.currentColony || self.tableView(tableView, numberOfRowsInSection: 0) == 0){
                    self.gameController!.unloadColony();
                }
            }));
            
            
            
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    
    @IBAction func activateTemplate(_ sender: UILongPressGestureRecognizer){
        if (sender.state == .began){
            let location = sender.location(in:self.view);
            let table = (self.view as! UITableView);
            var indexPath:IndexPath?;
            for (index,row) in self.templates.allColonies.enumerated(){
                var usercells = (self.view as! UITableView).rectForRow(at: IndexPath(row:index,section:1));
                var systcells = (self.view as! UITableView).rectForRow(at: IndexPath(row:index,section:2));
                usercells = usercells.offsetBy(dx:-table.contentOffset.x, dy:-table.contentOffset.y)
                systcells = systcells.offsetBy(dx:-table.contentOffset.x, dy:-table.contentOffset.y)
                if usercells.contains(location) || systcells.contains(location) {
                    indexPath = IndexPath(row:index,section:(usercells.contains(location) ? 1 : 2));
                    break;
                }
            }
            if (indexPath == nil){
                return;
            }
            self.splitViewController!.toggleMasterView()
            self.gameController!.readyTemplate((indexPath!.section == 2 ? self.templates : self.usertemplates).allColonies[indexPath!.row],sender);
            
        }else if (sender.state == .changed){
            self.gameController!.passTemplateTransform(sender)
        }else if (sender.state == .ended){
            self.gameController!.passTemplateTransform(sender,true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else{
            print("segue, no id.");
            return;
        }
        
        let controller = segue.destination
        controller.popoverPresentationController!.delegate = self
        
        
        let pop = (controller.popoverPresentationController!);
        
        switch(id){
            case "add":
                controller.preferredContentSize = CGSize(width: 300, height: 250)
                (controller as! AddController).fedCallback = { x in
                    print("adding new save");
                    self.addNewSave(withData: x);
                }
                break;
            default:
                break;
        }
    }
    
    override func viewDidLoad() {
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Blinker",fromDiagram:
            """
            *
            *
            *
            """)!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Toad",fromDiagram:
            """
            --*-
            *  *
            *  *
            -*
            """)!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Beacon",fromDiagram:
            """
            **--
            *---
            ---*
            --**
            ----
            """)!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Pulsar",fromDiagram:
            """
            --***----***--
            --------------
            *----*--*----*
            *----*--*----*
            *----*--*----*
            --***----***--
            --------------
            --***----***--
            *----*--*----*
            *----*--*----*
            *----*--*----*
            --------------
            --***----***--
            """)!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Pentadecathlon",fromDiagram:
            """
            ***
            *-*
            ***
            ***
            ***
            ***
            *-*
            ***
            """)!);
        
        
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Glider",fromDiagram:
            """
            -*-
            --*
            ***
            """)!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Lightweight Spaceship",fromDiagram:
            """
            *---*-
            -----*
            *----*
            -*****
            """)!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Gosper Glider Gun",fromDiagram:
            """
            ------------------------*-----------
            ----------------------*-*-----------
            ------------**------**------------**
            -----------*---*----**------------**
            **--------*-----*---**--------------
            **--------*---*-**----*-*-----------
            ----------*-----*-------*-----------
            -----------*---*--------------------
            ------------**----------------------
            """)!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Block Switching Engine",fromDiagram:
            """
            ***-*
            *----
            ---**
            -**-*
            *-*-*
            """)!);
        
        
        
    }
    
}

extension UISplitViewController {
    func toggleMasterView() {
        let current = self.preferredDisplayMode
        if current == UISplitViewControllerDisplayMode.automatic{
            //self.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden;
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                self.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden;
                (self.viewControllers[1] as! GridViewController).redraw();
            }, completion: nil);
            
        }else{
            //self.preferredDisplayMode = UISplitViewControllerDisplayMode.automatic;
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                self.preferredDisplayMode = UISplitViewControllerDisplayMode.automatic;
                (self.viewControllers[1] as! GridViewController).redraw();
            }, completion: nil);
            
        }
        (self.viewControllers[1] as! GridViewController).redraw();
    }
}




