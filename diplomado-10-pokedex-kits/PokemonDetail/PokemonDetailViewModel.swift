//
//  PokemonDetailViewModel.swift
//  diplomado-10-pokedex-kits
//
//  Created by Alejandro Mendoza on 17/01/26.
//

import UIKit

protocol PokemonDetailViewModelDelegate: AnyObject {
    func updatePokemonImage(to image: UIImage)
}

class PokemonDetailViewModel {

    let pokemon: Pokemon
    private let listViewModel = PokemonListViewModel()

    weak var delegate: PokemonDetailViewModelDelegate?

    var pokemonName: String { pokemon.name }
    var pokemonNumber: String { pokemon.number }

    var weaknesses: [String] {
        pokemon.weaknesses ?? []
    }

    var previousEvolutions: [Pokemon.Evolution] {
        pokemon.prevEvolution ?? []
    }

    var nextEvolutions: [Pokemon.Evolution] {
        pokemon.nextEvolution ?? []
    }

    init(pokemon: Pokemon) {
        self.pokemon = pokemon

        if let imageURL = URL(string: pokemon.imageURL) {
            loadPokemonImage(from: imageURL)
        }
    }

    func pokemonForEvolution(num: String) -> Pokemon? {
        listViewModel.pokemon(withNumber: num)
    }

    private func loadPokemonImage(from imageURL: URL) {
        DispatchQueue.global().async { [weak self] in
            if let imageData = try? Data(contentsOf: imageURL),
               let pokemonImage = UIImage(data: imageData) {

                DispatchQueue.main.async {
                    self?.delegate?.updatePokemonImage(to: pokemonImage)
                }
            }
        }
    }
}
