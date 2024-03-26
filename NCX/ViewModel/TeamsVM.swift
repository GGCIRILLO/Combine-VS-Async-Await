//
//  TeamsVM.swift
//  NCX
//
//  Created by Luigi Cirillo on 24/03/24.
//

import Foundation

@Observable class TeamsVM {
    enum TeamsError: Error{
        case invalidURL
        case invalidResponse
        case invalidStatusCode(Int)
        case networkError(Error)
        case decodingError(Error)
    }
    
    func getTeams () async throws -> TeamsModel {
        do {
            let data = try await fetchData()
            let teams = try parseTeamsResponse(data)
            return teams
        } catch {
            throw error
        }
    }
    
    private func fetchData() async throws -> Data {
        guard let url = URL(string: "https://api.balldontlie.io/v1/teams") else {
            throw TeamsError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("\(Constants.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = res as? HTTPURLResponse else {
                throw TeamsError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw TeamsError.invalidStatusCode(httpResponse.statusCode)
            }

            return data
        } catch {
            throw TeamsError.networkError(error)
        }
    }
    
    private func parseTeamsResponse(_ data:Data) throws -> TeamsModel {
        do {
            let teams = try JSONDecoder().decode(TeamsModel.self, from: data)
            return teams
        } catch {
            throw TeamsError.decodingError(error)
        }
    }
}
