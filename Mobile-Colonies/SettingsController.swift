//
//  SettingsController.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 12/6/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UIViewController{
    
    var linkedDrawController:GridViewController?;
    
    var settings = [
        "visibility":false,
    ]
    
    @IBAction func toggleVisibility(_ sender: UISwitch){
        settings["visibility"] = sender.isOn;
        linkedDrawController!.redraw();
    }
}
