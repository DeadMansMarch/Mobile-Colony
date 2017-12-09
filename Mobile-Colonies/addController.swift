//
//  addController.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 12/5/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit

class AddController: UIViewController{
    @IBOutlet var sizeText:UILabel!;
    @IBOutlet var textInput:UITextField!;
    
    var fedCallback:((ColonyData)->())?;
    
    var colonySize = 100;
    @IBAction func changeSize(_ sender: UISlider){
        colonySize = Int(floor(sender.value));
        if colonySize == 1001{
            sizeText.text = "InfxInf"
        }else{
            sizeText.text = "\(colonySize)x\(colonySize)"
        }
    }
    
    @IBAction func create(){
        if (textInput.text != nil && textInput.text! != ""){
            let ColonyDat = ColonyData(name:textInput.text!,size:colonySize,colony:Colony(size: colonySize));
            if fedCallback != nil{
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                fedCallback!(ColonyDat);
                fedCallback = nil;
            }
        }
    }
}
