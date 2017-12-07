//
//  MasterViewController.swift
//  Mobile-Colonies
//
//  Created by Ethan on 12/2/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit

protocol GridSelectionDelegate{
    func gridSelected(newGrid: Grid)
}

class MasterViewController: UITableViewController{
    var grids = GridStore()
    var delegate: GridSelectionDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int{
        return(grids.allGrids.count)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return(1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell{
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "GridCell", for: indexPath) as! GridCell
        
        let grid = grids.allGrids[indexPath.row]
        
        cell.nameL.text = grid.name
        cell.sizeL.text = "\(grid.size)x\(grid.size)"
        
        return(cell)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGrid = self.grids.allGrids[indexPath.row]
        self.delegate?.gridSelected(newGrid: selectedGrid)
        if let detailViewController = self.delegate as? DetailViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
    }
    
    @IBAction func addNewGrid(_ sender: UIButton){
        let newGrid = grids.createGrid()
        
        if let index = grids.allGrids.index(of: newGrid){
            let indexPath = IndexPath(row: index, section: 0)
            
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    @IBAction func toggleEditingMode(_ sender: UIButton){
        if isEditing{
            sender.setTitle("Edit", for: .normal)
            
            setEditing(false, animated: false)
        } else {
            sender.setTitle("Done", for: .normal)
            
            setEditing(true, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let grid = grids.allGrids[indexPath.row]
            
            let title = "Delete \(grid.name)?"
            let message = "Are you sure you want to delete this item?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                self.grids.removeGrid(grid)
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic)})
            
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
    
}

