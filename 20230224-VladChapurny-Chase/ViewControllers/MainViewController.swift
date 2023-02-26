//
//  ViewController.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import UIKit
import Combine
import CoreLocation

class MainViewController: UIViewController {
    
    // MARK: Variables
    let searchController = UISearchController()
    let viewModel = MainWeatherViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
        image.contentMode = .scaleAspectFill
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
        print("VIEW DID LOAD")
        setNavigationControls()
        setViews()
        setLayoutConstraints()
        setViewText()
        setObservables()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Bounds usually load here (minor optimization for gradient)super.viewDidLayoutSubviews()
        view.customGradient()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        setViews()
        setLayoutConstraints()
        
        weatherStack.setNeedsLayout()
        weatherStack.layoutIfNeeded()
        
        weatherImage.setNeedsLayout()
        weatherImage.layoutIfNeeded()
        
        weatherTable.setNeedsLayout()
        weatherTable.layoutIfNeeded()
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
            .receive(on: RunLoop.main)
            .sink { result in
                self.setViewText()
                self.weatherTable.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$weatherImage
            .receive(on: RunLoop.main)
            .sink { result in
                self.weatherImage.image = self.viewModel.weatherImage
            }
            .store(in: &cancellables)
    }
    
    private func setViewText() {
        cityNameLabel.text = Stringify(viewModel.weatherInformation?.name)
        weatherDescription.text = Stringify(viewModel.weatherInformation?.weather?[0].description)
        weatherTemp.text = Stringify(RoundTemp(viewModel.weatherInformation?.main?.temp)) + "°F"
    }
    
    private func setViews() {
        weatherTable.register(WeatherViewCell.self, forCellReuseIdentifier: "weatherCell")
        weatherTable.delegate = self
        weatherTable.dataSource = self
        
        [cityNameLabel, weatherTemp, weatherDescription,].forEach { weatherStack.addArrangedSubview($0) }
        
        /// simple refresh (does not actually move content - demo purpose)
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        scrollView.refreshControl = UIRefreshControl()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        weatherStack.setCustomSpacing(20.0, after: cityNameLabel)
        weatherStack.setCustomSpacing(0.0, after: weatherDescription)
        
        if UIDevice.current.orientation.isLandscape {
            [weatherStack, weatherTable].forEach { scrollView.addSubview($0) }
        } else {
            [weatherStack, weatherImage, weatherTable].forEach { scrollView.addSubview($0) }
        }
    }
    
    private func setLayoutConstraints() {
        
        if UIDevice.current.orientation.isLandscape {
            NSLayoutConstraint.activate([
                weatherStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                weatherStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                weatherStack.trailingAnchor.constraint(equalTo: weatherTable.leadingAnchor),
                weatherTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                weatherTable.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                weatherTable.widthAnchor.constraint(equalToConstant: view.layoutMarginsGuide.layoutFrame.size.width/2),
                weatherTable.heightAnchor.constraint(equalToConstant: 200 - 1), /// hack: removing buttom most separator
            ])
        } else {
            NSLayoutConstraint.activate([
                weatherStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                weatherStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                weatherStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                weatherImage.topAnchor.constraint(equalTo: weatherStack.bottomAnchor, constant: 20),
                weatherImage.bottomAnchor.constraint(equalTo: weatherTable.topAnchor, constant: -20),
                weatherImage.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                weatherImage.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                weatherTable.heightAnchor.constraint(equalToConstant: 200 - 1), /// hack: removing buttom most separator
                weatherTable.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
                weatherTable.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                weatherTable.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
            ])
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
            cell.infoText = Stringify(RoundTemp(viewModel.weatherInformation?.main?.feelsLike)) + "°F"
        case 1:
            cell.titleText = "Humidity"
            cell.infoText = Stringify(viewModel.weatherInformation?.main?.humidity) + "%"
        case 2:
            cell.titleText = "Pressure"
            cell.infoText = Stringify(viewModel.weatherInformation?.main?.pressure) + "hPa"
        case 3:
            cell.titleText = "Visibility"
            cell.infoText = Stringify(viewModel.weatherInformation?.visibility) + "m"
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

