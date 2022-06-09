//
//  CodeReaderViewController.swift
//  QARCode
//
//  Created by Marcos Chevis on 07/06/22.
//

import UIKit
import AVFoundation

final class CodeReaderViewController: UIViewController {
    
    struct MetadataInfo {
        var corners: [CGPoint]
        var string: String
    }
    
    var captureSession: AVCaptureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()
//    var detectionOverlays: [CALayer] = []
    
    var capturedImage: CGImage?
    var finalImage: CGImage?
    var finalQRCodeRect: CGRect = .init()
    
    var qrCodes: [MetadataInfo] = []
    var finalQRCode: MetadataInfo?
    
    
    var detectionSublayer: CALayer?
    
    var onBoardingButton: UIButton?
    
    @objc private func presentOnBoarding() {
        navigationController?.pushViewController(OnBoardingViewController(), animated: true)
    }
    
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
        setupButton()
        
        captureSession.startRunning()
    }
    
    private func setupButton() {
        let b = UIButton()
        b.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(b)
        b.addTarget(self, action: #selector(presentOnBoarding), for: .touchUpInside)
        NSLayoutConstraint.activate([
            b.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -8),
            b.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        onBoardingButton = b
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
    
    private func qrCodeMarkerPreviewLayer(qrCodes: [MetadataInfo]) {
        
    }
    
    func found(qrCodeMetadata: MetadataInfo) {
        
        self.finalQRCode = qrCodeMetadata
        self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
        
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let qrCodeMetadata = getQRCodeIn(touchLocation: touch.location(in: self.view), qrCodesMetadata: qrCodes) {
                
                found(qrCodeMetadata: qrCodeMetadata)
                return
            }
        }
        print("oh")
    }
    private func getQRCodeIn(touchLocation: CGPoint, qrCodesMetadata: [MetadataInfo]) -> MetadataInfo? {
        for qrCodeMetadata in qrCodesMetadata {
            if isPointInRect(point: touchLocation, rect: translateCornersSpaceIntoViewSpace(corners: qrCodeMetadata.corners)) {
                return qrCodeMetadata
            }
            return nil
        }
        
        return nil
    }
    private func translateCornersSpaceIntoViewSpace(corners: [CGPoint]) -> CGRect {
       let newCorners = corners.map({ point -> CGPoint in
            var newPoint = point
            newPoint.x *= CGFloat(self.view.frame.height)
            newPoint.y *= CGFloat(self.view.frame.width)
            return newPoint
        })
        
        return CGRect(x: self.view.frame.width - newCorners[0].y,
                      y: newCorners[0].x,
                      width: (newCorners[0].y - newCorners[2].y) ,
                      height: (newCorners[2].x - newCorners[0].x))

    }
    private func isPointInRect(point: CGPoint, rect: CGRect) -> Bool {
        if (point.x > rect.minX && point.x < rect.maxX) && (point.y > rect.minY && point.y < rect.maxY) {
            return true
        }
        
        return false
    }
    
    override var shouldAutorotate: Bool {
        false
    }
    

}

extension CodeReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        qrCodes = []
        
        for metadataObject in metadataObjects {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            qrCodes.append(MetadataInfo(corners: readableObject.corners, string: stringValue))
        }
        
        detectionSublayer?.removeFromSuperlayer()
        let shapeLayer = CAShapeLayer()
        detectionSublayer = shapeLayer
        
        
        guard let oldCorners = (metadataObjects.first as? AVMetadataMachineReadableCodeObject)?.corners else { return }
        
        let rect = translateCornersSpaceIntoViewSpace(corners: oldCorners)
        let offSet = rect.width/3
        
        let bezierPath = UIBezierPath()
        
        
        bezierPath.move(to: CGPoint(x: rect.minX + offSet, y: rect.minY))
        bezierPath.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        bezierPath.addLine(to: CGPoint(x: rect.minX, y: rect.minY + offSet))
        
        bezierPath.move(to: CGPoint(x: rect.maxX - offSet, y: rect.minY))
        bezierPath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        bezierPath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + offSet))
        
        bezierPath.move(to: CGPoint(x: rect.minX + offSet, y: rect.maxY))
        bezierPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        bezierPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - offSet))
        
        bezierPath.move(to: CGPoint(x: rect.maxX - offSet, y: rect.maxY))
        bezierPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        bezierPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - offSet))
        
        
        
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5
        
        previewLayer?.addSublayer(shapeLayer)
        
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
            
            
            guard let capturedImage = self.capturedImage,
                  var finalQRCode = finalQRCode else { return }
            
            finalQRCode.corners = finalQRCode.corners.map({ point -> CGPoint in
                var newPoint = point
                guard let capturedImage = self.capturedImage else { return .init() }
                newPoint.x *= CGFloat(capturedImage.width)
                newPoint.y *= CGFloat(capturedImage.height)
                return newPoint
            })
            
            finalQRCodeRect = CGRect(x: finalQRCode.corners[0].x,
                                     y: finalQRCode.corners[0].y,
                                     width: finalQRCode.corners[2].x - finalQRCode.corners[0].x,
                                     height: finalQRCode.corners[2].y - finalQRCode.corners[0].y)
            
            
            guard let cgImage = capturedImage.cropping(to: finalQRCodeRect) else { return }
            finalImage =  UIImage(cgImage: cgImage).rotate(radians: .pi/2)?.cgImage
            let vc = ARHologramViewController(string: finalQRCode.string, cgImage: finalImage)
            navigationController?.pushViewController(vc, animated: false)
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
