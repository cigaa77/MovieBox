//
//  SearchViewController.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 08.09.26.
//

import UIKit

final class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emptyStateLabel: UILabel!

    private let viewModel = SearchViewModel()
    private var searchTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UISearchBar Delegate

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        searchBar.resignFirstResponder()

        guard let text = searchBar.text else { return }
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else { return }

        Task {
            errorLabel.isHidden = true
            emptyStateLabel.isHidden = true
            activityIndicator.startAnimating()

            defer {
                activityIndicator.stopAnimating()
            }

            do {
                try await viewModel.searchMovies(query: query)
                emptyStateLabel.isHidden = !viewModel.movies.isEmpty
                tableView.reloadData()
            } catch {
                errorLabel.isHidden = false
                print("search error: \(error.localizedDescription)")
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        searchTask?.cancel()

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            errorLabel.isHidden = true
            emptyStateLabel.isHidden = true
            activityIndicator.stopAnimating()
            viewModel.clearResults()
            tableView.reloadData()
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(400))

                errorLabel.isHidden = true
                activityIndicator.startAnimating()
                emptyStateLabel.isHidden = true

                try await viewModel.searchMovies(query: query)

                guard !Task.isCancelled else { return }

                activityIndicator.stopAnimating()
                emptyStateLabel.isHidden = !viewModel.movies.isEmpty
                tableView.reloadData()

            } catch is CancellationError {
                activityIndicator.stopAnimating()
                return
            } catch {
                activityIndicator.stopAnimating()
                errorLabel.isHidden = false
                print("Search error: \(error.localizedDescription)")
            }

        }
    }

}

// MARK: - UITableView DataSource & Delegate

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchMovieCell",
                for: indexPath
            ) as? SearchMovieTableViewCell
        else {
            return UITableViewCell()
        }

        let movie = viewModel.movies[indexPath.row]
        cell.configure(movie: movie)

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let movie = viewModel.movies[indexPath.row]

        guard
            let detailViewController = storyboard?.instantiateViewController(
                withIdentifier: "MovieDetailViewController"
            ) as? MovieDetailViewController
        else { return }

        detailViewController.movie = movie

        navigationController?.pushViewController(
            detailViewController,
            animated: true
        )
    }
}
