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
            if (indexPath.section == 0){
                let colony = colonies.allColonies[indexPath.row]
                
                let alert = UIAlertController(
                    title: "Delete colony \(colony.name)?",
                    message: "Are you sure you want to delete this colony?",
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
            }else{
                let template = usertemplates.allColonies[indexPath.row]
                
                let alert = UIAlertController(
                    title: "Delete \(template.name)?",
                    message: "Are you sure you want to delete this template?",
                    preferredStyle: .alert);
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
                
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                    
                    self.usertemplates.removeColony(template)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                }));
                
                
                
                self.present(alert, animated: true, completion: nil);
            }
        }
    }
    
    
    @IBAction func activateTemplate(_ sender: UILongPressGestureRecognizer){
        if (sender.state == .began){
            let location = sender.location(in:self.view);
            let table = (self.view as! UITableView);
            
            var indexPath:IndexPath? = tableView.indexPathForSelectedRow
            print("Index : \(indexPath)");
            
            if indexPath==nil || indexPath!.section == 0{
                print("Template index not found.");
                return;
            }
            
            print(indexPath!.section);
            print(indexPath!.row);
            
            tableView.deselectRow(at: indexPath!, animated:true);
            
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
        
        addNewTemplate(withData: Colony.interpret(name:"Blinker",fromDiagram:
            """
            *
            *
            *
            """)!);
        
        addNewTemplate(withData: Colony.interpret(name:"Toad",fromDiagram:
            """
            --*-
            *  *
            *  *
            -*
            """)!);
        
        addNewTemplate(withData: Colony.interpret(name:"Beacon",fromDiagram:
            """
            **--
            *---
            ---*
            --**
            ----
            """)!);
        
        addNewTemplate(withData: Colony.interpret(name:"Pulsar",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Pentadecathlon",fromDiagram:
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
        
        
        
        addNewTemplate(withData: Colony.interpret(name:"Glider",fromDiagram:
            """
            -*-
            --*
            ***
            """)!);
        
        addNewTemplate(withData: Colony.interpret(name:"Lightweight Spaceship",fromDiagram:
            """
            *---*-
            -----*
            *----*
            -*****
            """)!);
        
        addNewTemplate(withData: Colony.interpret(name:"Block Switching Engine",fromDiagram:
            """
            ***-*
            *----
            ---**
            -**-*
            *-*-*
            """)!);
        
        addNewTemplate(withData: Colony.interpret(name:"Slow Spaceship",fromDiagram:
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
        addNewTemplate(withData: Colony.interpret(name:"Static Spaceship",fromDiagram:
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
        addNewTemplate(withData: Colony.interpret(name:"Gosper Glider Gun",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Backrake",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Cow",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Dragon",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Electric Fence",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Enterprise",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Filter",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Fly",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Frothing Puffer",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Hammerheads",fromDiagram:
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
                
        addNewTemplate(withData: Colony.interpret(name:"Volcano",fromDiagram:
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
            
        addNewTemplate(withData: Colony.interpret(name:"Portraitor",fromDiagram:
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
            
        addNewTemplate(withData: Colony.interpret(name:"Puff Suppresor",fromDiagram:
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

        addNewTemplate(withData: Colony.interpret(name:"Ring Of Fire",fromDiagram:
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
            
        addNewTemplate(withData: Colony.interpret(name:"Snail",fromDiagram:
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
                
        addNewTemplate(withData: Colony.interpret(name:"Spaceship",fromDiagram:
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

            
        addNewTemplate(withData: Colony.interpret(name:"Wickstretcher",fromDiagram:
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
        
        addNewTemplate(withData: Colony.interpret(name:"Tubstretcher",fromRLE:
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
        
        addNewTemplate(withData: Colony.interpret(name: "Hawk", fromRLE:
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
        
        addNewTemplate(withData: Colony.interpret(name: "BREEDER", fromRLE:
        """
    166b6o$165bo5bo95bobo$171bo95bo2bo$165bo4bo42b2o34b4o17b2o51b2o$167b2o
    43bo2bo32b6o14bo3bo48bo4bo62bo$212bobo33b4ob2o14bob3o53bo61b4o$211bo
    40b2o4bo15bo46bo5bo62b3o$242b2o14b3obo6b4o2bo46b6o42b6o14bo3bo78b2o$
    185b3o54bobo14b2o2bo8bo2bo93bo5bo16b3o76bo4bo$259bo3b2o4b3ob3o99bo3bo
    10bo4bo81bo$179b2o24b2o7bobo5bo34b3o5bo6b2o86b3o6bo4bo4bob2o8b6o74bo5b
    o95bobo119bo$138b2o39b2o24b2o6bo2bo4bobo19b3o9bo2bo2b2ob3o3bo88bo3bo7b
    2o9b4o10b2o74b6o95bo2bo51b6o43b2o16b4o$136bo4bo49bobo19bo3bo3bobo19bo
    5b4o4bo9bo3bobo61b3o20bo5bo19b2o5b2o3bo179b2o49bo5bo41bo4bo15b3o117bob
    o$113b4o25bo19b2o23b2obo3bo18b2o3bo3bo26b9o3bo4b3o4b2o48b2o15bo17bo3b
    2o14bob2obo3bo2bo2b2o163b2o14bo3bo54bo47bo14bo3bo52b2o61bo2bo$112bo3bo
    19bo5bo19b2o22bo2bo4bo18bo28bobo3b2o2bo7bo11b2o49b2o14bobo17bo2b2o13bo
    2bo4b3o4bobo159b4ob2o14bob3o47bo4bo42bo5bo16b3o48b4ob2o42b4o17b2o$116b
    o20b6o19b2o23b2ob3o22b2o2bo23b2o3b3o3b4o3b2o5b5o66bobo19b3o9b2o3b2o2b
    2o5bo3b3o158b6o4bo15bo33b3o12b2o14bo30b6o3bo10bo4bo47b6o42b6o14bo3bo$
    107bobo2bo2bo47bo50bo4bo28b3o2bo3b5o7bobo68bo20b3o9bob4o8b3o5bo128b2o
    29b4o5b3obo6b4o2bo32bobo6bo23bo37bob2o8b6o47b4o43b4ob2o14bob3o$164b2o
    23b2ob2o21b3o38bo12bo31bo28bo3bo34b2ob2o7bobo7bo3bo102b3o22b6o36b2o2bo
    8bo2bo32bobo5bobo19bo3bo25b2o12b4o10b2o97b2o4bo15bo$107bo2bo52b4o20b4o
    b2o51bo2b3o2bo3b5o7bobo28b3o27b2ob2o34b2ob2ob4o4bo5b2o3bo72b3o51b5o3bo
    35bo3b2o4b3ob3o29b5o30b4o23bo2bo13b2o5b2o3bo36b2o28b2o36b3obo6b4o2bo$
    107bo3bo52b4o18bob2o56b5o3b4o3b2o5b5o56bobobobo37bo5b5o8b2o74bo23b2o
    15bo10b2o4b3o6bo27b3o5bo6b2o32b3o5bo4bo10b2o6bo3bo4bo19bo2bo7bob2obo3b
    o2bo2b2o37bobo28b2o37b2o2bo8bo2bo112bobo$108bobo27b2ob2o24bo17bo2bo8b
    2o45bob4o2bo7bo11b2o26b2o26b3o2bo41bobo11b2o77bo23b2o14bobo8bo2b2obobo
    6bobo19b3o2bo2bo2b2ob3o3bo34b2o23b2o9bo4bobo19bo8bo2bo4b3o4bobo37bo7bo
    bo13b2o7bo26b2o8bo3b2o4b3ob3o49b2o61bo2bo$108bobo22b2o2bobo24bo21b2o4b
    2o50bobo2b9o3bo4b3o4b2o31b2o19bo3bo3bo37bo5b5o8b2o24bo2bo45b3o38bobo9b
    ob2o10bobo19b3o4bo9bo3bobo65bo6bobo25bo3b2o2b2o5bo3b3o32b2o2bo2bo3bo2b
    o12b3o5bobo5bo21bo6b3o5bo6b2o47b4ob2o42b4o17b2o$108bo24b3obobobob2o17b
    obo3b2o21b3o4bo45b2o3b4o4bo9bo3bobo6bo47bo4bo35b2ob2ob4o4bo5b2o3bo27bo
    20b6o27bo32bo10bob2o4b3o4bo21b7o3bo4b3o4b2o39bo3bo28bo20bo6b4o8b3o5bo
    32b2o10bobo12bo7b2o5bobo20bo4bo2bo2b2ob3o3bo50b6o27b3o12b6o14bo3bo50b
    2o$104bob2o29b3o5bo8b2o4b2ob2o3b2o85bo2bo2b2ob3o3bo7bo3bo20b2o24b2o2bo
    35b2ob2o7bobo7bo3bo22bo3bo19bo5bo26bobo49b2ob2o27bo6bo11b2o42bo51bo12b
    obo7bo3bo40bo4bo13b2obobo9bobo20bo6bo9bo3bobo48b4o28b2ob2o10b4ob2o14bo
    b3o47bo4bo62bo$102b2obo2bo24b7o3bobo7bo2bo3b3o20b2ob2o6bobo34b5o21b3o
    5bo6b2o9bo18b2o2b2o21bob5o37bob4o8b3o5bo23b4o25bo26b2o3bo19b2o25b2ob2o
    20bo6b5o3b2o5b5o71b2o23bo7b2o4bo5b2o3bo37bo4b2o32bo25b4o3bo4b3o4b2o98b
    2o4bo15bo52bo61b4o$105bo2bo22bo3bo4bo2b3o5bo34b2o7bo34bo4bo23bo3b2o4b
    3ob3o2bo4bo20bo24b6obo36b2o3b2o2b2o5bo3b3o46bo4bo31bobo18bobo26bo22bo
    10b5o7bobo34b2o36b2o24b5obo2b5o8b2o39bob4o56bo7bo11b2o80b2ob2o20b3obo
    6b4o2bo45bo5bo62b3o$103bob3o26b2o16b2ob2o9bo16b3o49bo23b2o2bo8bo2bo3b
    5o13b2o30b2o2bo3bo39bo2bo4b3o4bobo49b2o33bobo19b2ob4o52bobo12bo38bo30b
    o34bo2bo11b2o37b3o3b3o31b2o25b6o3b2o5b5o58bo21b2o2b2o21b2o2bo8bo2bo46b
    6o42b6o14bo3bo49b4o62bobo53b2o$90b5o8b4o24bo3b2o3bo12b2o10bobo62bo3bo
    23b3obo6b4o2bo20bo2bo36bo41bob2obo3bo2bo2b2o85bo18b2obobob2o44bo10b5o
    7bobo33bo2bo8bobo18b5o27b5obo2b5o8b2o74b2o25bo4b5o7bobo59bo21b5o22bo3b
    2o4b3ob3o93bo5bo16b3o48b6o61bo2bo50bo4bo62bo$89bo4bo10b2o25b3o4bo24bo
    2bo64bo25bo15bo21bo34bo52b2o5b2o3bo77b2o23b2obobo3bo43bo6b5o3b2o5b5o
    31bobobo12bo15bo5bo25bo7b2o4bo5b2o3bo34b2o10b4o54bo12bo48b2o11bo3bo17b
    o2bo13bo7b3o5bo6b2o101bo3bo10bo4bo47b4ob2o63b2o55bo61b4o$94bo70b2o102b
    ob3o21bo35bo18b6o26b4o10b2o56bo18bo2bo23bo2b2o2bo51bo6bo11b2o33b3o5b2o
    2bo2b2o12b3o2bob2o24bo11bobo7bo3bo33b3o8b7o16b2o30bo4b5o7bobo46b2o14bo
    bo16b3o14bo5bo2bo2b2ob3o3bo38b3o27b3o27bo4bo4bob2o8b6o50b2o46b2o14bo3b
    o33bo14bo5bo62b3o$89bo3bo7bo3bo162bo3bo9b2o12bobo9b2o21bo17bo5bo23bob
    2o8b6o24b3o30bo15bo2bo2bo4bo17b2o2b3obo21b2o26b7o3bo4b3o4b2o4b5o23b3o
    6bo2bo2bo14b2o2bobo25b2o4b4o8b3o5bo31b2o3bo7bob2ob2o15bo2b2o28b6o3b2o
    5b5o53bo7bobo17b6o10bo7bo9bo3bobo34bo2bo6bo23b2o25bo12b4o10b2o32bo60b
    4ob2o14bob3o32b2o14b6o42b6o14bo3bo$91bo10bo2bobo20b2o22b3o115b2o10b2o
    13bo10b2o45bo23bo10bo4bo23b2ob2o29b2o10bo5b4obo3bobo14b2o4bo34bo17b3o
    4bo9bo3bobo4bo4bo23b3o5b2obobo17bo31bobobo3b2o2b2o5bo3b3o31bo12bobo2b
    2o15bo4bo27bo7bo11b2o51b3o7bo20b2ob2o14b4o3bo4b3o4b2o31bo3bo5b2ob2o17b
    o3b2o26bo13b2o5b2o3bo32bobo59b6o4bo15bo31b3o60bo5bo16b3o$104bo2b3o18b
    2o24bo112bo2bo78bo4bo37b3o23bo3bo26bo13b2ob2obob3o7b2o16b3obo32bo3bo
    15b3o2bo2bo2b2ob3o3bo12bo20b2ob2o7b2ob3o2bo14b3o35bo2bo4b3o4bobo8b2o
    28bo6b4o19bo3bo29b4o3bo4b3o4b2o49b2o29bobob2o10b4o6bo11b2o31bob3o21b2o
    9b2o4bo20bobo6bob2obo3bo2bo2b2o33b2ob2o5bo51b6o5b3obo6b4o2bo32b2o65bo
    3bo10bo4bo68b6o$104bobobo43bo114bobo81b2o37bo3bo22bo3bo26b3o5b3o4b2o6b
    o2b2o21b3o41bo21b3o5bo6b2o4bo3bo22bobo15bo16bo10b2o25bob2obo3bo2bo2b2o
    5b3ob2o34bobobo19b3o26bo6bo9bo3bobo52bobo26bo3bo11b2ob5o3b2o5b5o32bobo
    8bo3bo10bo7b3o5bobo20bo6bo2bo4b3o4bobo32bo3bo6bo22bo2bo24b2o11b2o2bo8b
    o2bo32b3o53b2o3bo4bo4bob2o8b6o66bo5bo95bobo$105b3o45bo157bo78b3o4bo19b
    obobo25bo4bo10b2o3bo3b2o3bo58bo4bo23bo3b2o4b3ob3o4bo25bo11b5o26bo4bo
    29b2o5b2o3bo3b5o23b2ob2o11bobo46bo4bo2bo2b2ob3o3bo51bo5bo27bo2bo11b2ob
    o3b5o7bobo43b5o27bobo20bo4bo2b2o2b2o5bo3b3o30bo33bo3bo23bo2bo10bo3b2o
    4b3ob3o28bo4bo54bobo4b2o9b4o10b2o71bo95bo2bo$106bo202bob3o75b4o2bo3bo
    19bob2o25b2o2b3o17bo5bo58b5o23b2o2bo8bo2bo40b3o2bo33bo26b4o10b2o3b3o
    26bo14b2o46bo6b3o5bo6b2o23b2o29bo27b3o16bobo12bo78bo22b8o8b3o5bo34bo
    20b2o8bo2bo3bo19b3o9b3o5bo6b2o34bo30b3o23b2o17b2o5b2o3bo66bo4bo78b4o
    17b2o$103bo25bo180b5o74bo10bo17bob3o26b6o9bobo6b2o3bo85b3obo6b4o2bo13b
    2o24bob2o30bo5bo23bob2o8b6o43b2o30b4o26bo3b2o4b3ob3o20bo2bo22bobo2b2o
    42b2obo3b5o7bobo99bo9bobo7bo3bo30b2o23b2o14bobo28bo2bo2b2ob3o3bo56b2o
    15bo21b2o10bob2obo3bo2bo2b2o70b2o79b6o14bo3bo$102bobo23bobo176b3o2b3o
    80bo4bo16bob2obo31bo10bo8bo2bo86bo15bo14b2o23bo2bo32b6o23bo10bo4bo5bo
    37bo2bo28b6o25b2o2bo8bo2bo19b3ob2o20bo4bob2o41b2ob5o3b2o5b5o32bobo37b
    2o23bo5b3o4bo5b2o3bo72bobo26bo3bo9bo3bobo53b2o14bobo18bob2o9bo2bo4b3o
    4bobo151b4ob2o14bob3o$102bo2bo22bo2bo175b6o83b5o16bobo155bob3o118b3o5b
    o12b2o24bo2bo28b4ob2o23b3obo6b4o2bo19bo3bo21b6o3b2o39b4o6bo11b2o31bobo
    37b2o24b2obo4b5o8b2o74bo27b5o3bo4b3o4b2o68bobo25b2obo3b2o2b2o5bo3b3o
    154b2o4bo15bo$19bo7b5o71b2o24b2o176b3o108bo58bo96bo3bo46b3o68bo3bo6bo
    11b2o24bo2bo32b2o24bo15bo6b2o13bo2bo21bo2bo5b3o42b4o3bo4b3o4b2o32bo9b
    2o55b2obo11b2o98b2o12bo11b2o70bo19bo6bo2b5o8b3o5bo122b2o36b3obo6b4o2bo
    $18bobo4b2o5b2o274b2o165bo2bo97b2o118b3o47b2o70bob3o4b3ob2o12bobo23bob
    ob4o2b2o36bo7bo9bo3bobo32bo2bo7b3o20bobo28b2obo4b5o8b2o71b2o23b5o3b3o
    3b2o5b5o91bo2bo13bobo7bo3bo62b3o28b3o26b2o37b2o2bo8bo2bo$20bo4bo7bo
    407b2o29b2obo2bo94bo2bo46bo71b4o118bo3bo5b5o39bobob3o3b3o35bo5bo2bo2b
    2ob3o3bo9bo24b2o2bo8b2ob2o16b2o2b2o25bo5b3o4bo5b2o3bo33bo36b2o24b7o2b
    5o7bobo32bo35bo24b2o3b2o3b4o4bo5b2o3bo63b3o50b2o7bo26b2o8bo3b2o4b3ob3o
    $17bo2bo3bo7b2o406bo25b2o2bob3o2bo95bobo48bo70bo50bo72b2o7b3o41b3o3b2o
    b2o36bo7b3o5bo6b2o4bo3bo22b4o10bob3o14b3o2b2o26bo9bobo7bo3bo31bobo29b
    2obo34b3o12bo33b2o30bo3b2o30b2o6b5o8b2o65bo23b2o15bo9b3o5bobo5bo21bo6b
    3o5bo6b2o$17b3o3bo6b2o71b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    127bob2o22bo3bo2bo2bo145b3o119b2ob2o67bo2bo59b3o17b4o26bo3b2o4b3ob3o7b
    o23b2o7bob2obobo15b2o30b8o8b3o5bo30bo2b2o28b5o27b7o2b5o7bobo30bo2bo28b
    3ob2o35bobo11b2o45b2o21bo23b2o14bobo8bo14bobo20bo4bo2bo2b2ob3o3bo$28bo
    74b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24bo132bo22bo2bo150b2o193bobo
    61bo17b6o25b2o2bo8bo2bo2bo4bo23b2o8bobo20b4o31bo2b2o2b2o5bo3b3o30b2o9b
    obobobo13bo6b2o24bob3o3b3o3b2o5b5o28b2o12bo17b2obo3b3o23bo4b2o6b5o8b2o
    40bo4bo18b3o38bobo8b2obobo5bo3bobo20bo6bo9bo3bobo$8b2o13bo4bo387bo22bo
    4bo175bo2bo123bobo90b2o10b2o44b4ob2o23b3obo6b4o2bo3b5o22bo2bo7bo3bob2o
    16b2o26b3o5bo2bo4b3o4bobo6b3o23bo8b2o3b4o12bo6b2o23b2o12bo11b2o6bo20bo
    bo7bo3b2o23bo26b2ob2o3b4o4bo5b2o3bo16b4o25bo17b3o6bo32bo17b2obo4bo25b
    4o3bo4b3o4b2o$8b2o14bob2o387bobo21b2ob2o301bo3bo90b2o10b2o48b2o24bo15b
    o31bobo12b3o18bo35bob2obo3bo2bo2b2o5b5o22bo3bo7b6o12bo2bo3b2o24b3o3b5o
    3bo4b3o4b2o3bo3bo18bobo6b2o4b2o23b3o22b3o12bobo7bo3bo14bo3bo19bo5bo25b
    obo49b2ob2o27bo7bo11b2o$107bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo
    25bo21bo2bo22bo182b2o119bo2b2o189bob3o33bo13b2o61b2o5b2o3bo3b3ob2o30bo
    2bo18b2o2b2o26b3o3bo3bo9bo3bobo9bo17bo7b2obo28bo24bo4bo2b5o8b3o5bo18bo
    20b6o25b2o3bo19b3o25b3o28b6o3b2o5b5o$106bobo23bobo23bobo23bobo23bobo
    23bobo23bobo23bobo23bobo23bobo23bobo23bobo21b2o204bo2bo120b3o189bo3bo
    43bo2bo30b6o26b4o10b2o5b2o20b2o3bo5b7o17b3o35bo2bo2b2ob3o3bo7bo4bo17bo
    b2o5b4o20bo2bob2o26bo3b2obo3b2o2b2o5bo3b3o14bo2bo56bobo17b2ob5o21b3o
    28bo4b5o7bobo$105bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2b
    o22bo2bo22bo2bo22bo2bo22bo2bo227b3o122bo192b2o18b2o22b3o2b3o27bo5bo23b
    ob2o8b6o28b2ob2o8bo5bo15b3o37b3o5bo6b2o5b5o27b5o19bobob2o26bo9bo2bo4b
    3o4bobo75bobo17b2obobob2o21bo33bo12bo$106b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o543bo2bo19b2o23b2o2b2o34bo23bo10bo4bo31b
    o11b5o58bo3b2o4b3ob3o27bo2bo7b3o18b4o39bob2obo3bo2bo2b2o76bo20b2obo3bo
    50bo4b5o7bobo$618b2o24b2o24b2o24b2o24b2o213bobo49b2o28bo4bo37b3o42bo4b
    2o31b2o25b2o2bo8bo2bo24b2o4bo7b2obo66b2o5b2o3bo68b2o25b2o3bob2o49b6o3b
    2o5b5o$416b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o18b2o24b2o24b2o24b2o
    24b2o264b3o30b2o37bo3bo15b2o24bo34b4ob2o23b3obo6b4o2bo26b4o8b2o34b6o
    26b4o10b2o14b2o51bob2o21bo2bo5bo50bo7bo11b2o$2o6bo3bo403b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o388b3o69b3o17b2o25b3o31b6o24bo15bo11b2o15bo
    11bo33bo5bo23bob2o8b6o13b4o30b3o9bo8bob2o3bo16b3ob2ob2o54b4o3bo4b3o4b
    2o$2o5b3obo2bo973b3o68b4o48bo30b4o36bob3o12b2o24b2ob2o38bo23bo10bo4bo
    13bo4bo25bo3b3o8b3o8b2o3bobo15bo4bo53bo6bo9bo3bobo$7bobobo977bo69bo51b
    o69bo3bo39b2ob2o32bo4bo37b3o14bo3b2o24bobo12b2obo7b2o5b2o15bob3o54bo4b
    o2bo2b2ob3o3bo$13bo7bobo967bo119bo71b2o41b2ob2o33b2o37bo3bo14bo4bo23bo
    8b3o3bobo2bo2b2o2bo23b2o38b5o14bo6b3o5bo6b2o$13b2ob2obob3o4b2o956b2o3b
    o188bo2bo42b3obo72b3o19b2o24bo3bo10bo2bo4bo3b2o22b2o37bo4bo23bo3b2o4b
    3ob3o$7bo3bobo3b2o2bo6b2o71b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o129b2o119bobo70bobo42bo2bo73b4o45bo
    4bo10bobo5bo3bob2o63bo23b2o2bo8bo2bo$11bobo87b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o133bo115b2obo
    114bo3bo73bo19bo29bo3b4o9b2o5bo2bob2o58bo3bo23b3obo6b4o2bo$24b2o70b2o
    888bo2bo116bo2bo114bo4bo91bobo32bo20b2o64bo25bo15bo$23b4o8b3o56b2o2bo
    888b3o116b2o115bo2bo2bo91bobo31bo124bob3o$23bo2b2o5b7o54b2ob2o6b2o24b
    2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b
    2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b
    2o24b2o24b2o24b2o24b2o144bo114bo97b2o57bo97bo3bo$24b3obo3b9o53b2ob2o6b
    2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b
    2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b
    2o24b2o24b2o24b2o24b2o24b2o144b2o113b2obobo152bo98b2o$24bob2o3b3o7bo
    54bo1010bo2bo116b2o149bo99bo2bo$31bo6b3o80b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o22b3o115b3o61b2o53b2o24b2o2bo7bo95bobo$38b2o70b2o
    9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b
    2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o
    13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b
    2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o
    9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o9b2o13b2o8bo15b
    2o24b2o24b2o24b2o21b2o62b2o6b2o47b3o21b2o5b4o$36bo73b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o22b3o68bobo44bo
    2b2o28bo$35bo1190b3o69bo21bo22bo2bobo$34bo1192bo91bobo25bo$97b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24b2o24b2o23b2o25bo2bo20bo3bo$50bo45bo2bo22bo2bo22bo2bo22bo2bo22bo2bo
    22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo
    22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo
    22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo
    22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo
    22bo2bo20bob2obo24b2o23bo$49bobo45b2o24b2o24b2o24b2o24b2o24b2o24b2o24b
    2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b
    2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b
    2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o21b4o2b2o$48b2ob2o
    1238b2obob2o$48b2ob2o1239b2o2b5o$51b3o1241b2o2b2o$47bo3b3o1239bobo$46b
    o4b3o1240bo$36b2o7bo5b2o$36b2o12b3o$50b2o$49b2o3$50bo$49b3o49bo$48bo3b
    o49b2o$47b2o19b3o30b2o$48b2o$67bo$66b2o4b2o$67bo5bo9b2o21bo25bo25bo25b
    o25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo
    25bo25bo25bo25bo25bo31b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24bo$67b2o
    8bo5bobo19bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo
    23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bo
    bo23bobo23bobo23bobo23bobo30b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o23bo
    bo$70b3o4b2o4bo2bo18bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bo
    bo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo
    23bobo23bobo23bobo23bobo23bobo23bobo26bo213bo$72bo11bo2bo18bo25bo25bo
    25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo
    25bo25bo25bo25bo25bo25bo26b2o$72b2o10bobo695b2o2bo22b2o182b2o$73bo2bo
    36b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o24b2o
    24bo25bo25bo252b4o22bo2bo181bo2bo$42bo6b2o22b2obo35bo2bo22bo2bo22bo2bo
    22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo
    22bo2bo22bobo23bobo23bobo27b2o131b3o88b4o22bobo181bo5bo$41bobo6bo23bo
    38bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bobo23bo
    bo23bobo23bobo22bo2bo22bo2bo22bo2bo22b2o227b2o2bo21bo183bob2o2bo$40bo
    3bo3bo65bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo25bo24b2o24b
    2o24b2o22bo3bobo29b2o24b2o24b2o24b2o24bo92bobo204bo4bo74bobo$41bobo5b
    4o26bo198bo275bo4bo29b2o24b2o24b2o24b2o24bo84b3o4bo3bo43b3o159bo2bo74b
    o2bo$42bo7bo27b2o197bobo274bo4bo130bo2bo85b3o3bo2bo43bo3bo115bo42bobo
    78b2o$47bo3bo2bo3bo19b2o196b2o186bo90bo2bo130bo90bobo3bobo21bo21bo4bo
    114b4o118bo3bo$46bobo8bobo216b2o2bo181bo3bo89bo132b4o88bo5bo20bo3bo18b
    o5bo115b3o79b4o36bob3o$46b2o7b3obo33b3o181bobob2o184bo5b2o213b2obobo
    115bo2bob2o15bo3bo117bo3bo9b2o24b2o39b6o24bo15bo$52bo2b2obo36bo181bo4b
    o179bo4bo3bo4bo17bo69b2o122b3o86b2o32bo2bo16bo3bo9b2o108b3o9b2o12b3o9b
    2o39b4ob2o23b3obo6b4o2bo$54b2o35bob2o182bo4bo180b5o9bo14bo3bo66b2obo
    79bo41b3o2b2o79b3ob2o32bobo9b2o17b2obo16b2o77bo10bo4bo22b2o32b3o20b2o
    25b2o2bo8bo2bo$88b2o30b2o24b2o24b2o24b2o24b2o24b2o24b4o191bo5bo19bo67b
    3o78b4o39b2o2b2o72bobo4b5o33b2o12bo5b3o7bo3bo14b2obo77bob2o8b6o21bo2bo
    34bo45bo3b2o4b3ob3o$89bobo27bo2bo22bo2bo22bo2bo22bo2bo22bo2bo22bo2bo
    22b3obo23b2o167b6o14bo4bo26bo40b2o80b3o40b2obo73bo2bo4b3o34b2o9bobo15b
    o3b2o14b2o55b2o25b4o10b2o21b2o37bo41b3o5bo6b2o$90bo29b2o24b2o24b2o24b
    2o24b2o24b2o24b2o2bo21bo2bo25bo129b2o30b5o26b4o35b3o81bo3bo38bo4bo74b
    2o39b2o9b2obo2bo11b2obobo15b3o51b3ob2o26b2o5b2o3bo6b2o14b2o30bo5b2o39b
    o2bo2b2ob3o3bo$277b3obo20bobo21b2o3b2o127bo64b3o35b2o84b3o43bo72bo3bo
    38bo2b4o2b2ob2obo2bo9bob2obo70b5o21bob2obo3bo2bo2b2o5b3ob2o19bobo23b2o
    b5o37bo3bo9bo3bobo$104b3o172b3o21bo22b2o3b3o128b2obo39b6o14bo3bo16b2o
    37b3o19b6o23bo10bo4bo116bob3o37bo2b4o2b2o3b2o2bo10bo24bo7b3o40b3o17bo
    3bo2bo4b3o4bobo5b5o20bo2bo24bo41b6o3bo4b3o4b2o$104bobo173bo49b3obo21bo
    103bob4o25bo12bo5bo16b3o16b2o37bo2bo17bo5bo23bob2o8b6o10b2o24b2o40b2o
    24bo15bo38b2ob2o4b3o3bo12bo5b2o16b2o2bo66b2o3b2o2b2o5bo3b3o5b3o17bo3b
    2ob2o4bo17bo38b2o2bo7bo11b2o$104bob2o164b2o55b2o24b2o103bobobo26bo18bo
    3bo10bo4bo53bo3bo23bo26b4o10b2o9b2o14b2o9bo36b4ob2o23b3obo6b4o2bo39b3o
    5b2obo14b3o2b3o15bo2b2o68b5o8b3o5bo24bo7b2o4bo15b2ob4o34b2o2bob4o3b2o
    5b5o$104b3o165b2o57bo2b2o18bo99bobo5b2o24bo2bo12bo4bo4bob2o8b6o53b2o2b
    2o15bo4bo29b2o5b2o3bo25b5o44b6o25b2o2bo8bo2bo39b3o7bo15b2o3b3o16bob2o
    3bo58b2o4bo6bobo7bo3bo32bo21b2ob2o3bo36b2o3b5o7bobo$108b3o218b3o3bo17b
    2obo97bo2bo32bo15b2o9b4o10b2o3b3o43bo3b3o2bo16b2o25bob2obo3bo2bo2b2o
    27bo4bo6bo22b2o13b4o26bo3b2o4b3ob3o67bobob2o16bo8bo19bo36b3o4b4o4bo5b
    2o3bo27b2o26bo7bo38bobo12bo$104bo229b2o16b2o3bo2b2o95b2o27bo4bo27b2o5b
    2o3bo3b5o36b2o7b3o3bo34bo7bo2bo4b3o4bobo6b3o29bo22bob3o39b3o5bo6b2o71b
    o2bo17b2obo23bo2bo38b4o3b5o8b2o29bo29b3o39b2o3b5o7bobo$51b2o24b2o24bob
    o231b2o12bo8bobo92bo3bo29b2o22bob2obo3bo2bo2b2o5b3ob2o9b2o23b7o3b2o4bo
    33bobo3bo3b2o2b2o5bo3b3o4b5o18b3o5bo5bo17b2o4bo36bo2bo2b2ob3o3bo71bo2b
    o2bo16bo3bo22bobo42bo2bo11b2o31b3o26b3ob3o33b2o2bob4o3b2o5b5o$50bo2bo
    22bo2bo22bo3b2o22b2o25bobo177bobo16bo5bo93bob3o24b2o5bo19bo2bo4b3o4bob
    o8b2o10b2o25bob3o3b2o40bo3b5o8b3o5bo4b3ob2o17bo6bo26bo2bobo24b2o3b4o4b
    o9bo3bobo48b4o16b3o20bo3b3o20b2o41b4o3b5o8b2o97b2o2bo7bo11b2o$51b2o24b
    2o24bo25bo2bo204bo2bo9bo3b2o4bobo82bo15bo11b5o27bobobo3b2o2b2o5bo3b3o
    21bo21b2obo7bo26bo11bo13bobo7bo3bo7b2o16b2ob2o4bo3bo27bo24bobo2b9o3bo
    4b3o4b2o24b2o20b6o13bo5b2o16bo3bo2b2o58b3o4b4o4bo5b2o3bo67bo21b2o9b6o
    3bo4b3o4b2o$104b3o2bo19bobo21b2o2bo144b2o27bo8bo10bob2o6bo83b3obo6b4o
    2bo9bo4bo11bo14b2o4b4o8b3o5bo19bo23b2ob3o3b3o25b3o10b2o5b5o4bo5b2o3bo
    26b2o7bo2bo2b3o22b3o23bob4o2bo7bo11b2o23b2ob2o19b4ob2o12b2o29b2o51bo6b
    2o4bo6bobo7bo3bo65bobo18bobo11bo3bo9bo3bobo$106b3o21bo22b2o3b3o140bo2b
    o3bo20b2o6b2o2bo10bo5b2o58b5o23b2o2bo8bo2bo14bo10bobo13bo11bobo7bo3bo
    19bo3bo21b2o2bo4bo24b2obo12bo3b2o4b5o8b2o27b2obo6b2o3bobo22bo2bo24b5o
    3b4o3b2o5b5o24b4o24b2o40b2ob2ob3o26bo20b3o11b5o8b3o5bo49b2o14bobo17bo
    16bo2bo2b2ob3o3bo$161bo21b2o117bobo2bob2o19b2o4bobo2bo10b3o4bo57bo4bo
    23bo3b2o4b3ob3o9bo3bo27bo7b2o4bo5b2o3bo12b4o6bobo26b2o3bo23bo3bo19bo
    11b2o31bobo11b2o16b2ob2o2b2o25bo2b3o2bo3b5o7bobo26b2o40b2ob2o23bobo30b
    obo21b2o9b2o3b2o2b2o5bo3b3o49b2o11bo3bo18b2ob2o14b3o5bo6b2o$99b2o55b2o
    3bo20bo120bo2b2ob3o20b2obo4b2o11b4o2b4o5bo53bo21b3o5bo6b2o13bo14b2ob2o
    11b5obo2b5o8b2o12b6o36b3o23bo3bo12bo3b2o4b5o8b2o28b2obo28bo2b3o39bo12b
    o89b2o24b2o14bobo17bo4b2o8bo3bo2bo4b3o4bobo63bo22b2ob2o16bo3b2o4b3ob3o
    $99b2o55b2o23bo99bo25bob3o21b3o18b4o2bob2o4bo48bo3bo20bo2bo2b2ob3o3bo
    31bo2b2o15bo2bo11b2o15b4ob2o62bo13b2o5b5o4bo5b2o3bo29b3o28b3obobo29b3o
    2bo3b5o7bobo87b2o24b2o15bo17b2o4b2o13bob2obo3bo2bo2b2o33bo29bo22bo2b2o
    16b2o2bo8bo2bo$157bo3b2o18bobo97b4o71b2ob2o4bo2bo16b4o42b2o3b4o4bo9bo
    3bobo29b3o12b5obo2b5o8b2o16b2o31b3o30bo12bo13bobo7bo3bo28b2o34b2o24b2o
    3b3o3b4o3b2o5b5o93bo25bo33bo20b2o5b2o3bo31bo53b2o8b4o5b3obo6b4o2bo$
    158bo4bo16bob2o3b2o93b3o70b3ob2obo3bo18bobob2o25b2o13bobo2b9o3bo4b3o4b
    2o29bo12bo7b2o4bo5b2o3bo48b2ob3o6bo36bo3b5o8b3o5bo89bobo3b2o2bo7bo11b
    2o92bo25bo27bo24b4o10b2o93b6o4bo15bo$160bo18b2ob2o3b2o93bo3bo68b2o5bo
    3bo17bo2bob2o24b2obo12bob4o2bo7bo11b2o43bo11bobo7bo3bo48b2o8bobo21b2o
    10bobo3bo3b2o2b2o5bo3b3o69bo26b9o3bo4b3o4b2o91bo25bo28bo3bo16bob2o8b6o
    94b4ob2o14bob3o$164b3o11b2ob2o6bo94b3o79bo24bo24bobo14b5o3b4o3b2o5b5o
    44b2o4b4o8b3o5bo42b2o4b2ob2o5bobo15b2o6bo10bo7bo2bo4b3o4bobo69bobo19bo
    5b4o4bo9bo3bobo148b3o8b6o3bo10bo4bo51b2o46b2o14bo3bo$160bo3b3o11b2obo
    5b2o82bo10bo4bo23bo44b2o6b2o25b3o22bo15bo2b3o2bo3b5o7bobo46bobobo3b2o
    2b2o5bo3b3o42b2o6bo8bo15b2o4bob2o19bob2obo3bo2bo2b2o53b2o14bobo19b3o9b
    o2bo2b2ob3o3bo161bo5bo16b3o48b4ob2o63b2o$129b2o26bobo7bo10bo8b2o82bob
    2o8b6o22bo13b2o40b2o23b2o22bo26bo12bo55bo2bo4b3o4bobo55b3o19bo4b3o26b
    2o5b2o3bo51b2o11bo3bo34b3o5bo6b2o164bo14bo3bo48b6o61bo2bo$128bo2bo3bo
    21bo6b2o2bo11bobo2b2o60b2o25b4o10b2o33bo4bo37b2o15b2ob3o43bo2b3o2bo3b
    5o7bobo54bob2obo3bo2bo2b2o82b2o25b4o10b2o63bo40bo3b2o4b3ob3o116bo39bo
    4bo15b3o51b4o62bobo$129bobo2bobo7bo12b2o6b4o10bo4bobo57b3ob2o26b2o5b2o
    3bo11b4o25bo33bo4bo15b5o28b3o13b5o3b4o3b2o5b5o59b2o5b2o3bo80bo23bob2o
    8b6o34bo29bo23bobo14b2o2bo8bo2bo78b2o36bo41b2o16b4o$130bo3bob2o6bo15bo
    b2o3bo12bo6b2o55b5o21bob2obo3bo2bo2b2o12bo3bo19bo5bo32bobo20bo45bob4o
    2bo7bo11b2o56b4o10b2o47b2o31bo13b6o3bo10bo4bo35bo53b2o14b3obo6b4o2bo
    74b4ob2o95bo$134bo3b2o20b2o19b3o3bob2o3b3o48b3o11bo9bo2bo4b3o4bobo16bo
    20b6o32bobo31bo34bobo2b9o3bo4b3o4b2o52bob2o8b6o46bo4bo25b4o13bo5bo16b
    3o36bo63b2o4bo15bo75b6o$135bo47bobobo3bo21b2o44bo3b2obo3b2o2b2o5bo3b3o
    11bo2bo60bo31bobo15bo17b2o3b4o4bo9bo3bobo53bo10bo4bo53bo24bo22bo14bo3b
    o32bo2bo13b4o43b4ob2o14bob3o77b4o$188b5o18b2obob2o25b3o12bo4bo2b5o8b3o
    5bo65b2o3b3o18b2o14bobo13b2ob2o6bo19bo2bo2b2ob3o3bo69b3o48bo5bo25b3o
    13bo4bo15b3o33bo2bo13b6o42b6o14bo3bo$136bo3bo41b2o3bobob3o20bo2bo25bo
    14b3o12bobo7bo3bo65b2o3bobo18b2o15bo14bo2bo3bobobo21b3o5bo6b2o64bo3bo
    49b6o25b2o16b2o16b4o34b2o14b4ob2o42b4o17b2o$183bo7b2o17bo3bo28bobo13b
    2ob2o3b4o4bo5b2o3bo71b3o51b2o3bobob2o23bo3b2o4b3ob3o62b3o118bo57b2o61b
    o2bo$137bobo43b2o6bo25bob2o23b2o12bo4b2o6b5o8b2o99b3o29bo3bo24b2o2bo8b
    o2bo61b4o239bobo$138bo55b2o15bo7bo24b3o20bobo11b2o153b4o5b3obo6b4o2bo
    61bo$151b4o39bobo14bo2bo3bo25b3o11bo4b2o6b5o8b2o149b6o4bo15bo$128b2o
    20b6o34bo3bo16b3ob2o28bo13b2ob2o3b4o4bo5b2o3bo128b2ob3o14b4ob2o14bob3o
    $126b2ob2o19b4ob2o32bobo66b3o12bobo7bo3bo126bo24b2o14bo3bo$126b4o24b2o
    33bobo31bo34bo4bo2b5o8b3o5bo126bo3bo38b2o$127b2o61bo31bobo14bobo17bo3b
    2obo3b2o2b2o5bo3b3o65b6o59bo35bo2bo$180b2o4bo19b2o14bobo13bo2bo6bo10bo
    9bo2bo4b3o4bobo65bo5bo58bo36bobo$180b2o2b2ob2o17b2o15bo14bo2bo4bo2b2o
    19bob2obo3bo2bo2b2o71bo$186bo26bo25b2o3bobo29b2o5b2o3bo63bo4bo$213bo
    30b2ob2o25b4o10b2o64b2o$213bo32b2o23bob2o8b6o$246b2o14b6o3bo10bo4bo$
    244bobo14bo5bo16b3o$241b3o23bo14bo3bo$241b5o15bo4bo15b3o$183b2o58b3o
    17b2o16b4o$179b4ob2o95bo$179b6o$180b4o!
    """)!);
        
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




