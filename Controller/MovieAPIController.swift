//
//  MovieAPIController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/1/22.
//

import Foundation

class MovieAPIController {
    let apiKey = "989c52e"
    let baseURL = URL(string: "http://www.omdbapi.com/")!
    
    func fetchMovies(with searchTerm: String) async throws -> [APIMovie] {
        let query = [
            "apikey": apiKey,
            "s": searchTerm
        ]
        
        let movieRequest = MovieInfoAPIRequest(query: query)
        let searchInfo = try await sendRequest(movieRequest)
        return searchInfo.movies
    }
    
    func sendRequest<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
        let (data, response) = try await URLSession.shared.data(for: request.urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw APIRequestError.itemNotFound }
        
        let decodedResponse = try request.decodeResponse(data: data)
        return decodedResponse
    }
    
    private func fakeMovies() -> [APIMovie] {
        let posterURL1 = URL(string: "https://m.media-amazon.com/images/M/MV5BN2ZkNDgxMjMtZmRiYS00MzFkLTk5ZjgtZDJkZWMzYmUxYjg4XkEyXkFqcGdeQXVyNTIzOTk5ODM@._V1_SX300.jpg")
        let mockMovie1 = APIMovie(title: "Nacho Libre", year: "2006", imdbID: "tt0457510", posterURL: posterURL1)
        let posterURL2 = URL(string: "https://m.media-amazon.com/images/M/MV5BNjYwNTA3MDIyMl5BMl5BanBnXkFtZTYwMjIxNjA3._V1_SX300.jpg")
        let mockMovie2 = APIMovie(title: "Napoleon Dynamite", year: "2004", imdbID: "tt0374900", posterURL: posterURL2)
        let mockMovie3 = APIMovie(title: "Unknown Thriller", year: "not sure", imdbID: "tt03948", posterURL: nil)
        return [mockMovie1, mockMovie2, mockMovie3]
    }
    
}

struct MovieInfoAPIRequest: APIRequest {
    typealias Response = SearchResults
    
    var query: [String: String]
    
    var urlRequest: URLRequest {
        var urlComponents = URLComponents(string: "http://www.omdbapi.com/")!
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value)}
        print(urlComponents.url as Any)
        return URLRequest(url: urlComponents.url!)
    }
    
    func decodeResponse(data: Data) throws -> SearchResults {
        let movieInfo = try JSONDecoder().decode(SearchResults.self, from: data)
        return movieInfo
    }
}

protocol APIRequest {
    associatedtype Response
    
    var urlRequest: URLRequest { get }
    func decodeResponse(data: Data) throws -> Response
}

enum APIRequestError: Error {
    case itemNotFound
}
