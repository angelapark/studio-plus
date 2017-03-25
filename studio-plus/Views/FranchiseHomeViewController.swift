//
//  FranchiseHomeViewController.swift
//  studio-plus
//
//  Created by Lindsay Pond on 3/24/17.
//  Copyright © 2017 Lindsay Angela Ena. All rights reserved.
//

import UIKit

class FranchiseHomeViewController: UIViewController {
    
    var franchiseDestination: UIViewController?
    @IBOutlet weak var backgroundView: UIImageView!

    @IBAction func navigateBack(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func navigateTo(_ sender: Any) {
        if let franchiseDestination = franchiseDestination {
            present(franchiseDestination, animated: true, completion: nil)
        }
    }
    
    func configure(destination: UIViewController?, backgroundImage: UIImage) {
        franchiseDestination = destination
        backgroundView.image = backgroundImage
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

}
