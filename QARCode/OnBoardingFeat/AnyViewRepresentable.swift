//
//  AnyViewRepresentable.swift
//  QARCode
//
//  Created by Bianca Maciel Matos on 07/06/22.
//

import Foundation
import UIKit
import SwiftUI

public struct AnyViewControllerRepresentable: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController
    
    private let viewController: UIViewController
    
    public init(of viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        return self.viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
}
