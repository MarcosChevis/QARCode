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
    
    var sceneView: ARSCNView = {
        let s: ARSCNView = .init(frame: .zero)//ARSCNView(frame: .zero)
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isUserInteractionEnabled = true
        s.debugOptions = .showWireframe

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
        
        self.view.backgroundColor = .red
        sceneView.delegate = self
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let con = ARImageTrackingConfiguration()
        con.maximumNumberOfTrackedImages = 1
        guard let cgImage = self.cgImage else { return }
        print(cgImage.width)
        con.trackingImages = [ARReferenceImage(cgImage, orientation: .up, physicalWidth: 6.5)]
       
        
        sceneView.session.run(con)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        sceneView.session.pause()
    }
    
    func setupConstraints() {
        self.view.addSubview(sceneView)
        
//        if let cgImage = cgImage {
//            let im = UIImage(cgImage: cgImage)
//            let v = UIImageView(image: im)
//            v.contentMode = .scaleAspectFit
//            v.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(v)
////            v.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
////            v.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//            v.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//            v.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//            v.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//            v.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        }
        
        
        
        
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
            let arVC = UIHostingController(rootView: WebView(url: url))
            arVC.willMove(toParent: self)
            // make the hosting VC a child to the main view controller
            self.addChild(arVC)
            
            // set the pixel size of the Card View
            arVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
            arVC.view.layer.zPosition = 1000
            
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
    
    func show(hostingVC: UIHostingController<WebView>, on node: SCNNode) {
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
        
//        let planeNode = SCNNode(geometry: plane)
        
        
        let pyramid = SCNPyramid(width: plane.width, height: plane.height, length: plane.height)
        let pyramidNode = SCNNode(geometry: pyramid)
        
        let mat = SCNMaterial()
//        mat.diffuse.contents =
//        mat.selfIllumination.contents = UIColor.red
        pyramidNode.geometry?.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
//        pyramidNode.geometry?.materials.first?.selfIllumination
        
        let viewPlane = SCNPlane(width: pyramid.width, height: pyramid.height)
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

import WebKit
 
struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

