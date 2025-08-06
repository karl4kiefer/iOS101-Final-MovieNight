//
//  MovieDetailViewController.swift
//  MovieNight
//
//  Created by Karl Kiefer IV on 8/5/25.
//

import UIKit

protocol MovieDetailDelegate: AnyObject {
    func getNewRandomMovie() -> Movie?
}

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var suggestNewButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: MovieDetailDelegate?
    var hideSaveButton = false
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(with: movie)
        suggestNewButton.isHidden = (delegate == nil)
        saveButton.isHidden = hideSaveButton
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview

        if let posterPath = movie.posterPath {
            let imageUrlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
            if let imageUrl = URL(string: imageUrlString) {
                URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.posterImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        }
    }
    
    @IBAction func onSaveTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        var savedMovies = getSavedMovies()

        savedMovies.append(self.movie)

        if let encoded = try? JSONEncoder().encode(savedMovies) {
            defaults.set(encoded, forKey: "savedMovies")
            print("✅ Movie saved! Total saved: \(savedMovies.count)")
        }
    }
    
    func getSavedMovies() -> [Movie] {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "savedMovies") as? Data {
            if let decodedMovies = try? JSONDecoder().decode([Movie].self, from: savedData) {
                return decodedMovies
            }
        }
        return []
    }
    
    @IBAction func onSuggestNewTapped(_ sender: Any) {
        if let newMovie = delegate?.getNewRandomMovie() {
            configure(with: newMovie)
        }
    }
    
}
