//
//  SpringfieldViewController.swift
//  studio-plus
//
//  Created by Angela Park on 3/25/17.
//  Copyright © 2017 Lindsay Angela Ena. All rights reserved.
//

import UIKit
import AVFoundation

class SpringfieldViewController: UIViewController {
    
    let vuforiaLicenseKey = "AYMrEOL/////AAAAGZAtWrwL8kBAu5nfDaUbHvZ2qfgLiVZ4KXtAd+yQU6RgaPzv2HFiI7VGxHAculE5GE3H2MbP2o4k6t8p7n6V59kQaWVyRT5sku+xuABy63ceWWFybkLf8Em1VMTUN3ADO4UQOrHBpUNEjxKWFpZNxm91dUdtkpf1mnTEU25YkD4p3+nfPRPvPuaP/fQbpOdkLBMMZqiO94a1LIl2929XB22vERJv4BNZ/bYinfHZKyHCVjd7TXN+T6cpwnz6MnD/BKlzf/rCPprGB89Nlbi7bTIM0VSFVqA9tx5eqYk0oybppyPS1wcPY3cWCjTzOQZlyZEKupCnoh2vDnZ1Kqmj1U4HGzcqZgKLhNCTOO4cAqVB"
    let vuforiaDataSetFile = "VuforiaSample.xml"
    
    var vuforiaManager: VuforiaManager? = nil
    var arImage: UIImage?
    
    let boxMaterial = SCNMaterial()
    fileprivate var lastSceneName: String? = nil
    
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepare()
        
        initializeCameraView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resume()
    }
    
    func initializeCameraView() {
        if let cameraView = CameraView.instanceFromNib() as? CameraView {
            self.cameraView = cameraView
            view.addSubview(cameraView)
            cameraView.quickViewDelegate = self
            cameraView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
}

private extension SpringfieldViewController {
    func prepare() {
        vuforiaManager = VuforiaManager(licenseKey: vuforiaLicenseKey, dataSetFile: vuforiaDataSetFile)
        if let manager = vuforiaManager {
            manager.delegate = self
            manager.eaglView.sceneSource = self
            manager.eaglView.delegate = self
            manager.eaglView.setupRenderer()
            self.view = manager.eaglView
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didRecieveWillResignActiveNotification),
                                       name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(didRecieveDidBecomeActiveNotification),
                                       name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        vuforiaManager?.prepare(with: .portrait)
    }
    
    func pause() {
        do {
            try vuforiaManager?.pause()
        }catch let error {
            print("\(error)")
        }
    }
    
    func resume() {
        do {
            try vuforiaManager?.resume()
        }catch let error {
            print("\(error)")
        }
    }
    
    func stop() {
        do {
            try vuforiaManager?.stop()
        } catch let error {
            print("\(error)")
        }
    }
    
    func start() {
        do {
            try vuforiaManager?.start()
            vuforiaManager?.setContinuousAutofocusEnabled(true)
        }catch let error {
            print("\(error)")
        }
    }
}

extension SpringfieldViewController {
    func didRecieveWillResignActiveNotification(_ notification: Notification) {
        pause()
    }
    
    func didRecieveDidBecomeActiveNotification(_ notification: Notification) {
        resume()
    }
}

extension SpringfieldViewController: VuforiaManagerDelegate {
    func vuforiaManagerDidFinishPreparing(_ manager: VuforiaManager!) {
        print("did finish preparing\n")
        
        start()
    }
    
    func vuforiaManager(_ manager: VuforiaManager!, didFailToPreparingWithError error: Error!) {
        print("did faid to preparing \(error)\n")
    }
    
    func vuforiaManager(_ manager: VuforiaManager!, didUpdateWith state: VuforiaState!) {
        for index in 0 ..< state.numberOfTrackableResults {
            let result = state.trackableResult(at: index)
            let trackerableName = result?.trackable.name
            print("\(trackerableName)")
            if trackerableName == "KwikEMart" {
                boxMaterial.diffuse.contents = UIColor.gray
                
                if lastSceneName != "KwikEMart" {
                    manager.eaglView.setNeedsChangeSceneWithUserInfo(["scene" : "KwikEMart"])
                    lastSceneName = "KwikEMart"
                }
            }
        }
    }
}

extension SpringfieldViewController: VuforiaEAGLViewSceneSource, VuforiaEAGLViewDelegate {
    
    func scene(for view: VuforiaEAGLView!, userInfo: [String : Any]?) -> SCNScene! {
        guard let userInfo = userInfo else {
            print("default scene")
            return createKwikEMartScene(with: view, character: "krusty")
        }
        
        // switch out characters
        if let sceneName = userInfo["scene"] as? String , sceneName == "KwikEMart" {
            print("KwikEMart scene")
            return createKwikEMartScene(with: view, character: "krusty")
        } else {
            print("another scene")
            return createKwikEMartScene(with: view, character: "krusty")
        }
    }
    
    fileprivate func createKwikEMartScene(with view: VuforiaEAGLView, character: String) -> SCNScene {
        guard let scene = SCNScene(named: "model_\(character).dae") else {
            return SCNScene()
        }
        
        boxMaterial.diffuse.contents = UIColor.lightGray
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.lightGray
        lightNode.position = SCNVector3(x:0, y:10, z:10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let sphereNode = SCNNode()
        sphereNode.geometry = SCNSphere(radius: 1.0)
        sphereNode.geometry?.firstMaterial = boxMaterial
        sphereNode.position = SCNVector3Make(30, 30, -10)
        scene.rootNode.addChildNode(sphereNode)
        
        return scene
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchDownNode node: SCNNode!) {
        print("touch down \(node.name)\n")
        cameraView?.isHidden = true
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, UIScreen.main.scale)
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        cameraView?.setPhotoThumbnail(image)
        cameraView?.savePhotoToLibrary(image)
        cameraView?.isHidden = false

    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchUp node: SCNNode!) {
        print("touch up \(node.name)\n")
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchCancel node: SCNNode!) {
        print("touch cancel \(node.name)\n")
    }
}

extension SpringfieldViewController: QuickViewDelegate {
    func showPhoto(image: UIImage) {
        if let quickViewController = QuickLookViewController.viewController() {
            quickViewController.photoImage = image
            present(quickViewController, animated: true)
        }
    }
}
