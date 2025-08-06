//
//  GenreSelectionViewController.swift
//  MovieNight
//
//  Created by Karl Kiefer IV on 8/4/25.
//

import UIKit

class GenreSelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var genres: [Genre] = []
    var selectedGenreIDs: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchGenres()
    }
    
    func fetchGenres() {
        let urlString = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(API.key)"
        guard let url = URL(string: urlString) else {
            print("Error: Could not create a URL from \(urlString)")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Error: Did not receive data.")
                return
            }

            do {
                let decoder = JSONDecoder()
                let genreResponse = try decoder.decode(GenreResponse.self, from: data)

                DispatchQueue.main.async {
                    self.genres = genreResponse.genres
                    self.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    @IBAction func onContinueTapped(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.set(selectedGenreIDs, forKey: "selectedGenreIDs")
        print("Saved Genre IDs: \(selectedGenreIDs)")
        NotificationCenter.default.post(name: .genresUpdated, object: nil)
        self.dismiss(animated: true)
    }
    
}


extension GenreSelectionViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath)

        let genre = genres[indexPath.row]

        cell.textLabel?.text = genre.name

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        let selectedGenre = genres[indexPath.row]

        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            selectedGenreIDs.removeAll { $0 == selectedGenre.id }
        } else {
            cell.accessoryType = .checkmark
            selectedGenreIDs.append(selectedGenre.id)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
