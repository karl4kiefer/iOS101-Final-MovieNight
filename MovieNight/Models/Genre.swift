//
//  Genre.swift
//  MovieNight
//
//  Created by Karl Kiefer IV on 8/4/25.
//

import Foundation


struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable {
    let id: Int
    let name: String
}
