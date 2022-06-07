//
//  OnBoardingViewController.swift
//  QARCode
//
//  Created by Bianca Maciel Matos on 07/06/22.
//

import Foundation
import UIKit


class OnBoardingViewController: UIViewController {
    
    var isOnboarding: Bool
    
    // inits
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Cards - Tutorial
    lazy var first_card: OnBoardingView = {
        let card = OnBoardingView(titleLabel: "Aponte a Câmera", labelDescription: "Aponte a câmera para o local em que estiver o QRCode desejado.", imageName: "Tutorial - 1")
    
        return card
    }()
    
    lazy var second_card: OnBoardingView = {
        let card = OnBoardingView(titleLabel: "Selecione o QRCode", labelDescription: "Selecione o QRCode de seu interesse para que ocorra a leitura.", imageName: "Tutorial - 2")
        
        return card
    }()
    
    lazy var third_card: OnBoardingView = {
        let card = OnBoardingView(titleLabel: "Veja o Site saltando", labelDescription: "Veja um holograma da página web no qual o QRCode te leva!", imageName: "Tutorial - 3")
        
        return card
    }()
    
    lazy var arrayOfCards = [first_card, second_card, third_card]
    
    //MARK: ScrollView - Tutorial
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(arrayOfCards.count), height: view.frame.height)
       
        for i in 0..<arrayOfCards.count {
            scrollView.addSubview(arrayOfCards[i])
            arrayOfCards[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
        }
        scrollView.delegate = self
        
        return scrollView
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = arrayOfCards.count
        pageControl.currentPage = 0
        pageControl.isEnabled = false
        pageControl.addTarget(self, action: #selector(pageControlTapHandler(sender:)), for: .valueChanged)
        
        return pageControl
    }()
    
    //MARK: Buttons
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Próximo", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(addPageContol), for: .touchUpInside)
        
        return button
    }()
    
    lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Voltar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(subPageControl), for: .touchUpInside)
        
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        
        /// setting the configuration
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold, scale: .large)
        
        /// adding which SF Symbol image with the configuration created above
        let largeBoldDoc = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)
        
        /// putting the image
        button.setImage(largeBoldDoc, for: .normal)
        
        return button
    }()
    
}

extension OnBoardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // making sure it goes to the other card
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
}
