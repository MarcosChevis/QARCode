//
//  OnBoardingView.swift
//  QARCode
//
//  Created by Bianca Maciel Matos on 07/06/22.
//

import Foundation
import UIKit

class OnBoardingView: UIView {
    
    var titleLabel = UILabel()
    var labelDescription = UILabel()
    var imageName = String()
    
    lazy var image = UIImage(named: imageName)
    lazy var imageView = UIImageView(image: image!)
    
    
    init(titleLabel: String, labelDescription: String, imageName: String) {
        self.titleLabel.text = titleLabel
        self.labelDescription.text = labelDescription
        self.imageName = imageName
        
        
        super.init(frame: .zero)

        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        // title label
        //titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont .boldSystemFont(ofSize: 35.0)
        
        labelDescription.font = .systemFont(ofSize: 20.0)
        labelDescription.numberOfLines = 2
        
        imageView.contentMode = .scaleAspectFit
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        // unauthorizing automatic constraints

        self.addSubview(titleLabel)
        self.addSubview(labelDescription)
        self.addSubview(imageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let size = UIScreen.main.bounds
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: size.height*0.1),
            titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            
            labelDescription.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 30),
            labelDescription.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            labelDescription.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),

//            imageView.widthAnchor.constraint(equalToConstant: 250),
            imageView.centerXAnchor.constraint(equalTo: self.labelDescription.centerXAnchor),
//            imageView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 30),
            imageView.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: 16),
            imageView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.9)
            
        ])
            
    }
}
