//
//  PokemonListTableViewController.swift
//  diplomado-10-pokedex-kits
//
//  Created by Alejandro Mendoza on 17/01/26.
//

import UIKit

class PokemonListTableViewController: UITableViewController {

    let model = PokemonListViewModel()
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = model.title
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: model.pokemonCellIdentifier)

        setupSearchController()
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokémon by name or number"

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        model.pokemonCount
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: model.pokemonCellIdentifier,
                                                 for: indexPath)

        var cellConfiguration = cell.defaultContentConfiguration()
        let pokemon = model.pokemon(at: indexPath)

        cellConfiguration.text = pokemon.name
        cellConfiguration.secondaryText = pokemon.number

        cell.contentConfiguration = cellConfiguration

        return cell
    }
}

// MARK: - TableView Delegate
extension PokemonListTableViewController {
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let selectedPokemon = model.pokemon(at: indexPath)
        let detailViewController = PokemonDetailViewController(pokemon: selectedPokemon)

        navigationController?.pushViewController(detailViewController,
                                                 animated: true)
    }
}

// MARK: - Search Results Updating
extension PokemonListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        model.filterPokemon(by: searchText)
        tableView.reloadData()
    }
}
