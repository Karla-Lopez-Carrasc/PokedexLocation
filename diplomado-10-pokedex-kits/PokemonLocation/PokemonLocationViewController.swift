//
//  PokemonLocationViewController.swift
//  diplomado-10-pokedex-kits
//
//  Created by Alejandro Mendoza on 17/01/26.
//

import UIKit
import MapKit
import CoreLocation

class PokemonLocationViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: PokemonLocationViewModel


    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.preferredConfiguration = MKHybridMapConfiguration()
        mapView.showsUserLocation = true
        mapView.delegate = self
        return mapView
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self,
                         action: #selector(closeButtonTapped),
                         for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(pokemon: Pokemon, pokemonImage: UIImage?) {
        self.viewModel = PokemonLocationViewModel(
            pokemon: pokemon,
            pokemonImage: pokemonImage
        )
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("Programmatic viewcontroller")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.requestLocationAccess()
    }

    // MARK: - Setup

    private func setupView() {
        view.addSubview(mapView)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Botón existente
        var config = UIButton.Configuration.filled()
        config.title = "Show pokemon location"

        let showPokemonLocationButton = UIButton(configuration: config)
        showPokemonLocationButton.translatesAutoresizingMaskIntoConstraints = false
        showPokemonLocationButton.addTarget(self,
                                            action: #selector(showPokemonLocationButtonTapped),
                                            for: .touchUpInside)

        view.addSubview(showPokemonLocationButton)

        NSLayoutConstraint.activate([
            showPokemonLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            showPokemonLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ])
    }

    // MARK: - Actions

    @objc
    private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc
    private func showPokemonLocationButtonTapped() {
        guard let coordinate = viewModel.pokemonCoordinate() else { return }

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = viewModel.pokemon.name

        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )

        mapView.setRegion(region, animated: true)
    }
}

// MARK: - ViewModel Delegate
extension PokemonLocationViewController: PokemonLocationViewModelDelegate {

    func didUpdateUserLocation(_ location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01,
                                   longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
    }

    func didUpdateAuthorization(status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            let alert = UIAlertController(
                title: "Location permission required",
                message: "To show the Pokémon location, please allow location access in your device settings.",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(title: "Aceptar", style: .default) { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            )

            present(alert, animated: true)
        }
    }

    func didRequestDismiss() {
        dismiss(animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension PokemonLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !(annotation is MKUserLocation) else { return nil }

        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.image = viewModel.pokemonImage
        return annotationView
    }
}
