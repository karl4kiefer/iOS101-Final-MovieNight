//
//  SavedViewController.swift
//  MovieNight
//
//  Created by Karl Kiefer IV on 8/4/25.
//

import UIKit

class SavedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var savedMovies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedMovies()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieDetail" {
            let movie = sender as! Movie
            let detailViewController = segue.destination as! MovieDetailViewController
            detailViewController.movie = movie
            detailViewController.hideSaveButton = true
        }
    }
    
    func loadSavedMovies() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "savedMovies") as? Data {
            if let decodedMovies = try? JSONDecoder().decode([Movie].self, from: savedData) {
                self.savedMovies = decodedMovies
                self.tableView.reloadData()
            }
        }
    }
    
    func saveMovies() {
        let defaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(savedMovies) {
            defaults.set(encoded, forKey: "savedMovies")
        }
    }
}

extension SavedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedMovies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = savedMovies[indexPath.row]
        performSegue(withIdentifier: "showMovieDetail", sender: movie)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = savedMovies[indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.overviewLabel.text = movie.overview
        
        if let posterPath = movie.posterPath {
            let imageUrlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
            if let imageUrl = URL(string: imageUrlString) {
                URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.posterImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        }
        return cell
    }
    
    // This function enables the swipe-to-delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedMovies.remove(at: indexPath.row)
            saveMovies()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
