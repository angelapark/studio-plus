//
//  CameraViewController.swift
//  studio-plus
//
//  Created by Angela Park on 3/16/17.
//  Copyright © 2017 Lindsay Angela Ena. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

struct CameraBrandAssets {
    let hintImageDefaultName: String
    let hintImageActivatedName: String
    
    init(hintImageDefaultName: String, hintImageActivatedName: String) {
        self.hintImageDefaultName = hintImageDefaultName
        self.hintImageActivatedName = hintImageActivatedName
    }
}

class CameraViewController: UIViewController {
    var cameraView: CameraView? {
        didSet {
            if let brandAssets = brandAssets, let cameraView = cameraView {
                cameraView.configure(brandAssets: brandAssets)
            }
        }
    }

    var brandAssets: CameraBrandAssets? {
        didSet {
            if let brandAssets = brandAssets {
                cameraView?.configure(brandAssets: brandAssets)
            }
        }
    }
    static func viewController() -> CameraViewController? {
        return UIStoryboard(name: "Camera", bundle: Bundle.main).instantiateInitialViewController() as? CameraViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cameraView = CameraView.instanceFromNib() as? CameraView {
  
                            self.cameraView = cameraView
            view.addSubview(cameraView)
        }
        cameraView?.setupSession()
        cameraView?.setupPreview()
        cameraView?.startSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Setup session and preview
   

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QuickLookSegue" {
            let quickLook = segue.destination as! QuickLookViewController
            
            if let image = cameraView?.thumbnail.backgroundImage(for: UIControlState()) {
                quickLook.photoImage = image
            } else {
                quickLook.photoImage = UIImage(named: "Penguin")
            }
        }
    }
}

extension CameraViewController: QuickViewDelegate {
    func showPhoto(image: UIImage) {
        if let quickViewController = QuickLookViewController.viewController() {
            quickViewController
        }
    }
}
