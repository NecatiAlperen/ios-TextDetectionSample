//
//  TabbarController.swift
//  ios-TextDetectionSample
//
//  Created by Necati Alperen IŞIK on 2.08.2024.
//

import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
    }
    
    private func setupTabbar() {
        tabBar.backgroundColor = .systemGray3
        
        let homeViewController = HomeViewController()
        let settingsViewController = SettingsViewController()
        let scannerViewController = ScannerViewController()
        
        let vcFirst = UINavigationController(rootViewController: homeViewController)
        let vcSecond = UINavigationController(rootViewController: settingsViewController)
        let vcThird = UINavigationController(rootViewController: scannerViewController)
        
        vcFirst.tabBarItem.image = UIImage(systemName: "house")
        vcSecond.tabBarItem.image = UIImage(systemName: "gearshape")
        vcThird.tabBarItem.image = UIImage(systemName: "camera.viewfinder")
        
        vcFirst.tabBarItem.title = "Home"
        vcSecond.tabBarItem.title = "Settings"
        vcThird.tabBarItem.title = "Scan"
        
        tabBar.tintColor = .label
        setViewControllers([vcFirst, vcSecond, vcThird], animated: true)
    }
}
