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
    let captureSession = AVCaptureSession()
    let imageOutput = AVCaptureStillImageOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    
    var focusMarker: UIImageView!
    var exposureMarker: UIImageView!
    var resetMarker: UIImageView!
    fileprivate var adjustingExposureContext: String = ""
    
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
            cameraView.switchCameras = { [weak self] in
                guard let this = self else {
                    return
                }
                // Make sure the device has more than 1 camera.
                if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 1 {
                    // Check which position the active camera is.
                    var newPosition: AVCaptureDevicePosition!
                    if this.activeInput.device.position == AVCaptureDevicePosition.back {
                        newPosition = AVCaptureDevicePosition.front
                    } else {
                        newPosition = AVCaptureDevicePosition.back
                    }
                    
                    // Get camera at new position.
                    var newCamera: AVCaptureDevice!
                    let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
                    for device in devices! {
                        if (device as AnyObject).position == newPosition {
                            newCamera = device as! AVCaptureDevice
                        }
                    }
                    
                    // Create new input and update capture session.
                    do {
                        let input = try AVCaptureDeviceInput(device: newCamera)
                        this.captureSession.beginConfiguration()
                        // Remove input for active camera.
                        this.captureSession.removeInput(this.activeInput)
                        // Add input for new camera.
                        if this.captureSession.canAddInput(input) == true {
                            this.captureSession.addInput(input)
                           this.activeInput = input
                        } else {
                            this.captureSession.addInput(this.activeInput)
                        }
                        this.captureSession.commitConfiguration()
                    } catch {
                        print("Error switching cameras: \(error)")
                    }
                }
            }
            self.cameraView = cameraView
            view.addSubview(cameraView)
        }
        setupSession()
        setupPreview()
        startSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Setup session and preview
    
    func setupSession() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device input: \(error)")
        }
        
        imageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        if captureSession.canAddOutput(imageOutput) {
            captureSession.addOutput(imageOutput)
        }
        
    }
    
    
    func setupPreview() {
        guard let camPreview = cameraView?.camPreview else {
            return
        }
        
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
        
        // Attach tap recognizer for focus & exposure.
        let tapForFocus = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.tapToFocus(_:)))
        tapForFocus.numberOfTapsRequired = 1
        
        let tapForExposure = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.tapToExpose(_:)))
        tapForExposure.numberOfTapsRequired = 2
        
        let tapForReset = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.resetFocusAndExposure))
        tapForReset.numberOfTapsRequired = 2
        tapForReset.numberOfTouchesRequired = 2
        
        camPreview.addGestureRecognizer(tapForFocus)
        camPreview.addGestureRecognizer(tapForExposure)
        camPreview.addGestureRecognizer(tapForReset)
        tapForFocus.require(toFail: tapForExposure)
        
        // Create marker views.
        focusMarker = imageViewWithImage("Focus_Point")
        exposureMarker = imageViewWithImage("Exposure_Point")
        resetMarker = imageViewWithImage("Reset_Point")
        camPreview.addSubview(focusMarker)
        camPreview.addSubview(exposureMarker)
        camPreview.addSubview(resetMarker)
    }
    
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
    }
    
    // MARK: - Configure

    // MARK: Focus Methods
    func tapToFocus(_ recognizer: UIGestureRecognizer) {
//        guard let camPreview = cameraView?.camPreview else {
//            return
//        }
//        if activeInput.device.isFocusPointOfInterestSupported {
//            let point = recognizer.location(in: camPreview)
//            let pointOfInterest = previewLayer.captureDevicePointOfInterest(for: point)
//            showMarkerAtPoint(point, marker: focusMarker)
//            focusAtPoint(pointOfInterest)
//        }
    }
    
    func focusAtPoint(_ point: CGPoint) {
        let device = activeInput.device
        // Make sure the device supports focus on POI and Auto Focus.
        if (device?.isFocusPointOfInterestSupported)! &&
            (device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus))! {
            do {
                try device?.lockForConfiguration()
                device?.focusPointOfInterest = point
                device?.focusMode = AVCaptureFocusMode.autoFocus
                device?.unlockForConfiguration()
            } catch {
                print("Error focusing on POI: \(error)")
            }
        }
    }
    
    // MARK: Exposure Methods
    func tapToExpose(_ recognizer: UIGestureRecognizer) {
//        guard let camPreview = cameraView?.camPreview else {
//            return
//        }
//        if activeInput.device.isExposurePointOfInterestSupported {
//            let point = recognizer.location(in: camPreview)
//            let pointOfInterest = previewLayer.captureDevicePointOfInterest(for: point)
//            showMarkerAtPoint(point, marker: exposureMarker)
//            exposeAtPoint(pointOfInterest)
//        }
    }
    
    func exposeAtPoint(_ point: CGPoint) {
        let device = activeInput.device
        if (device?.isExposurePointOfInterestSupported)! &&
            (device?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure))! {
            do {
                try device?.lockForConfiguration()
                device?.exposurePointOfInterest = point
                device?.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                
                if (device?.isExposureModeSupported(AVCaptureExposureMode.locked))! {
                    device?.addObserver(self,
                                        forKeyPath: "adjustingExposure",
                                        options: NSKeyValueObservingOptions.new,
                                        context: &adjustingExposureContext)
                    
                    device?.unlockForConfiguration()
                }
            } catch {
                print("Error exposing on POI: \(error)")
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if context == &adjustingExposureContext {
            let device = object as! AVCaptureDevice
            if !device.isAdjustingExposure &&
                device.isExposureModeSupported(AVCaptureExposureMode.locked) {
                (object as AnyObject).removeObserver(self,
                                                     forKeyPath: "adjustingExposure",
                                                     context: &adjustingExposureContext)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    do {
                        try device.lockForConfiguration()
                        device.exposureMode = AVCaptureExposureMode.locked
                        device.unlockForConfiguration()
                    } catch {
                        print("Error exposing on POI: \(error)")
                    }
                })
                
            }
        } else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }
    
    // MARK: Reset Focus and Exposure
    func resetFocusAndExposure() {
        let device = activeInput.device
        let focusMode = AVCaptureFocusMode.continuousAutoFocus
        let exposureMode = AVCaptureExposureMode.continuousAutoExposure
        
        let canResetFocus = (device?.isFocusPointOfInterestSupported)! &&
            (device?.isFocusModeSupported(focusMode))!
        let canResetExposure = (device?.isExposurePointOfInterestSupported)! &&
            (device?.isExposureModeSupported(exposureMode))!
        
        let center = CGPoint(x: 0.5, y: 0.5)
        
        if canResetFocus || canResetExposure {
            let markerCenter = previewLayer.pointForCaptureDevicePoint(ofInterest: center)
            showMarkerAtPoint(markerCenter, marker: resetMarker)
        }
        
        do {
            try device?.lockForConfiguration()
            if canResetFocus {
                device?.focusMode = focusMode
                device?.focusPointOfInterest = center
            }
            if canResetExposure {
                device?.exposureMode = exposureMode
                device?.exposurePointOfInterest = center
            }
            
            device?.unlockForConfiguration()
        } catch {
            print("Error resetting focus & exposure: \(error)")
        }
    }
    
    // MARK: Flash Modes
    @IBAction func setFlashMode(_ sender: AnyObject) {
        let avDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // check if the device has torch
        if avDevice?.hasTorch == true {
            // lock your device for configuration
            do {
                let abv = try avDevice?.lockForConfiguration()
            } catch {
                print("aaaa")
            }
            
            // check if your torchMode is on or off. If on turns it off otherwise turns it on
            if avDevice?.isTorchActive == true {
                avDevice?.torchMode = AVCaptureTorchMode.off
            } else {
                // sets the torch intensity to 100%
                do {
                    let abv = try avDevice?.setTorchModeOnWithLevel(1.0)
                } catch {
                    print("bbb")
                }
                //    avDevice.setTorchModeOnWithLevel(1.0, error: nil)
            }
            // unlock your device
            avDevice?.unlockForConfiguration()
        }
        
    }
    
    // MARK: - Capture photo
    @IBAction func capturePhoto(_ sender: AnyObject) {
        let connection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = currentVideoOrientation()
        }
        
        imageOutput.captureStillImageAsynchronously(from: connection, completionHandler: { (sampleBuffer, error) in
            if sampleBuffer != nil {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let image = UIImage(data: imageData!)
                self.savePhotoToLibrary(image!)
            } else {
                print("Error capturing photo: \(error?.localizedDescription)")
            }
        })
    }
    
    
    
    // MARK: - Helpers
    func savePhotoToLibrary(_ image: UIImage) {
        let photoLibrary = PHPhotoLibrary.shared()
        photoLibrary.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success: Bool, error: Error?) -> Void in
            if success {
                // Set thumbnail
                self.setPhotoThumbnail(image)
            } else {
                print("Error writing to photo library: \(error!.localizedDescription)")
            }
        }
    }
    
    func setPhotoThumbnail(_ image: UIImage) {
        DispatchQueue.main.async { () -> Void in
            self.cameraView?.thumbnail.contentMode = .scaleAspectFill
            
            self.cameraView?.thumbnail.setBackgroundImage(image, for: UIControlState())
            
            self.cameraView?.thumbnail.layer.borderColor = UIColor.white.cgColor
            self.cameraView?.thumbnail.layer.borderWidth = 1.0
            
        }
    }
    
    func imageViewWithImage(_ name: String) -> UIImageView {
        let view = UIImageView()
        let image = UIImage(named: name)
        view.image = image
        view.sizeToFit()
        view.isHidden = true
        
        return view
    }
    
    func showMarkerAtPoint(_ point: CGPoint, marker: UIImageView) {
        marker.center = point
        marker.isHidden = false
        
        UIView.animate(withDuration: 0.15,
                       delay: 0.0,
                       options: UIViewAnimationOptions(),
                       animations: { () -> Void in
                        marker.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
        }) { (Bool) -> Void in
            let delay = 0.5
            let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime, execute: { () -> Void in
                marker.isHidden = true
                marker.transform = CGAffineTransform.identity
            })
        }
    }
    
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
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
        let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    func randomInt(_ n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    
    
}

