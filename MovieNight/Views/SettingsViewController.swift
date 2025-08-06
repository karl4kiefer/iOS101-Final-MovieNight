//
//  SettingsViewController.swift
//  MovieNight
//
//  Created by Karl Kiefer IV on 8/4/25.
//

import UIKit

class SettingsViewController: UITableViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            showClearDataAlert()
        }
    }


    func showClearDataAlert() {
        let alert = UIAlertController(title: "Clear All Data?", message: "This will erase your saved movies and genre preferences. This action cannot be undone.", preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { _ in
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "savedMovies")
            defaults.removeObject(forKey: "selectedGenreIDs")
            print("All app data cleared.")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }


}
