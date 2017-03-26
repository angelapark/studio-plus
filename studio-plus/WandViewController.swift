//
//  WandViewController.swift
//  studio-plus
//
//  Created by Lindsay Pond on 3/25/17.
//  Copyright © 2017 Lindsay Angela Ena. All rights reserved.
//

import UIKit

class WandViewController: CameraViewController {
    @IBOutlet weak var wandImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var wandGuide: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubview(toFront: wandGuide)
        view.bringSubview(toFront: wandImage)
        wandGuide.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cameraView?.toggleHint(toSelected: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.wandGuide.alpha = 0.5
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 3.0, options: [], animations: {
                self.wandGuide.alpha = 0
            }, completion: { _ in
                self.wandGuide.isHidden = true
                self.cameraView?.toggleHint(toSelected: false)
            })
        })
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        if recognizer.state.rawValue == 3 {
            //apply filter
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func toggleHint() {
        wandGuide.alpha = 0.5
        wandGuide.isHidden = !wandGuide.isHidden
    }
}
