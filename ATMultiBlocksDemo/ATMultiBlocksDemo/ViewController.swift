//
//  ViewController.swift
//  ATMultiBlocksDemo
//
//  Created by abiaoyo on 2022/11/9.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        StateCenter.shared.addStateBlock(for: self) { state in
            print("ViewController: \(state)")
        }
        
    }

    @IBAction func clickButton1(_ sender: Any) {
        StateCenter.shared.addStateBlock(for: self) { state in
            print("手动 ViewController: \(state)")
        }
    }
    
    @IBAction func clickButton2(_ sender: Any) {
        StateCenter.shared.removeStateBlock(for: self)
    }
    
    @IBAction func clickButton3(_ sender: Any) {
        StateCenter.shared.state = .suc
    }
    
}

