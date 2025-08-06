//
//  MainTabBarController.swift
//  MovieNight
//
//  Created by Karl Kiefer IV on 8/4/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleFirstLaunch()
    }
    
    func handleFirstLaunch() {
        let defaults = UserDefaults.standard

        if let savedGenres = defaults.array(forKey: "selectedGenreIDs"), !savedGenres.isEmpty {
            print("Welcome back! Firing notification to load movies.")
        } else {
            print("First launch. Presenting genre selection.")
            performSegue(withIdentifier: "showGenreSelection", sender: nil)
        }
    }
    
}
