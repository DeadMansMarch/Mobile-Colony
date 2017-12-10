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
    
    @IBOutlet var visibility: UISwitch!
    @IBOutlet var prettywrap: UISwitch!
    
    var settings = [
        "visibility":false,
        "prettywrap":true
    ]
    
    var links:[String:UISwitch]!;
    
    func updateBySetting(_ key:String){
        links[key]!.isOn = settings[key]!
    }
    
    func changeSetting(_ key:String, to: Bool){
        settings[key] = to;
        linkedDrawController!.redraw();
    }
    
    @IBAction func toggleVisibility(_ sender: UISwitch){
        changeSetting("visibility",to:sender.isOn)
    }
    
    @IBAction func togglePrettyWrap(_ sender: UISwitch){
        changeSetting("prettywrap",to:sender.isOn);
    }
    
    @IBAction func resetColony(_ sender: Any) {
        linkedDrawController?.currentColony!.colony.resetColony()
    }
    
    override func viewDidLoad() {
        links = [
            "visibility":visibility,
            "prettywrap":prettywrap
        ]
        links.forEach{ self.updateBySetting( $0.key )}
    }
}
