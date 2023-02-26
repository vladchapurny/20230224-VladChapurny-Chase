//
//  ViewController.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    // MARK: Variables
    let searchController = UISearchController()
    let viewModel: MainWeatherViewModel = MainWeatherViewModel()
    private let refreshControl = UIRefreshControl()
    private var cancellables = Set<AnyCancellable>()
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var viewOffScreen: Bool = false
    
    // MARK: Views
    private let weatherStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .center
        stack.sizeToFit()
        return stack
    }()
    
    private let cityNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.AFFontBold(size: 30)
        lbl.numberOfLines = 0 /// in case city name is very long
        return lbl
    }()
    
    private let weatherTemp: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.AFFontBold(size: 70)
        return lbl
    }()
    
    private let weatherDescription: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0 /// in case weather description is very long
        lbl.font = UIFont.AFFontRegular(size: 24)
        return lbl
    }()
    
    private let weatherImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let weatherTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false
        table.separatorInset = .init(top: 40, left: 40, bottom: 40, right: 40)
        table.layer.cornerRadius = 10
        table.rowHeight = 50
        table.estimatedRowHeight = 50
        return table
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherTable.register(WeatherViewCell.self, forCellReuseIdentifier: "weatherCell")
        weatherTable.delegate = self
        weatherTable.dataSource = self
        
        setNavigationControls()
        setupViews()
        setLayoutConstraints()
        setViewText()
        setObservables()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWeatherData), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
    }
    
    @objc func refreshWeatherData() {
        self.viewModel.refreshWeatherData() {
            self.refreshControl.endRefreshing()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Bounds usually load here (minor optimization for gradient)super.viewDidLayoutSubviews()
        view.customGradient()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if UIDevice.current.orientation.isLandscape {
            self.weatherImage.isHidden = true
            NSLayoutConstraint.deactivate(self.regularConstraints)
            NSLayoutConstraint.activate(self.compactConstraints)
        } else {
            self.weatherImage.isHidden = false
            NSLayoutConstraint.deactivate(self.compactConstraints)
            NSLayoutConstraint.activate(self.regularConstraints)
        }
    }

    // MARK: Functions
    private func setNavigationControls() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Current Weather"
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search US Cities (ex. Plano)"
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setObservables() {
        viewModel.$weatherInformation
            .receive(on: DispatchQueue.main)
            .sink { result in
                self.setViewText()
                self.weatherTable.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$weatherImage
            .receive(on: DispatchQueue.main)
            .sink { result in
                self.weatherImage.image = self.viewModel.weatherImage
            }
            .store(in: &cancellables)
    }
    
    private func setViewText() {
        cityNameLabel.text = Utils.Stringify(viewModel.weatherInformation?.name)
        weatherDescription.text = Utils.Stringify(viewModel.weatherInformation?.weather?[0].description)
        weatherTemp.text = Utils.Stringify(Utils.RoundTemp(viewModel.weatherInformation?.main?.temp)) + "°F"
    }
    
    private func setupViews() {
        [cityNameLabel, weatherTemp, weatherDescription].forEach { weatherStack.addArrangedSubview($0) }
        
        /// simple refresh (does not actually move content - demo purpose)
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        scrollView.refreshControl = refreshControl
        [weatherStack, weatherImage, weatherTable].forEach { view.addSubview($0) }
        
        // Putting scrollview on top so you can swipe to refresh on any element
        view.addSubview(scrollView)
    }
    
    private func setLayoutConstraints() {
        
        compactConstraints.append(contentsOf: [
                            weatherStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                            weatherStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                            weatherStack.trailingAnchor.constraint(equalTo: weatherTable.leadingAnchor),
                            weatherStack.heightAnchor.constraint(equalToConstant: 200),
                            weatherTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                            weatherTable.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                            weatherTable.widthAnchor.constraint(equalToConstant: 400),
                            weatherTable.heightAnchor.constraint(equalToConstant: 200 - 1), /// hack: removing buttom most separator
                        ])
        
        regularConstraints.append(contentsOf: [
                            weatherStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                            weatherStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                            weatherStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                            weatherStack.heightAnchor.constraint(equalToConstant: 200),
                            weatherImage.topAnchor.constraint(equalTo: weatherStack.bottomAnchor, constant: 20),
                            weatherImage.bottomAnchor.constraint(equalTo: weatherTable.topAnchor, constant: -20),
                            weatherImage.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                            weatherImage.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                            weatherTable.heightAnchor.constraint(equalToConstant: 200 - 1), /// hack: removing buttom most separator
                            weatherTable.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -6),
                            weatherTable.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                            weatherTable.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
                        ])
        
        if UIDevice.current.orientation.isLandscape {
            self.weatherImage.isHidden = true
            NSLayoutConstraint.deactivate(self.regularConstraints)
            NSLayoutConstraint.activate(self.compactConstraints)
        } else {
            self.weatherImage.isHidden = false
            NSLayoutConstraint.deactivate(self.compactConstraints)
            NSLayoutConstraint.activate(self.regularConstraints)
        }
    }
}

// MARK: TableViewDelegate and TableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleText = "Feels Like"
            cell.infoText = Utils.Stringify(Utils.RoundTemp(viewModel.weatherInformation?.main?.feelsLike)) + "°F"
        case 1:
            cell.titleText = "Humidity"
            cell.infoText = Utils.Stringify(viewModel.weatherInformation?.main?.humidity) + "%"
        case 2:
            cell.titleText = "Pressure"
            cell.infoText = Utils.Stringify(viewModel.weatherInformation?.main?.pressure) + "hPa"
        case 3:
            cell.titleText = "Visibility"
            cell.infoText = Utils.Stringify(viewModel.weatherInformation?.visibility) + "m"
        default:
            fatalError("reached more cells than there should be")
        }

        return cell
    }
}

// MARK: SearchResultsUpdating and SearchBarDelegate
extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Implement drop down with potential locations
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchCity = searchBar.text {
            viewModel.fetchWeatherInformation(city: searchCity)
        }
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        self.searchController.isActive = false
    }
}

