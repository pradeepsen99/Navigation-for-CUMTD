//
//  ViewController.swift
//  UIUC_Transit_2.0
//
//  Created by Pradeep Kumar on 1/1/19.
//  Copyright © 2019 Pradeep Kumar. All rights reserved.
//

import UIKit
import FoldingCell
import paper_onboarding
import CoreLocation

class IntroViewController: UIViewController {
    private static let titleFont = UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    private static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    enum Const {
        static let closeCellHeight: CGFloat = 179
        static let openCellHeight: CGFloat = 488
        static let rowsCount = 10
    }
    
    var cellHeights: [CGFloat] = []
    
    fileprivate let items = [
        OnboardingItemInfo(informationImage: UIImage(named: "star")!.resizeWithPercentage(percentage: 0.8)!,
                           title: "Favorite Stops",
                           description: "You have the option to save your Favorite stops so you wont have to worry about missing out",
                           pageIcon: UIImage(named: "star")!.alpha(0),
                           color: UIColor(red: 1/256, green: 4/255, blue: 13/255, alpha: 1.00),
                           titleColor: UIColor.white,
                           descriptionColor: UIColor.white,
                           titleFont: titleFont,
                           descriptionFont: descriptionFont),
        OnboardingItemInfo(informationImage: UIImage(named: "map_marker")!,
                           title: "Nearest Stops",
                           description: "All the stops nearest to you, sorted by location.",
                           pageIcon: UIImage(named: "map_marker")!.alpha(0),
                           color: UIColor(red: 0.40, green: 0.56, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white,
                           descriptionColor: UIColor.white,
                           titleFont: titleFont,
                           descriptionFont: descriptionFont),
        OnboardingItemInfo(informationImage: UIImage(named: "list")!,
                           title: "All Stops",
                           description: "Search through all stops in the Champaign-Urbana area.",
                           pageIcon: UIImage(named: "list")!.alpha(0),
                           color: UIColor(red: 0.0, green: 0.56, blue: 0.1, alpha: 1.00),
                           titleColor: UIColor.white,
                           descriptionColor: UIColor.white,
                           titleFont: titleFont,
                           descriptionFont: descriptionFont),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use when the app is open
        DispatchQueue.main.async {
            //Requests the user to provide access to use their location.
            self.locationManager.requestWhenInUseAuthorization()
            
//            //Requests the user to provide access to give them notifications for stuff like bus timings.
//            self.center.requestAuthorization(options: self.options) { (granted, error) in
//                if !granted {
//                    print("Something went wrong")
//                }
//            }
            
        }
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //getStartedButton.isHidden = true
        setupPaperOnboardingView()
        view.bringSubviewToFront(getStartedButton)
    }
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // Add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
    

    

}
extension IntroViewController: PaperOnboardingDataSource {
    

    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
//        func onboardinPageItemRadius() -> CGFloat {
//            return 12.5
//        }
//
//        func onboardingPageItemSelectedRadius() -> CGFloat {
//            return 25
//        }
//        func onboardingPageItemColor(at index: Int) -> UIColor {
//            return [UIColor.white.withAlphaComponent(0), UIColor.red, UIColor.green][index]
//        }
    
    
}

extension IntroViewController: PaperOnboardingDelegate {
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 1 {
            
            if self.getStartedButton.alpha == 1 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.getStartedButton.alpha = 0
                })
            }
            
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 2{
            UIView.animate(withDuration: 0.4, animations: {
                self.getStartedButton.alpha = 1
            })
        }
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        //item.titleLabel?.backgroundColor = .redColor()
        //item.descriptionLabel?.backgroundColor = .redColor()
        //item.imageView = ...
    }
}

extension IntroViewController {
    
    @IBAction func getStartedButtonTapped(_: UIButton) {
        print("works")
    }
}


extension UIImage {
    
    //This allows to change the alpha value manually
    //https://stackoverflow.com/questions/28517866/how-to-set-the-alpha-of-an-uiimage-in-swift-programmatically
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    //This allows to resize the image based off of a percentage
    //https://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size/38633826#38633826
    func resizeWithPercentage(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }

}
