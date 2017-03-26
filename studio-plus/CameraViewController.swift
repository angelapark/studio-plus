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
    static func viewController(subClass: CameraViewController.Subclass = .cameraViewController) -> CameraViewController? {
        
        switch subClass {
        case .cameraViewController:
            return UIStoryboard(name: subClass.rawValue, bundle: Bundle.main).instantiateInitialViewController() as? CameraViewController
        case .wandViewController:
            return UIStoryboard(name: subClass.rawValue, bundle: Bundle.main).instantiateInitialViewController() as? WandViewController
        }
    }
    
    enum Subclass: String {
        case wandViewController = "Hogsmeade"
        case cameraViewController = "Camera"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cameraView = CameraView.instanceFromNib() as? CameraView {
            self.cameraView = cameraView
            cameraView.delegate = self
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
}

extension CameraViewController: CameraViewDelegate {
    func showPhoto(image: UIImage) {
       if let quickViewController = QuickLookViewController.viewController() {
            quickViewController.photoImage = image
            present(quickViewController, animated: true)
        }
    }
    
    func toggleHint() {
        
    }
    
    func backToMap() {
        if ((self.presentingViewController) != nil){
            self.dismiss(animated: false, completion: nil)
        }
    }
}
