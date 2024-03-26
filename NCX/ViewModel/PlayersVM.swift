import Foundation

@Observable class PlayersVM {
    
    enum PlayersError: Error {
        case invalidURL
        case invalidResponse
        case invalidStatusCode(Int)
        case networkError(Error)
        case decodingError(Error)
    }
    
    func getPlayers(forTeam teamID: Int) async throws -> [Player] {
        do {
            let data = try await fetchData(forTeam: teamID)
            let players = try parsePlayersResponse(data)
            return players
        } catch {
            throw error
        }
    }
    
    private func fetchData(forTeam teamID: Int) async throws -> Data {
            guard var urlComponents = URLComponents(string: "http://api.balldontlie.io/v1/players") else {
                throw PlayersError.invalidURL
            }
        
            urlComponents.queryItems = [
                URLQueryItem(name: "team_ids[]", value: "\(teamID)"),
                URLQueryItem(name: "per_page", value: "16")
            ]
            
            guard let url = urlComponents.url else {
                throw PlayersError.invalidURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.addValue("Bearer \(Constants.apiKey2)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, res) = try await URLSession.shared.data(for: urlRequest)

                guard let httpResponse = res as? HTTPURLResponse else {
                    throw PlayersError.invalidResponse
                }

                guard httpResponse.statusCode == 200 else {
                    throw PlayersError.invalidStatusCode(httpResponse.statusCode)
                }

                return data
            } catch {
                throw PlayersError.networkError(error)
            }
        }
    private func parsePlayersResponse(_ data: Data) throws -> [Player] {
        do {
            let response = try JSONDecoder().decode(PlayersModel.self, from: data)
            return response.data
        } catch {
            throw PlayersError.decodingError(error)
        }
    }
}
