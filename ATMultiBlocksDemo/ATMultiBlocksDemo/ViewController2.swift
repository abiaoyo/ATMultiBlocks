//
//  ViewController2.swift
//  ATMultiBlocksDemo
//
//  Created by abiaoyo on 2022/11/9.
//

import UIKit

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        StateCenter.shared.addStateBlock(for: self) { state in
            print("ViewController2: \(state)")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
