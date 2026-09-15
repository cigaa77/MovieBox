//
//  TabBarController.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 15.09.26.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabBarApperance()
    }

    private func configureTabBarApperance() {
        let apperance = UITabBarAppearance()
        apperance.configureWithOpaqueBackground()
        apperance.backgroundColor = .black

        tabBar.standardAppearance = apperance
        tabBar.scrollEdgeAppearance = apperance

        tabBar.tintColor = .systemYellow
        tabBar.unselectedItemTintColor = .secondaryLabel
    }
}
