//
//  APIConfig.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 08.09.26.
//

import Foundation

enum APIConfig {
    
    static var tmdbAccessToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDBAccessToken") as? String
        else {
            fatalError("TMDB Access Token bulunamadı.")
        }
        
        return token
    }
}
