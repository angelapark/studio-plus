//
//  ViewController.swift
//  studio-plus
//
//  Created by Lindsay Pond on 3/25/17.
//  Copyright © 2017 Lindsay Angela Ena. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    static let hogsmeadeBrandAssets = CameraBrandAssets(hintImageDefaultName: "hp-camera-hint-default", hintImageActivatedName: "hp-camera-hint-activated")
    
    static let springfieldBrandAssets = CameraBrandAssets(hintImageDefaultName: "simpsons-camera-hint-default", hintImageActivatedName: "simpsons-camera-hint-activated")

        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func enterHogsmeade(_ sender: Any) {
        
        if let cameraViewController = WandViewController.viewController(subClass: .wandViewController) {
            cameraViewController.brandAssets = ViewController.hogsmeadeBrandAssets
            present(cameraViewController, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

    @IBAction func SegueToSpringfield(_ sender: Any) {
        let springfieldVC = SpringfieldViewController()
        springfieldVC.brandAssets = ViewController.springfieldBrandAssets
        present(SpringfieldViewController(), animated: true, completion: nil)
    }
    

}
