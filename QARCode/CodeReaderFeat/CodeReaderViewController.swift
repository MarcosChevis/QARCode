//
//  CodeReaderViewController.swift
//  QARCode
//
//  Created by Marcos Chevis on 07/06/22.
//

import UIKit
import AVFoundation

final class CodeReaderViewController: UIViewController {
    var captureSession: AVCaptureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let photoOutput = AVCapturePhotoOutput()
    
    var capturedImage: CGImage?
    var finalImage: CGImage?
    var stringValue: String = ""
    var rectImage: CGRect = .init()
    
    var corners: [CGPoint] = .init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    private func setup() {
        setupCaptureSession()
        setupPreviewLayer()
        
        captureSession.startRunning()
    }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            fatalError()
        }
        
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            captureSession.addOutput(photoOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            captureSession.commitConfiguration()
        } else {
            
            return
        }
    }
    
    private func setupPreviewLayer() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = previewLayer else { return }
        
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}

extension CodeReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        
        self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
//        self.rectImage = metadataObjects[0].bounds
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            self.corners = readableObject.corners
            
            self.stringValue = stringValue
            self.captureSession.stopRunning()
        }
        
    }
    
    func found(code: String) {
        print(code)
        let vc = ARHologramViewController(string: code, cgImage: finalImage)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
}

extension CodeReaderViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            guard let data = photo.fileDataRepresentation() else { return }
            let img = UIImage(data: data)!.cgImage//fixImageOrientation(UIImage(data: data)!).cgImage
            self.capturedImage = img
            
            
            guard let capturedImage = self.capturedImage else { return }
            
            self.corners = self.corners.map({ point -> CGPoint in
                var newPoint = point
                guard let capturedImage = self.capturedImage else { return .init() }
                newPoint.x *= CGFloat(capturedImage.width)
                newPoint.y *= CGFloat(capturedImage.height)
                return newPoint
            })
            
            rectImage = CGRect(x: corners[0].x,
                               y: corners[0].y,
                               width: corners[2].x - corners[0].x,
                               height: corners[2].y - corners[0].y)
            
            print(rectImage)
            finalImage =  UIImage(cgImage: capturedImage.cropping(to: self.rectImage)!).rotate(radians: .pi/2)?.cgImage
            
            self.found(code: stringValue)
        }
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
