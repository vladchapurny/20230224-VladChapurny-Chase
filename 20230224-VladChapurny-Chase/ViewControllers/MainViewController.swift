//
//  ViewController.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import UIKit
import Combine

/*
 * Main View Controller. This could have been multiple view - however I decided to do it in 1.
 */
class MainViewController: UIViewController {
    
    // MARK: Variables
    let searchController = UISearchController() /// search controller
    let viewModel: MainWeatherViewModel = MainWeatherViewModel() /// View Model
    private let refreshControl = UIRefreshControl() /// refresh controller
    private var cancellables = Set<AnyCancellable>() /// storing subscribers
    private var compactConstraints: [NSLayoutConstraint] = [] /// size constraints for compact
    private var regularConstraints: [NSLayoutConstraint] = [] /// size constraints for regular
    
    // MARK: Views
    /// Main weather stack view
    private let weatherStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .center
        stack.sizeToFit()
        return stack
    }()
    
    /// city name label
    private let cityNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.AFFontBold(size: 30)
        lbl.numberOfLines = 0 /// in case city name is very long
        return lbl
    }()
    
    /// weather temperature label
    private let weatherTemp: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.AFFontBold(size: 70)
        return lbl
    }()
    
    /// weather description label
    private let weatherDescription: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0 /// in case weather description is very long
        lbl.font = UIFont.AFFontRegular(size: 24)
        return lbl
    }()
    
    /// weather image
    private let weatherImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    // custom weather table
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
        
        /// Registering the table
        weatherTable.register(WeatherViewCell.self, forCellReuseIdentifier: Constants.weatherCellIdentifier)
        weatherTable.delegate = self
        weatherTable.dataSource = self
        
        /// Setting up
        setNavigationControls()
        setupViews()
        setLayoutConstraints()
        setViewText()
        setObservables()
        
        /// Refreshing data when user comes back from background (in case they toggled location)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWeatherData), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        /// Refreshing when pulling down to refresh
        self.refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Bounds usually load here (minor optimization for gradient)super.viewDidLayoutSubviews()
        view.customGradient()
    }
    
    /// handing different view depending on size class (could have been better designed!)
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
    /// Setting up navigation controller and adding searchbar
    private func setNavigationControls() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = Constants.currentWeather
        navigationItem.hidesSearchBarWhenScrolling = false
        
        /// Search controller
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = Constants.searchTextMain
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    /// Settings up subscribers as part of Combine framework
    private func setObservables() {
        
        /*
         * DESIGN: can be merged or zipped where we wait for both calls (weather and image) to finish before we display data
         * decision to make it separate: users have slow connection and simply want to see weather details, they can quickly
         * fetch the weather information see it and close the app without having to wait for the image to load
         *
         * If we are waiting for everything a loading screen would probably be appropriate!
         */
        
        /// Subscribed to weather information
        viewModel.$weatherInformation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                /// Update view and reload when new data arrived
                self?.setViewText()
                self?.weatherTable.reloadData()
            }
            .store(in: &cancellables)
        
        /// Subscribed to weather information
        viewModel.$weatherImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.weatherImage.image = result
            }
            .store(in: &cancellables)
    }
    
    /// set the text for the main components
    private func setViewText() {
        cityNameLabel.text = Utils.Stringify(viewModel.weatherInformation?.name)
        weatherDescription.text = Utils.Stringify(viewModel.weatherInformation?.weather?[0].description)
        weatherTemp.text = Utils.Stringify(Utils.RoundTemp(viewModel.weatherInformation?.main?.temp)) + "°F"
    }
    
    /// setup the views
    private func setupViews() {
        [cityNameLabel, weatherTemp, weatherDescription].forEach { weatherStack.addArrangedSubview($0) }
        
        /// simple refresh (does not actually move content - demo purpose)
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        scrollView.refreshControl = refreshControl
        [weatherStack, weatherImage, weatherTable].forEach { view.addSubview($0) }
        
        // Putting scrollview on top so you can swipe to refresh on anywhere
        view.addSubview(scrollView)
    }
    
    /// setup constraints
    private func setLayoutConstraints() {
        
        compactConstraints.append(contentsOf: [
            weatherStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            weatherStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            weatherStack.trailingAnchor.constraint(equalTo: weatherTable.leadingAnchor),
            weatherStack.heightAnchor.constraint(equalToConstant: 200),
            weatherTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            weatherTable.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            weatherTable.widthAnchor.constraint(equalToConstant: 400),
            weatherTable.heightAnchor.constraint(equalToConstant: 200 - 1) /// hack: removing buttom most separator
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
        
        /// Depending on starting orientation manage the view correctly
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
    
    // MARK: Obj-c selectors
    @objc func refreshWeatherData() {
        self.viewModel.refreshWeatherData() {
            self.refreshControl.endRefreshing()
            self.view.setNeedsLayout()
        }
    }
}

// MARK: TableViewDelegate and TableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 /// static value since I know I will only need 4 cells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.weatherCellIdentifier, for: indexPath) as! WeatherViewCell
        
        /// Handle each cells data
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
    
    /// When tapping search on the keyboard fetch the location
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
