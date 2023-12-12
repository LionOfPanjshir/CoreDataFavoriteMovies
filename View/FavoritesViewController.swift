//
//  FavoritesViewController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/3/22.
//

import UIKit
//import CoreData

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    
    private var datasource: UITableViewDiffableDataSource<Int, Movie>!
    private var viewContext = PersistenceController.shared.viewContext
    private let movieController = MovieController.shared
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search a movie title"
        sc.searchBar.delegate = self
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpDataSource()
        navigationItem.searchController = searchController
        fetchFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var snapshot = datasource.snapshot()
        guard !snapshot.sectionIdentifiers.isEmpty else { return }
        snapshot.reloadSections([0])
        datasource?.apply(snapshot, animatingDifferences: true)
    }
    
}

private extension FavoritesViewController {
    
    func setUpTableView() {
        tableView.backgroundView = backgroundView
        tableView.register(UINib(nibName: MovieTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
    }
    
    func setUpDataSource() {
        datasource = UITableViewDiffableDataSource<Int, Movie>(tableView: tableView) { tableView, indexPath, movie in
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier) as! MovieTableViewCell
            cell.update(with: movie) {
                self.removeFavorite(movie)
            }
            return cell
        }
    }
    
    func fetchFavorites() {
       // let fetchRequest: NSFetchRequest<Movie>
        let fetchRequest = Movie.fetchRequest()
        let searchParameter = searchController.searchBar.text ?? ""
        if !searchParameter.isEmpty {
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchParameter)
            fetchRequest.predicate = predicate
        }
        
        let context = PersistenceController.shared.viewContext
        
        let objects = try? context.fetch(fetchRequest)
        guard let objects else { return }
        applyNewSnapshot(from: objects)
    }
    
    func applyNewSnapshot(from movies: [Movie]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        datasource?.apply(snapshot, animatingDifferences: true)
        tableView.backgroundView = movies.isEmpty ? backgroundView : nil
    }
    
    func removeFavorite(_ movie: Movie) {
        MovieController.shared.unFavoriteMovie(movie)
        var snapshot = datasource.snapshot()
        snapshot.deleteItems([movie])
        datasource?.apply(snapshot, animatingDifferences: true)
    }
}

extension FavoritesViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.isEmpty {
            fetchFavorites()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchFavorites()
    }
    
}
