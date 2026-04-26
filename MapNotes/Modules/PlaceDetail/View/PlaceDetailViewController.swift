import UIKit
import SnapKit

final class PlaceDetailViewController: UIViewController {
    private let presenter: PlaceDetailViewOutput

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var viewModel = PlaceDetailViewModel(title: .empty, cells: [])

    init(presenter: PlaceDetailViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTableView()
        presenter.viewDidLoad()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.info)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = .Spx8
    }
}

extension PlaceDetailViewController: PlaceDetailViewInput {
    func configure(_ viewModel: PlaceDetailViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        tableView.reloadData()
    }
}

extension PlaceDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModel.cells[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.info, for: indexPath)

        var content = cell.defaultContentConfiguration()
        switch cellType {
        case .info(let title, let value):
            content.text = title
            content.secondaryText = value
            content.secondaryTextProperties.numberOfLines = .zero
            cell.accessoryType = .none
            cell.selectionStyle = .none

        case .description(let text):
            content.text = text
            content.textProperties.numberOfLines = .zero
            cell.accessoryType = .none
            cell.selectionStyle = .none

        case .websiteButton(let website):
            content.text = String.openWebsiteTitle
            content.secondaryText = website
            content.image = .safariIcon
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }

        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = viewModel.cells[indexPath.row]
        if case .websiteButton = cellType {
            presenter.didSelectCell()
        }
    }
}

private enum CellIdentifier {
    static let info = "PlaceDetailInfoCell"
}

private extension String {
    static let openWebsiteTitle = "Открыть сайт"
}
