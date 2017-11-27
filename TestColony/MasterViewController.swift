//
//  MasterViewController.swift
//  TestColony
//
//  Created by Ethan on 11/18/17.
//  Copyright © 2017 TheSucc. All rights reserved.
//

import Foundation
import UIKit

protocol ItemSelectionDelegate{
    func itemSelected(newItem: Item)
}

class MasterViewController: UITableViewController{
    var items = ItemStore()
    var delegate: ItemSelectionDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int{
        return(items.allItems.count)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return(1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell{
            // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        let item = items.allItems[indexPath.row]
        
        cell.nameL.text = item.name
        cell.serialL.text = item.serialNumber
        cell.valueL.text = "$\(item.valueInDollars)"
        
        return(cell)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = self.items.allItems[indexPath.row]
        self.delegate?.itemSelected(newItem: selectedItem)
        if let detailViewController = self.delegate as? DetailViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
    }
    
    @IBAction func addNewItem(_ sender: UIButton){
        let newItem = items.createItem()
        
        if let index = items.allItems.index(of: newItem){
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
            let item = items.allItems[indexPath.row]
            
            let title = "Delete \(item.name)?"
            let message = "Are you sure you want to delete this item?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                self.items.removeItem(item)
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic)})
            
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }

}
