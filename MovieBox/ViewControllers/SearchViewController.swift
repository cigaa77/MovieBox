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
            do {
                try await viewModel.searchMovies(query: query)
                tableView.reloadData()
            } catch {
                print("search error: \(error.localizedDescription)")
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        searchTask?.cancel()

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            viewModel.clearResults()
            tableView.reloadData()
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(400))

                try await viewModel.searchMovies(query: query)

                guard !Task.isCancelled else { return }

                tableView.reloadData()

            } catch is CancellationError {
                return
            } catch { print("Search error: \(error.localizedDescription)") }

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
}
