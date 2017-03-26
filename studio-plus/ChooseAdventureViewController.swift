//
//  ChooseAdventureViewController.swift
//  studio-plus
//
//  Created by Angela Park on 3/16/17.
//  Copyright © 2017 Lindsay Angela Ena. All rights reserved.
//

import UIKit

class ChooseAdventureViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func enterHogsmeade(_ sender: Any) {
        if let cameraViewController = WandViewController.viewController(subClass: .wandViewController) {
            cameraViewController.brandAssets = ViewController.hogsmeadeBrandAssets
            present(cameraViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func enterSpringField(_ sender: Any) {
        let springfieldVC = SpringfieldViewController()
        springfieldVC.brandAssets = ViewController.springfieldBrandAssets 
        present(SpringfieldViewController(), animated: true, completion: nil)
    }
}
