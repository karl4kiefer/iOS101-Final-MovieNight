//
//  MovieListViewController.swift
//  MovieNight
//
//  Created by Karl Kiefer IV on 8/4/25.
//

import UIKit

class MovieListViewController: UIViewController, MovieDetailDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MovieListViewController - viewDidLoad")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("MovieListViewController - viewWillAppear")
        fetchMovies()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRandomMovie" {
            guard let randomMovie = movies.randomElement() else { return }
            let detailViewController = segue.destination as! MovieDetailViewController
            detailViewController.movie = randomMovie
            detailViewController.delegate = self
            
        } else if segue.identifier == "showMovieFromList" {
            let movie = sender as! Movie
            let detailViewController = segue.destination as! MovieDetailViewController
            detailViewController.movie = movie
        }
    }
    
    func getNewRandomMovie() -> Movie? {
        return movies.randomElement()
    }

    func fetchMovies() {
        print("--- Starting fetchMovies ---")
        let defaults = UserDefaults.standard
        guard let selectedGenreIDs = defaults.array(forKey: "selectedGenreIDs") as? [Int], !selectedGenreIDs.isEmpty else {
            print("--- No saved genres found. Aborting. ---")
            return
        }

        let genreIDString = selectedGenreIDs.map { String($0) }.joined(separator: ",")
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(API.key)&with_genres=\(genreIDString)"
        
        print("--- Fetching URL: \(urlString) ---")

        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("--- NETWORK ERROR: \(error.localizedDescription) ---")
                return
            }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                
                DispatchQueue.main.async {
                    print("--- Found \(movieResponse.results.count) movies. Reloading table. ---")
                    self?.movies = movieResponse.results
                    self?.tableView.reloadData()
                }
            } catch {
                print("--- DECODING ERROR: \(error) ---")
            }
        }
        task.resume()
    }
    
    @IBAction func onRandomTapped(_ sender: UIBarButtonItem) {
        guard let randomMovie = movies.randomElement() else { return }
        performSegue(withIdentifier: "showRandomMovie", sender: nil)
    }
    
}

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        performSegue(withIdentifier: "showMovieFromList", sender: movie)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let saveAction = UIContextualAction(style: .normal, title: "Save") { (action, view, completionHandler) in
            
            let movieToSave = self.movies[indexPath.row]
            
            let defaults = UserDefaults.standard
            var savedMovies: [Movie] = []
            if let savedData = defaults.object(forKey: "savedMovies") as? Data {
                if let decodedMovies = try? JSONDecoder().decode([Movie].self, from: savedData) {
                    savedMovies = decodedMovies
                }
            }
            
            savedMovies.append(movieToSave)
            if let encoded = try? JSONEncoder().encode(savedMovies) {
                defaults.set(encoded, forKey: "savedMovies")
                print("✅ Movie saved from list! Total saved: \(savedMovies.count)")
            }
            
            completionHandler(true)
        }
        
        saveAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [saveAction])
        return configuration
    }
}
