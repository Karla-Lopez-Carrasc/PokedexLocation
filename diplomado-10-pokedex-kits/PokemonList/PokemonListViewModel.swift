//
//  PokemonListViewModel.swift
//  diplomado-10-pokedex-kits
//
//  Created by Alejandro Mendoza on 17/01/26.
//

import Foundation

class PokemonListViewModel {

    private let pokemonDataFileName = "pokemon_list"
    private let pokemonDataFileExtension = "json"

    private var allPokemon: [Pokemon] = []
    private var filteredPokemon: [Pokemon] = []

    public let pokemonCellIdentifier = "pokemon-cell"
    public let title = "Pokedex"

    public var pokemonCount: Int {
        filteredPokemon.count
    }

    init() {
        allPokemon = loadPokemonData()
        filteredPokemon = allPokemon
    }

    // MARK: - Public methods
    func pokemon(at indexPath: IndexPath) -> Pokemon {
        filteredPokemon[indexPath.row]
    }

    func filterPokemon(by searchText: String) {
        guard !searchText.isEmpty else {
            filteredPokemon = allPokemon
            return
        }

        let lowercasedText = searchText.lowercased()

        filteredPokemon = allPokemon.filter { pokemon in
            pokemon.name.lowercased().contains(lowercasedText) ||
            pokemon.number.lowercased().contains(lowercasedText)
        }
    }

    func pokemon(withNumber number: String) -> Pokemon? {
        allPokemon.first { $0.number == number }
    }

    // MARK: - Private methods
    private func loadPokemonData() -> [Pokemon] {
        guard let fileURL = Bundle.main.url(forResource: pokemonDataFileName,
                                            withExtension: pokemonDataFileExtension),
              let pokemonData = try? Data(contentsOf: fileURL),
              let pokemonList = try? JSONDecoder().decode([Pokemon].self, from: pokemonData)
        else {
            assertionFailure("Cannot find file \(pokemonDataFileName).\(pokemonDataFileExtension)")
            return []
        }

        return pokemonList
    }
}
