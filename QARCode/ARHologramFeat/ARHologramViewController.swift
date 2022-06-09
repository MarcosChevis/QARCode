//
//  ARHologramViewController.swift
//  QARCodeApp
//
//  Created by Marcos Chevis on 01/06/22.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import SwiftUI



final class ARHologramViewController: UIViewController {
    var url: URL?
    var cgImage: CGImage?
    
    var onBoardingButton: UIButton?
    var qrButton: UIButton?

    
    var sceneView: ARSCNView = {
        let s: ARSCNView = .init(frame: .zero)
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isUserInteractionEnabled = true
//        s.debugOptions = .showWireframe

        return s
    }()
    
    init(string: String, cgImage: CGImage?) {
        self.cgImage = cgImage
        self.url = URL(string: string)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        setupConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let con = ARImageTrackingConfiguration()
        con.maximumNumberOfTrackedImages = 1
        guard let cgImage = self.cgImage else { return }
        con.trackingImages = [ARReferenceImage(cgImage, orientation: .up, physicalWidth: 6.5)]
       
        sceneView.session.run(con)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupOnboardingButton()
        setupQRButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    private func setupQRButton() {
        let b = UIButton()
        let v = UIView()
        v.backgroundColor = .blue
        v.translatesAutoresizingMaskIntoConstraints = false
//        b.backgroundColor = .white
        view.addSubview(v)
        v.layer.zPosition = 1
        b.layer.zPosition = 2
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        b.setImage(UIImage(systemName: "qrcode.viewfinder", withConfiguration: largeConfig)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(b)
        b.addTarget(self, action: #selector(popVC), for: .touchUpInside)
        NSLayoutConstraint.activate([
            b.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 8),
            b.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            v.leadingAnchor.constraint(equalTo: b.leadingAnchor, constant: 8),
            v.trailingAnchor.constraint(equalTo: b.trailingAnchor, constant: -8),
            v.topAnchor.constraint(equalTo: b.topAnchor, constant: 6),
            v.bottomAnchor.constraint(equalTo: b.bottomAnchor, constant: -6)
        ])
        v.layer.cornerRadius = 20
        qrButton = b
    }
    
    @objc func popVC() {
        navigationController?.popViewController(animated: false)
    }
    
    private func setupOnboardingButton() {
        let b = UIButton()
        b.backgroundColor = .white
        b.layer.cornerRadius = 85
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        b.setImage(UIImage(systemName: "questionmark.square.fill", withConfiguration: largeConfig)?.withTintColor(UIColor.blue, renderingMode: .alwaysOriginal), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(b)
        b.addTarget(self, action: #selector(presentOnBoarding), for: .touchUpInside)
        NSLayoutConstraint.activate([
            b.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -8),
            b.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        onBoardingButton = b
    }
    
    @objc private func presentOnBoarding() {
        navigationController?.pushViewController(OnBoardingViewController(), animated: true)
    }
    
    func setupConstraints() {
        self.view.addSubview(sceneView)
        
        
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    func createHostingController(for node: SCNNode) {
        guard let url = self.url else { return }
        

        DispatchQueue.main.async {
            let arVC = WebViewController(url: url)
            arVC.willMove(toParent: self)
            // make the hosting VC a child to the main view controller
            self.addChild(arVC)
            
            // set the pixel size of the Card View
            arVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
//            arVC.view.layer.zPosition = 1000
            
            // add the ar card view as a subview to the main view
            self.view.addSubview(arVC.view)
            
            // render the view on the plane geometry as a material
            self.show(hostingVC: arVC, on: node)
        }
    }
    
    func show(viewController: UIViewController, on node: SCNNode) {
        // create a new material
        let material = SCNMaterial()
        
        // this allows the card to render transparent parts the right way
        viewController.view.isOpaque = false
        
        // set the diffuse of the material to the view of the Hosting View Controller
        material.diffuse.contents = viewController.view
        material.diffuse.intensity = 1
        
        // Set the material to the geometry of the node (plane geometry)
        node.geometry?.materials = [material]
        
        
        viewController.view.backgroundColor = UIColor.clear
    }
    
    func show(hostingVC: UIViewController, on node: SCNNode) {
        // create a new material
        let material = SCNMaterial()
        
        // this allows the card to render transparent parts the right way
        hostingVC.view.isOpaque = true
        
        // set the diffuse of the material to the view of the Hosting View Controller
        material.diffuse.contents = hostingVC.view
        
        // Set the material to the geometry of the node (plane geometry)
        node.geometry?.materials = [material]
        
        hostingVC.view.backgroundColor = UIColor.clear
    }
    
}

extension ARHologramViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        guard let planeAnchor = anchor as? ARImageAnchor else { return nil }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.referenceImage.physicalSize.width),
                             height: CGFloat(planeAnchor.referenceImage.physicalSize.height))
        
        let pyramid = SCNPyramid(width: plane.width*1.1, height: plane.height, length: plane.height*1.1)
        let pyramidNode = SCNNode(geometry: pyramid)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
        
        pyramidNode.geometry?.materials = [material]
        
        let viewPlane = SCNPlane(width: pyramid.width*0.9, height: pyramid.height*0.9)
        let viewPlaneNode = SCNNode(geometry: viewPlane)

        

        
        pyramidNode.eulerAngles.z = -.pi
        pyramidNode.eulerAngles.y = -.pi
        
        
        viewPlaneNode.eulerAngles.x = .pi/2
        viewPlaneNode.position.y -= 0.3

        pyramidNode.position.y = Float(pyramid.length)
        
        createHostingController(for: viewPlaneNode)
        
        
        pyramidNode.addChildNode(viewPlaneNode)
        node.addChildNode(pyramidNode)
        return node
        
        
    }
}

 


