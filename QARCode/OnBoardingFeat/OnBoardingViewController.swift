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
    
    //MARK: inits
    init(isOnboarding: Bool) {
        self.isOnboarding = isOnboarding
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
        
        /// setting somethings of the button
        button.layer.cornerRadius = 30
        
        /// onBoarding
        isOnboarding ? button.addTarget(self, action: #selector(actionNavigateViewController), for: .touchUpInside) : button.addTarget(self, action: #selector(actionDismiss), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: objc
    @objc
    func pageControlTapHandler(sender: UIPageControl) {
        var frame: CGRect = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage )
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @objc
    func addPageContol(){
        if (scrollView.contentOffset.x+view.frame.width < view.frame.width*CGFloat(arrayOfCards.count)) {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x+view.frame.width, y: 0), animated: false)
            
            if (scrollView.contentOffset.x+view.frame.width == view.frame.width*CGFloat(arrayOfCards.count)) {
                nextButton.setTitle("Terminar", for: .normal)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    func subPageControl(){
        nextButton.setTitle("Próximo", for: .normal)
        if (scrollView.contentOffset.x-view.frame.width>=0){
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x-view.frame.width, y: 0), animated: false)
        }
    }
    
    @objc
    func actionDismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func actionNavigateViewController() {
        //TODO: colocar para qual viewController isso aqui vai dar dismiss
    }
    
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        /// setting up after loading the view
        view.backgroundColor = UIColor(named: "corAzul")
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(closeButton)
        setupConstraints()
    }
    
    //MARK: Constraints
    func setupConstraints() {
        
        // unauthorizing automatic constraints
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            /// pageControl
            pageControl.heightAnchor.constraint(equalToConstant: 50),
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -30),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            /// scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height/6),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height/3),
            
            /// nextButton
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant:-30),
            
            /// previousButton
            previousButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            previousButton.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 30),
            
            /// closeButton
            closeButton.widthAnchor.constraint(equalToConstant: 48),
            closeButton.heightAnchor.constraint(equalToConstant: 48),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant:16)
            
        ])
    }
}

extension OnBoardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // making sure it goes to the other card
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
}
