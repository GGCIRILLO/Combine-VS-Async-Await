//
//  StatsVM.swift
//  NCX
//
//  Created by Luigi Cirillo on 26/03/24.
//

import Foundation

@Observable class StatsVM {
    enum StatsError: Error {
        case invalidURL
        case invalidResponse
        case invalidStatusCode(Int)
        case networkError(Error)
        case decodingError(Error)
    }
    
    func getStats(season: Int, forPlayer playerID: Int) async throws -> [Stats] {
        do {
            let data = try await fetchData(season: season, forPlayer: playerID)
            let stats = try parseStats(data)
            return stats
        } catch {
            throw error
        }
    }
    private func fetchData(season: Int, forPlayer playerID: Int) async throws -> Data {
        guard var urlComponents = URLComponents(string: "http://api.balldontlie.io/v1/season_averages") else {
            throw StatsError.invalidURL
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "season", value: "\(season)"),
            URLQueryItem(name: "player_ids[]", value: "\(playerID)")
        ]
        guard let url = urlComponents.url else {
            throw StatsError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("\(Constants.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = res as? HTTPURLResponse else {
                throw StatsError.invalidResponse
            }
            guard httpResponse.statusCode == 200 else {
                throw StatsError.invalidStatusCode(httpResponse.statusCode)
            }
            return data
        } catch {
            throw StatsError.networkError(error)
        }
        
    }
    
    private func parseStats(_ data:Data) throws -> [Stats] {
        do {
            let response = try JSONDecoder().decode(StatsModel.self, from: data)
            return response.data
        } catch {
            throw StatsError.decodingError(error)
        }
    }
}
