//
//  PokemonLocationViewModel.swift
//  diplomado-10-pokedex-kits karla
//
//  Created by Karla Lopez on 23/01/26.
//


import Foundation
import CoreLocation
import UIKit

protocol PokemonLocationViewModelDelegate: AnyObject {
    func didUpdateUserLocation(_ location: CLLocation)
    func didUpdateAuthorization(status: CLAuthorizationStatus)
    func didRequestDismiss()
}

class PokemonLocationViewModel: NSObject {

    // MARK: - Properties

    let pokemon: Pokemon
    let pokemonImage: UIImage?

    private let locationManager = CLLocationManager()
    weak var delegate: PokemonLocationViewModelDelegate?

    // MARK: - Init

    init(pokemon: Pokemon, pokemonImage: UIImage?) {
        self.pokemon = pokemon
        self.pokemonImage = pokemonImage
        super.init()

        configureLocationManager()
    }

    // MARK: - Location setup

    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Pokémon location

    func pokemonCoordinate() -> CLLocationCoordinate2D? {
        guard let location = pokemon.location else { return nil }
        return CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
}

// MARK: - CLLocationManagerDelegate
extension PokemonLocationViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        delegate?.didUpdateAuthorization(status: status)

        if status == .denied || status == .restricted {
            delegate?.didRequestDismiss()
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else { return }
        delegate?.didUpdateUserLocation(location)
    }
}
