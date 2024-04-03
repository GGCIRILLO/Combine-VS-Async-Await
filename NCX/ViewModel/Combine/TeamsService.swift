//
//  TeamsService.swift
//  NCX
//
//  Created by Luigi Cirillo on 03/04/24.
//

import Foundation
import Combine

class TeamsService {
    enum TeamsError: Error {
        case invalidURL
        case invalidResponse
        case invalidStatusCode(Int)
        case networkError(Error)
        case decodingError(Error)
    }
    
    func getTeams() -> AnyPublisher<TeamsModel, Error> {
        guard let url = URL(string: "https://api.balldontlie.io/v1/teams") else {
            return Fail(error: TeamsError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("\(Constants.apiKey)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw TeamsError.invalidResponse
                }
                
                guard httpResponse.statusCode == 200 else {
                    throw TeamsError.invalidStatusCode(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: TeamsModel.self, decoder: JSONDecoder())
            .mapError { error in
                if let teamsError = error as? TeamsError {
                    return teamsError
                } else {
                    return TeamsError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

