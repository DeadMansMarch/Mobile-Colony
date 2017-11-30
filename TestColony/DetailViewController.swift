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
    @IBOutlet var gridName: UILabel!
    @IBOutlet var gridSize: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var sizeField: UITextField!
    
    @IBAction func backgroundTap(_ sender: UITapGestureRecognizer) {
        refreshLabel()
        view.endEditing(true)
    }
    

    var grid: Grid? {
        didSet (newGrid) {
            self.refreshUI()
        }
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
        }
    }
    
    func refreshLabel(){
        if (grid != nil){
            gridName?.text = nameField.text!
            gridSize?.text = sizeField.text!
        }
        print("I did a do")
    }
    
    override func viewDidLoad() {
        refreshUI()
    }
}

extension DetailViewController: GridSelectionDelegate{
    func gridSelected(newGrid: Grid) {
        grid = newGrid
    }
}
