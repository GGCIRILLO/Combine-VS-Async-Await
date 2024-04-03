//
//  TeamsVMCombine.swift
//  NCX
//
//  Created by Luigi Cirillo on 03/04/24.
//

import Foundation
import Combine

@Observable class TeamsVMCombine {
        private var cancellables = Set<AnyCancellable>()
        private let teamsService = TeamsService()
        var teams: [Team] = []
        var errorMessage: String?
        
        func fetchTeams() {
            teamsService.getTeams()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                }, receiveValue: { teams in
                    self.teams = teams.data
                })
                .store(in: &cancellables)
        }
}
