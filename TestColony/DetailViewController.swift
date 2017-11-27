//
//  DetailViewController.swift
//  TestColony
//
//  Created by Ethan on 11/18/17.
//  Copyright © 2017 TheSucc. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController{
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemValue: UILabel!
    @IBOutlet var itemSerial: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var serialNumberField: UITextField!
    @IBOutlet var valueField: UITextField!
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer){
        
    }

    var item: Item? {
        didSet (newItem) {
            self.refreshUI()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return(true)
    }
    
    func refreshUI() {
        if (item != nil){
            itemName?.text = item!.name
            itemValue?.text = String(item!.valueInDollars)
            itemSerial?.text = item!.serialNumber
            nameField?.text = item!.name
            valueField?.text = String(item!.valueInDollars)
            serialNumberField?.text = item!.serialNumber
        }
    }
    
    override func viewDidLoad() {
        refreshUI()
    }
}

extension DetailViewController: ItemSelectionDelegate{
    func itemSelected(newItem: Item) {
        item = newItem
    }
}
