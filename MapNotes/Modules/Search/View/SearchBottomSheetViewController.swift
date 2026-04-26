import UIKit
import SnapKit

final class SearchBottomSheetViewController: UIViewController {
    private let presenter: SearchBottomSheetViewOutput
    private var viewModel = SearchViewModel(rows: [], isLoading: true)

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activity = UIActivityIndicatorView(style: .medium)
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = .searchSheetPlaceholder
        return bar
    }()

    init(presenter: SearchBottomSheetViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(activity)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.Spx4)
            make.leading.trailing.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        activity.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        searchBar.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseID.resultCell)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
    }
}

extension SearchBottomSheetViewController: SearchBottomSheetViewInput {
    func configure(_ viewModel: SearchViewModel) {
        self.viewModel = viewModel
        viewModel.isLoading ? activity.startAnimating() : activity.stopAnimating()
        tableView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: .searchErrorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .commonOK, style: .default))
        present(alert, animated: true)
    }
}

extension SearchBottomSheetViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.queryDidChange(searchText)
    }
}

extension SearchBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseID.resultCell, for: indexPath)
        let row = viewModel.rows[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.secondaryText = row.subtitle
        content.image = UIImage(systemName: row.iconSystemName)
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectResult(at: indexPath.row)
        dismiss(animated: true)
    }
}

private enum ReuseID {
    static let resultCell = "SearchResultCell"
}

private extension String {
    static let searchSheetPlaceholder = "Введите название места"
    static let searchErrorTitle = "Ошибка поиска"
    static let commonOK = "OK"
}
