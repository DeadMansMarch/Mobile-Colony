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
            
            var indexPath:IndexPath? = tableView.indexPathForSelectedRow
            print("Index : \(indexPath)");
            //return;
            /*
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
 */
            
            if indexPath==nil || indexPath!.section == 0{
                print("Template index not found.");
                return;
            }
            
            print(indexPath!.section);
            print(indexPath!.row);
            
            tableView.deselectRow(at: indexPath!, animated:true);
            
            self.splitViewController!.toggleMasterView()
            //print(indexPath);
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
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Block Switching Engine",fromDiagram:
            """
            ***-*
            *----
            ---**
            -**-*
            *-*-*
            """)!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Slow Spaceship",fromDiagram:
            """
            -****--------------
            -*---*---------*---
            -*-----------**----
            --*--*--**-----***-
            -------***------***
            --*--*--**-----***-
            -*-----------**----
            -*---*---------*---
            -****--------------
            """
        )!);
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Static Spaceship",fromDiagram:
            """
            ---***---***---
            ---------------
            -**---*-*---**-
            -*----*-*----*-
            *-----*-*-----*
            -*----*-*----*-
            --***-----***--
            -
            -----**-**-----
            ----*-*-*-*----
            -----*---*-----
            """
        )!);
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
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Backrake",fromDiagram:
            """
            .....OOO...........OOO.....
            ....O...O.........O...O....
            ...OO....O.......O....OO...
            ..O.O.OO.OO.....OO.OO.O.O..
            .OO.O....O.OO.OO.O....O.OO.
            O....O...O..O.O..O...O....O
            ............O.O............
            OO.......OO.O.O.OO.......OO
            ............O.O............
            ......OOO.........OOO......
            ......O...O.........O......
            ......O.O....OOO...........
            ............O..O....OO.....
            ...............O...........
            ...........O...O...........
            ...........O...O...........
            ...............O...........
            ............O.O............
            """
        )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Cow",fromDiagram:
            """
            OO.......OO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO.....
            OO....O.OOO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO...OO
            ....OO.O.................................................O.O
            ....OO...OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO..
            ....OO.O..................................................O.
            OO....O.OOO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO.
            OO.......OO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO..OO.....
            """
            )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Dragon",fromDiagram:
            """
            .............O..OO......O..OOO
            .....O...OOOO.OOOOOO....O..OOO
            .OOOOO....O....O....OOO.......
            O......OO.O......OO.OOO..O.OOO
            .OOOOO.OOO........OOOO...O.OOO
            .....O..O..............O......
            ........OO..........OO.OO.....
            ........OO..........OO.OO.....
            .....O..O..............O......
            .OOOOO.OOO........OOOO...O.OOO
            O......OO.O......OO.OOO..O.OOO
            .OOOOO....O....O....OOO.......
            .....O...OOOO.OOOOOO....O..OOO
            .............O..OO......O..OOO
            """
            )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Electric Fence",fromDiagram:
            """
            ..........O..................................................
            .........O.O........................OO.......................
            ..O....OOO.O.....O...................O...O..O......O.....OO..
            .O.O..O....OO...O.O..................O.OOO..OOO...O.O....O...
            .O.O..O.OO.......O....................O...OO...O.O..O......O.
            OO.OO.O.O.OOOOO.....O..................OO...O..O.O.OO.OO..OO.
            .O.O..O...O..O..O.......OO...OO...OO....OO.OO..O.O..O.O.O....
            .O..OO....OO......OOO.OO...OO...OO...OOO.....OOOO.OOO.O...OO.
            ..O..OOO..O..O.OOOO...OO...OO...OO...OOO.OO..O....O.O....O..O
            ...OO...O.O..O.....OO...OO...OO...OO......O............O...OO
            .....OO.O.OO.O.OO..O......................O........OO.O......
            .....O.OO.O..O.OO....O.................OO.O.O................
            ...........OO.......OO..................O..OO................
            ......................................O.O....................
            ......................................OO.....................
            """
        )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Enterprise",fromDiagram:
            """
            .......OOO...........
            .....O.OO............
            ....OOOO.............
            ...OO.....O..........
            ..OOO..O.O.O.........
            .OO...O.O..O.........
            .O.O.OOOOO...........
            OO.O.O...O...........
            O........OO..........
            .OO..O...O.O.........
            ....OO..O.OO......O..
            ...........OO.....OOO
            ............O..OOO..O
            ............O..O..OO.
            .............O.OO....
            ............OO.......
            ............OO.......
            ...........O.........
            ............O.O......
            ...........O..O......
            .............O.......
            """
            )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Filter",fromDiagram:
            """
            ..........................
            ................OO........
            ..............O....O......
            ..........................
            .............O.O..O.O.....
            ...........OOOO.OO.OOOO...
            ........O.O....O..O....O.O
            ........OO.OO.O....O.OO.OO
            ...........O.O......O.O...
            ........OO.O.O......O.O.OO
            ........OO.O..........O.OO
            ...........O.O.OOOO.O.O...
            ...........O.O......O.O...
            ..........OO.O.OOOO.O.OO..
            ..........O..OOO..OOO..O..
            ............O..OOOO..O....
            ...........OO.O....O.OO...
            ...........O..O....O..O...
            ............O..O..O..O....
            .............OO....OO.....
            """
            )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Fly",fromDiagram:
            """
            ..O...............................
            .O.O..............................
            .O.O......................O.O...O.
            .O.......................OO.O.O..O
            ...........OOO........O.........O.
            OO.........OO..O.OO...O..OOOO.....
            .O.O.........OOOO..O.O..OO....OO..
            .OO........O..O...OOO.....OOO.....
            ..O.......O....O..OO..OO..O..O....
            ...O..O...O....O..OOO.O.O....OO...
            .......O.OO....O..OOOO.....O......
            ....OO...OO....O..OOOO.....O......
            ....O.O...O....O..OOO.O.O....OO...
            ...OO.....O....O..OO..OO..O..O....
            ....O.O....O..O...OOO.....OOO.....
            .....O.......OOOO..O.O..OO....OO..
            ...........OO..O.OO...O..OOOO.....
            ...........OOO........O.........O.
            .........................OO.O.O..O
            ..........................O.O...O.
            """
            )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Frothing Puffer",fromDiagram:
            """
            .......O.................O.......
            ......OOO...............OOO......
            .....OO....OOO.....OOO....OO.....
            ...OO.O..OOO..O...O..OOO..O.OO...
            ....O.O..O.O...O.O...O.O..O.O....
            .OO.O.O.O.O....O.O....O.O.O.O.OO.
            .OO...O.O....O.....O....O.O...OO.
            .OOO.O...O....O.O.O....O...O.OOO.
            OO.........OO.O.O.O.OO.........OO
            ............O.......O............
            .........OO.O.......O.OO.........
            ..........O...........O..........
            .......OO.O...........O.OO.......
            .......OO...............OO.......
            .......O.O.O.OOO.OOO.O.O.O.......
            ......OO...O...O.O...O...OO......
            ......O..O...O.O.O.O...O..O......
            .........OO....O.O....OO.........
            .....OO....O...O.O...O....OO.....
            .........O.OO.O...O.OO.O.........
            ..........O.O.O.O.O.O.O..........
            ............O..O.O..O............
            ...........O.O.....O.O...........
            """
            )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Hammerheads",fromDiagram:
            """
            ................O..
            .OO...........O...O
            OO.OOO.......O.....
            .OOOOO.......O....O
            ..OOOOO.....O.OOOO.
            ......OOO.O.OO.....
            ......OOO....O.....
            ......OOO.OOO......
            ..........OO.......
            ..........OO.......
            ......OOO.OOO......
            ......OOO....O.....
            ......OOO.O.OO.....
            ..OOOOO.....O.OOOO.
            .OOOOO.......O....O
            OO.OOO.......O.....
            .OO...........O...O
            ................O..
            """
            )!);
                
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Volcano",fromDiagram:
            """
            .........O..........................
            ........O.O.........................
            ......OOO.O.........................
            .....O....OO.O......................
            .....O.OO...OO......OO..............
            ....OO.O.OO.........O.O.............
            .........O.OOOOO......O..O.OO.......
            ..O.OO.OO.O.....O....OO.O.OO.O......
            .....OO.....OOOO........O....O......
            O...O.O..O...O.O....OO.O.OOOO.OO....
            O...O.O..OO.O.OO.OO....O.O....O.O...
            .....OO...OOO.OO.O.OOO.O..OOO...O...
            ..O.OO.OO.OO.............O.O..O.O.OO
            ...........O......O.O.O.O..OO.O.O.O.
            ....OO.O.O.OO......OO.O.O.O...O.O.O.
            .....O.OO.O..O.......O.OO..OOOO.OO..
            .....O....O.O........O...OO.........
            ....OO....OO........OO...O..O.......
            ...........................OO.......
            """
            )!);
            
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Portraitor",fromDiagram:
            """
            ...........OO...........
            ......OO.O....O.OO......
            ......O..........O......
            .......OO......OO.......
            ....OOO..OOOOOO..OOO....
            ....O..O........O..O....
            .OO.O.O..........O.O.OO.
            .O.O.O............O.O.O.
            ...O................O...
            .O..O..............O..O.
            ....O.......OOO....O....
            O...O.......O.O....O...O
            O...O.......O.O....O...O
            ....O..............O....
            .O..O..............O..O.
            ...O................O...
            .O.O.O............O.O.O.
            .OO.O.O..........O.O.OO.
            ....O..O........O..O....
            ....OOO..OOOOOO..OOO....
            .......OO......OO.......
            ......O..........O......
            ......OO.O....O.OO......
            ...........OO...........
            """
            )!);
            
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Puff Suppresor",fromDiagram:
            """
            ............O....................
            ..........OO.O...................
            ..........OO...O.................
            ........O...OO.O.....O...........
            ........OOOO.OO...OOOO.......O.O.
            ......O......O....OOO.....O.O..O.
            ......OOOOOOO...O...O....O..O....
            ...O.O......OO..O...O.O.OO....O..
            ..OOOOOOOOO.....O..OO........O...
            .OO..............O.OO.OOOO...O..O
            OO....OO.O..........O...O..O.O...
            .OO....O........OOO......O.O.O..O
            .........O......OO......O....OO..
            .OO....O........OOO......O.O.O..O
            OO....OO.O..........O...O..O.O...
            .OO..............O.OO.OOOO...O..O
            ..OOOOOOOOO.....O..OO........O...
            ...O.O......OO..O...O.O.OO....O..
            ......OOOOOOO...O...O....O..O....
            ......O......O....OOO.....O.O..O.
            ........OOOO.OO...OOOO.......O.O.
            ........O...OO.O.....O...........
            ..........OO...O.................
            ..........OO.O...................
            ............O....................
            """
        )!);

        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Ring Of Fire",fromDiagram:
            """
            ................O.................
            ..............O.O.O...............
            ............O.O.O.O.O.............
            ..........O.O.O.O.O.O.O...........
            ........O.O.O..OO.O.O.O.O.........
            ......O.O.O.O......O..O.O.O.......
            ....O.O.O..O..........O.O.O.O.....
            .....OO.O..............O..O.O.O...
            ...O...O..................O.OO....
            ....OOO....................O...O..
            ..O.........................OOO...
            ...OO...........................O.
            .O...O........................OO..
            ..OOOO.......................O...O
            O.............................OOO.
            .OOO.............................O
            O...O.......................OOOO..
            ..OO........................O...O.
            .O...........................OO...
            ...OOO.........................O..
            ..O...O....................OOO....
            ....OO.O..................O...O...
            ...O.O.O..O..............O.OO.....
            .....O.O.O.O..........O..O.O.O....
            .......O.O.O..O......O.O.O.O......
            .........O.O.O.O.OO..O.O.O........
            ...........O.O.O.O.O.O.O..........
            .............O.O.O.O.O............
            ...............O.O.O..............
            .................O................
            """
        )!);
            
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Snail",fromDiagram:
            """
            .O....................................
            .O....................................
            O.....................................
            .OOO.................OOO...OOO........
            .OO.O.........O...O.O......OOO........
            ..O...........OO.O.......O....OOOO....
            ......O......O...O.O...OO.O.....OO....
            ...O..O.OOO...OO.........O........OO.O
            ...OO.O.....O.....O.................O.
            .........O.OOOOOOO....................
            ......................................
            .........O.OOOOOOO....................
            ...OO.O.....O.....O.................O.
            ...O..O.OOO...OO.........O........OO.O
            ......O......O...O.O...OO.O.....OO....
            ..O...........OO.O.......O....OOOO....
            .OO.O.........O...O.O......OOO........
            .OOO.................OOO...OOO........
            O.....................................
            .O....................................
            .O....................................
            """
        )!);
                
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Spaceship",fromDiagram:
            """
            .............OO.....................................
            .....OO....OO.O.O...................................
            ....OOO....OOOO.....................................
            ...OO......OO.....O.................................
            ..OO..OO...O..O..O..................................
            .OO.....O.......O..OO...............................
            .OO.O...OOOO........................................
            ....O...OO..OO.O....................................
            .....OOO....O.O.....................................
            ......OO...OO..O....................................
            ......O.....O.......................................
            .OOOO.O..O..O...O...................................
            .OOO...OOOOO..OOOOOOO.O.............................
            O.O....O..........O..OO.............................
            OOO.O...O...O.....OOO...............................
            .......O.O..O.......OO..............................
            .O...O.....OO........OO..O.O........................
            ....O.......O........OOO.O.OOO......................
            ...O........OOO......O....O.........................
            .....O......O.O.....O.O.............................
            .....O......O.OO...O....O...........................
            .............O.OOOO...O.....O..O....................
            ............OO..OO.O.O...O.OOO......................
            .................O......O..OOO...OOO................
            ....................O..O......OO....................
            ................OO....O..O..........OO..............
            ..................O.............O...O...............
            ................OO....OO........O...................
            .................O...OOO........O.O.O.O.............
            .................O....OO........O.....OO............
            ........................O........O..OOO.............
            .....................O..O........O........O.........
            ..........................OOOO........OO...O........
            .......................O......OO......OO...O........
            .......................O....O............O..........
            .......................O...............O............
            .........................OO.O.O.......O..O..........
            .........................O....O.........OOO.........
            ............................OOO.OO..O...O...O.OO....
            .............................O..OO.O.....O...O..O...
            .....................................OO..O...O......
            ..................................O.OO.OO.O..OO...O.
            ...............................O.....O...O.......O.O
            ................................OO............OO...O
            ......................................O.......OO....
            .......................................OOO...OO..O..
            ......................................O..O.OOO......
            ......................................O....OO.......
            .......................................O............
            ..........................................O..O......
            .........................................O..........
            ..........................................OO........
            """
            )!);

            
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Wickstretcher",fromDiagram:
            """
            .................OO..............................
            .............OO....O.............................
            ............OOO.O................................
            O.OO..OO...O...OOOO.O.O....OO.......OO...........
            O....OO..O........O.OOO....O....OO.O..O.OO.O.....
            O.OO....OO.OO....O...........O...O.O.OO.O.OO.....
            ......O.......O.............OO.....O..O.O...OO...
            .....O.........O.O....OOO...O....O..O.O.OOO...O..
            .....O.........O.O....OOO.OO.O..OO.O.O...O..OO.O.
            ......O.......O.............OO.O...OO....OO....O.
            O.OO....OO.OO....O..........O........OO.O.O.OO.OO
            O....OO..O........O.OOO........O...O...OO.O..O.O.
            O.OO..OO...O...OOOO.O.O.......O.O...OO....O..O.O.
            ............OOO.O..............O.....O.OOO....O..
            .............OO....O.................O.O.........
            .................OO...................O..........
            """
            )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name:"Tubstretcher",fromRLE:
            """
            59b2o$58bo2bo$58bo2b2o$57b3o2bo$57b3o2bob2o$58b2o5b2o$58b2o$59b5ob2o$
            60b5o2$66bo$66b2o$67bo$68b2o$69b2o2bobo$73bob2o$72bo3bo$72b2o$72b2o2b
            3o$72b2o4b2o$72b2o6bo$73b5o2bo$74b6o$76b2o2$74b3o7b2o$74b3o6bo2bo$74bo
            2bo5bo2b2o$73bob2obo3b3o2bo$74b2obob2ob3o2bob2o$70bo2bo2b2ob2o2b2o5b2o
            $70b3o3bob3o2b2o$63bo5b3o3bobo6b5ob2o$62bobo3b2o4bo10b5o$62bo3b2o2bo2b
            2o$65bob3obob3o15bo$61bobo4bobob2o17b2o$60bobo2bo3b2obo19bo$60bo9b2o
            21b2o$58b3o3b2o5bo22b2o2bobo$58bo5bobobobo27bob2o$55bo2b2o5b2o5bo24bo
            3bo$54bobo2bob2o6bo3bo23b2o$53bobo7bo4bo2b2o24b2o2b3o$52bobo8bo5bo27b
            2o4b2o$51bobo12b3o28b2o6bo$50bobo10b2obo31b5o2bo$49bobo12b3o32b6o$48bo
            bo50b2o$47bobo13bo$46bobo13bobo$45bobo13bobo$44bobo13bobo$43bobo13bobo
            $42bobo13bobo$41bobo13bobo$40bobo13bobo$39bobo13bobo$38bobo13bobo$37bo
            bo$36bobo11b2obo$35bobo11b3o$34bobo12b2o3b2o$33bobo12bo4b2obo$32bobo
            14bo6b2o$31bobo21b2o$30bobo22bo$29bobo19bo4bo$28bobo20bo2b3o$27bobo$
            26bobo23bo$25bobo24b2ob2o$24bobo28bo$23bobo26bo2bo$22bobo28b2o$21bobo
            29b2o$20bobo31bo$19bobo33b2o$18bobo35bo$17bobo$16bobo$15bobo38b2o$14bo
            bo37bobo$13bobo38b2o$12bobo$11bobo41bo$10bobo41bobo$9bobo41bo2bo$8bobo
            41bo$7bobo45bo$6bobo46bo$5bobo45bobo$4bobo46b2o$3bobo$2bobo$bobo49b3o$
            obo49bob2o$2o50b2o$52b2o$53bo$52bobo$51bobo3$53b2o$51bobo$51b2o2$52bo$
            51bobo$50bo2bo$21b2o26bo$20bo2bo28bo$20bo2b2o27bo$19b3o2bo25bobo$19b3o
            2bob2o22b2o$20b2o5b2o$20b2o$21b5ob2o21b3o$22b5o22bob2o$49b2o$28bo20b2o
            $28b2o20bo$29bo19bobo$30b2o16bobo$31b2o6b2o$35b2o3b2obob2ob2o$34b2obob
            o3bo2bo2b2o$36bo6bobo2bobo$49b2o$48b2o$47b3o$49bo$47b2o!
            """
            )!);
        
        addNewTemplate(withData: ColonyInterpretor.interpret(name: "Hawk", fromRLE:
        """
        48b3o22b3o$46b2o3bo20bo3b2o109bo24bo$45bo3bo2bo18bo2bo3bo106b4o22b4o$45bo6b
        2obo12bob2o6bo105b2o3bo20bo3b2o$48b3ob2ob2o10b2ob2ob3o107bo5b3o16b3o5bo$45b
        3o3bob2o2bo8bo2b2obo3b3o107bobo4b2o10b2o4bobo$44b2o32b2o103bob4o4b2o10b2o4b
        4obo$56bo10bo114b8ob4o10b4ob8o$48b3o4b2o10b2o4b3o106b2o32b2o$39bo9b2o3b3o10b
        3o3b2o9bo102bo5b2o10b2o5bo$38bobob2o5b2o2b2o14b2o2b2o5b2obobo100bobo3bo2b
        o8bo2bo3bobo$37bo4b2o8b3o14b3o8b2o4bo90bo11bobo2bo10bo2bobo11bo$37bo3b3o6b
        o2bo16bo2bo6b3o3bo89b2ob3o5b4o18b4o5b3ob2o$52bo18bo103b2o5bo4b4o18b4o4bo5b
        2o$37b2ob2o13b2o10b2o13b2ob2o92bobo7bo2bo14bo2bo7bobo$36bobobo14b2ob2ob2ob
        2ob2o14bobobo87b2obo42bob2o$36bo3bob2o12bob2ob2ob2obo12b2obo3bo87b2ob2o13b
        3o8b3o13b2ob2o$37bo2bob2ob3o9b2o6b2o9b3ob2obo2bo87bobobobo15b2ob2ob2o15bob
        obobo$41bobo4b2o10bo2bo10b2o4bobo91bo3bob3obo8b2o4b2o4b2o8bob3obo3bo$46bob
        o8bo8bo8bobo100bo5b3o8b2ob4ob2o8b3o5bo$23bo9bob3o6bo3b3o7bo2b2o2bo7b3o3bo6b
        3obo9bo78bob3o2b2o7b2o6b2o7b2o2b3obo$22b2o9b2ob2o7bob2obob3o5bo2bo5b3obob
        2obo7b2ob2o9b2o72bo13bo10b2o10bo13bo$13b2o3b2obobo9bo4bo2b4o8b2o4b2o2b2o4b
        2o8b4o2bo4bo9bobob2o3b2o49b2o9bobobo7b2o3b2obo7b2o7bob2o3b2o7bobobo9b2o$10b
        2ob2o2bo3bo2bob2ob2obo2bo8bob3obo2b2o4b2o2b2o4b2o2bob3obo8bo2bob2ob2obo2b
        o3bo2b2ob2o47b2o7b2o4bo3bo2bob2ob3obo5bo2bo5bob3ob2obo2bo3bo4b2o7b2o$7b4o2b
        o2bo4b4o2bobo2b4o2bo5bob2ob2ob4ob2o6b2ob4ob2ob2obo5bo2b4o2bobo2b4o4bo2bo2b
        4o33b3o3bob2ob2o7b2ob3o4b3o6bo3bo5b2o5bo3bo6b3o4b3ob2o7b2ob2obo3b3o$6bo4b
        o4b2o5b2o2bobo2b2o4b2ob5o4bobo4bobob2obobo4bobo4b5ob2o4b2o2bobo2b2o5b2o4b
        o4bo28bob2o3bob2o2bo2b4ob4o2bo6bobobobob2o8bo2bo8b2obobobobo6bo2b4ob4o2bo2b
        2obo3b2obo$7b2o7b2o23bobo5b2obo4bobo4bobo4bob2o5bobo23b2o7b2o28b3o3b4o4bo5b
        obo5bo2b2o2bo7bobo2b3o3b2o3b3o2bobo7bo2b2o2bo5bobo5bo4b4o3b3o$53bob2obobo2b
        obob2obo73bo3bo4bo8bo7bo5b4o3b2obo3bobo2bob2o2b2obo2bobo3bob2o3b4o5bo7bo8b
        o4bo3bo$53b3o12b3o74bo8b2o22b2obo5b2ob2o3bobob2obobo3b2ob2o5bob2o22b2o8bo$22b
        o9bo20b2o2bo3b2o3bo2b2o20bo9bo88b2ob5o4b5ob2o$21b4o5b3ob3o18b2o2b6o2b2o18b
        3ob3o5b4o87bo4bo3b2o3bo4bo$8bo7b4o4b2o3b2o6bo10b2ob2o3bobo6bobo3b2ob2o10b
        o6b2o3b2o4b4o7bo43b2o9b2obo17bo16bo17bob2o9b2o$b2ob3ob3o5bobobobo3bobo3bob
        obo3b3o4bobob2o18b2obobo4b3o3bobobo3bobo3bobobobo5b3ob3ob2o32b2o2b2ob2o3b
        2ob2ob2o15b5ob3o2b3ob5o15b2ob2ob2o3b2ob2o2b2o$b2o4bo2b2ob2o2bo2b5obobo3bob
        2o3b2ob4obobobo5b2o6b2o5bobobob4ob2o3b2obo3bobob5o2bo2b2ob2o2bo4b2o20bob2o7b
        ob3o3b2o3b2obobo2bo3bo6b2ob2o2b3ob6ob3o2b2ob2o6bo3bo2bobob2o3b2o3b3obo7b2ob
        o$o2bob2o3bo2b2o5b2ob2obobobobobo4b2o3b2o32b2o3b2o4bobobobobob2ob2o5b2o2b
        o3b2obo2bo15b3ob2obob2o3b2o3bobo3bobo2bo2bobo2b2obobob2obo8bo6bo8bob2obob
        ob2o2bobo2bo2bobo3bobo3b2o3b2obob2ob3o$12bo6bobo3bo3bobo2bob2obo3bob3o11b
        6o11b3obo3bob2obo2bobo3bo3bobo6bo26bo6b2o2b5obo6bobobo3bobo7bo2bo5b2o18b2o5b
        o2bo7bobo3bobobo6bob5o2b2o6bo$19bo3bo10bob2o8bobo26bobo8b2obo10bo3bo34b2o3b
        o3bo3bo4bo6bobobobobobo4b2o4b2o9b8o9b2o4b2o4bobobobobobo6bo4bo3bo3bo3b2o$21b
        o8bo4bob2o4b2o3bo4b2o14b2o4bo3b2o4b2obo4bo8bo48bo5bobobobo3b3o2bob2ob2o6b
        o12b4o12bo6b2ob2obo2b3o3bobobobo5bo$30bo8b3obo6b2ob2o14b2ob2o6bob3o8bo66b
        o7bo3bo8bo2bobo26bobo2bo8bo3bo7bo$39bobo2b2obo2b2o3bo2bo6bo2bo3b2o2bob2o2b
        obo88bob4ob3o2bobo2b3o6b2o6b3o2bobo2b3ob4obo$45bob2o2bo4b2o2bo2bo2b2o4bo2b
        2obo98bobobobo3b3o3bo5b2o5bo3b3o3bobobobo$40b3obo12bo8bo12bob3o93bob2ob2ob
        3o3b2o14b2o3b3ob2ob2obo$57b2o6b2o113b2obob2ob2o20b2ob2obob2o$59bob2obo114b
        o40bo$61b2o116bo16bobo2bobo16bo$61b2o133bobo2bobo$195bo8bo$39b2o16bo8bo129b
        8o$36b2ob2o15b3o6b3o128b8o$33b4o2b2o4b2o8bo3bo4bo3bo125b3o6b3o$32bo4bo4b2ob
        2o8b2ob2o4b2ob2o124bo3bo4bo3bo$33b2o7b2o3bo144bo5bo2bo5bo$42b2o148bo5bo2b
        o5bo15b3ob2o$176b3o13b3ob3o2b3ob3o13b2o4b2o$172bob2o3bo40bo3bobo2bo$171b3o3b
        3o2b3o30b3o2b3o$170bo3bo4b3obobo28bobob3o$171bo7bo4bo30bo4bo$46bo104b2o27b
        2o36b2o$45bobo97bo5b2ob2o5b2o26b2o18b2o20bo11b4o$45bobo96b3o3bo3b2o4bob2o24b
        o2bo16bo2bo12b2o4b3obo8bobob2obo$46bo96bo3bo6b2o3bo2b2o2b3o2b3obo13b2o18b
        2o13b2ob2obob2obo3b3o2bo4b3o$144bobobobobo5bo2bob3o3bob3ob2o46bo3bo4bo3bob
        ob2o6bo3bo$150bobo3b4ob2o3b5o2bo3bo43bo4b3o4bob3o2b2o9b2o$150bobo3b2o3b2o3b
        2o6bo2bo42b2o3b2ob2o7bo2bobo8b2o$152bo13bo3b3o2bob2o39b2o2b2obobo3bo8bobob
        2o5bob2o$162bo3bo7b2obobo38b3ob2obo2bo4b3o2bobobob2o4b2obob2o$172bo2bobob
        2o38b2ob2obobo2bobo2b4obo4bo11bo$174bo2bo51bo6b2o5bo3b2ob2ob2obo$173b3obob
        2o7b3o18b3o10bo13bo3b4o3bo$46bo128bo47b2o12bo10b2o$45bobo127bo6b2o5bo20bo4b
        3o20bo$45bobo137bobobo20bobob2obo$46bo135bo7bo18bo$183b3o4bo18bo4b2o$184b
        obo4bo16bo4bobo$187bo3bo16bo3bo$188b4o16b4o$196bo$196bo$196bo2$46bo145b3o3b
        3o$45bobo$45bobo136b2o10bo$46bo137b3o9bo$186b2o2b2o4bo$186bobo2bo$191bo$186b
        o2bo$180b2o$181b2obo2bob3o$181bo3bobo3bo$181b3obobobo$181bo3bobo$181b3o3b
        2o$183b4o$185bo2$192b3o$191b2ob2o$190bobob2o$190bo3bo$191bo2bo$191b3o2$167b
        2o$164b2ob2o$161b4o2b2o4b2o$160bo4bo4b2ob2o4bo12b2o$161b2o7b2o3bo2bo6b2o5b
        2o$170b2o6bobo3bobo$178bobo$183bob2o$182b2obo$182b5o$181bo3b2o$181bo2bo6b
        o4bo$182b3o5bobob4o$190bo2bo4bo$191b3ob5o$194b2o2bo$196b2o2$216bo$215b4o$214b
        o3b2o$212b3o5bo$185b2o8bo13b2o4bobo$181b2o2b2o8b3o11b2o4b4obo$181b2o11bo3b
        o10b4ob8o$191b3o4bo21b2o$191b3obob2o10b2o5bo$191b2o3bo11bo2bo3bobo$209bo2b
        obo$213b4o$213b4o$205b3o3bo2bo$205bob2o$206bob2o$185b2o19bobo$181b2o2b2o14b
        o4b2o$181b2o18bobo$190b2o9b2o$190b2o8$185b2o$181b2o2b2o$181b2o$190b2o$190b
        2o6$192bo$192bobo9bo$185b2o5b2o9b4o$181b2o2b2o11bo3bo3b2ob2o$181b2o14b4o5b
        o2b2o$190b2o4bo3bo7bo2bo$190b2o5bobo2bo$201bo2$184bo$184bo$183bobo$181b2o$181b
        o$183bo3bo$182b2o3bo$180b3o4bo7$166b3o$162bob2o3bo$161b3o3b3o2b3o10bo$160b
        o3bo4b3o3bo9bo$161bo7bo3b2o10bo$170b2o9b3o$183bo$179bo3bo$178bo2b2o2$178b
        2o9$181b2o$181bobo$182bo10$181b2o$181bobo$182bo10$181b2o$181bobo$182bo!

        """
        )!)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view!.isKind(of: UITableViewCell.classForCoder())){
            return false;
        }
        return true;
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




