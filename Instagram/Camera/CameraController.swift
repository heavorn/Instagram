//
//  CameraController.swift
//  Instagram
//
//  Created by Sovorn on 10/4/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    let dismisButtom: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "right_arrow_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        return button
    }()
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capture_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleDismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        
        setupCameraSession()
        setupButton()
    }
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismiss = CustomAnimationDismiss()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismiss
    }
    
    private func setupButton(){
        view.addSubview(capturePhotoButton)
        view.addSubview(dismisButtom)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismisButtom.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
    }
    
    @objc func handleCapturePhoto() {
        let settings = AVCapturePhotoSettings()
        guard let preViewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {return}
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: preViewFormatType]
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!)
        
        let previewImage = UIImage(data: imageData!)
        let containerView = PreviewPhotoContainerView()
        containerView.preViewImage.image = previewImage
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let output = AVCapturePhotoOutput()
    
    private func setupCameraSession(){
        //setup Input
        
        let captureSession = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup Camera input", err)
        }
        
        //setup output
        
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }
        
        //setup output previe
        let previewLayout = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayout.frame = view.frame
        
        view.layer.addSublayer(previewLayout)
        captureSession.startRunning()
    }
}

