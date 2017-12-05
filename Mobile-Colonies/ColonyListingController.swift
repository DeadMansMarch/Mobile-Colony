//
//  MasterViewController.swift
//  Mobile-Colonies
//
//  Created by Ethan on 12/2/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit


class ColonyListingController:UITableViewController, UIPopoverPresentationControllerDelegate{
    var colonies = ColonyStore()
    
    var gameController: GridViewController?;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int{
        return (colonies.allColonies.count)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell{
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "GridCell", for: indexPath) as! GridCell
        
        let colony = colonies.allColonies[indexPath.row]
        
        cell.nameL.text = colony.name
        cell.sizeL.text = "\(colony.size)x\(colony.size)"
        
        return(cell)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedColony = self.colonies.allColonies[indexPath.row]
        
        gameController?.loadColony(colony: selectedColony)
        gameController?.redraw();
    }
    
    func addNewSave(withData:ColonyData){
        let newColony = colonies.createColony(Data:withData)
        
        let indexPath = IndexPath(row: newColony, section: 0)
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
            }));
            
            
            
            self.present(alert, animated: true, completion: nil);
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




