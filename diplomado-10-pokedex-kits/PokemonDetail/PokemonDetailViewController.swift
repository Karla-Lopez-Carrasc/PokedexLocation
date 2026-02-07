//
//  PokemonDetailViewController.swift
//  diplomado-10-pokedex-kits
//
//  Created by Alejandro Mendoza on 17/01/26.
//

import UIKit

class PokemonDetailViewController: UIViewController {

    private let viewModel: PokemonDetailViewModel

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return imageView
    }()

    private lazy var pokemonNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.text = viewModel.pokemonNumber
        return label
    }()

    private lazy var locationButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Pokemon location"

        let button = UIButton(configuration: configuration)
        button.addTarget(self,
                         action: #selector(locationButtonTapped),
                         for: .touchUpInside)
        return button
    }()

    init(pokemon: Pokemon) {
        self.viewModel = PokemonDetailViewModel(pokemon: pokemon)
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("Programmatic viewcontroller")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        title = viewModel.pokemonName
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        // Imagen y número
        mainStack.addArrangedSubview(pokemonImageView)
        mainStack.addArrangedSubview(pokemonNumberLabel)

        // Botón de ubicación
        mainStack.addArrangedSubview(locationButton)

        // Weaknesses
        mainStack.addArrangedSubview(
            makeTextSection(
                title: "Weaknesses",
                value: viewModel.weaknesses.isEmpty
                    ? "None"
                    : viewModel.weaknesses.joined(separator: ", ")
            )
        )

        // Evoluciones
        mainStack.addArrangedSubview(
            makeEvolutionSection(
                title: "Previous Evolutions",
                evolutions: viewModel.previousEvolutions
            )
        )

        mainStack.addArrangedSubview(
            makeEvolutionSection(
                title: "Next Evolutions",
                evolutions: viewModel.nextEvolutions
            )
        )

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Sections

    private func makeTextSection(title: String, value: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4

        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.font = .preferredFont(forTextStyle: .body)
        valueLabel.text = value
        valueLabel.numberOfLines = 0

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)

        return stack
    }

    private func makeEvolutionSection(
        title: String,
        evolutions: [Pokemon.Evolution]
    ) -> UIView {

        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 8

        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.text = title
        sectionStack.addArrangedSubview(titleLabel)

        guard !evolutions.isEmpty else {
            let noneLabel = UILabel()
            noneLabel.text = "None"
            sectionStack.addArrangedSubview(noneLabel)
            return sectionStack
        }

        evolutions.forEach { evolution in
            let button = UIButton(type: .system)
            button.setTitle("\(evolution.name) (#\(evolution.num))", for: .normal)
            button.contentHorizontalAlignment = .leading
            button.addAction(UIAction { [weak self] _ in
                self?.handleEvolutionTap(num: evolution.num)
            }, for: .touchUpInside)
            sectionStack.addArrangedSubview(button)
        }

        return sectionStack
    }

    // MARK: - Navigation

    private func handleEvolutionTap(num: String) {
        guard let pokemon = viewModel.pokemonForEvolution(num: num) else {
            let alert = UIAlertController(
                title: "Pokémon not found",
                message: "This Pokémon is not available in the list.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let detailVC = PokemonDetailViewController(pokemon: pokemon)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc
    private func locationButtonTapped() {
        let locationViewController = PokemonLocationViewController(
            pokemon: viewModel.pokemon,
            pokemonImage: pokemonImageView.image
        )
        present(locationViewController, animated: true)
    }
}

// MARK: - ViewModel Delegate
extension PokemonDetailViewController: PokemonDetailViewModelDelegate {
    func updatePokemonImage(to image: UIImage) {
        pokemonImageView.image = image
    }
}
