import UIKit
import SnapKit

final class CategoryFilterViewController: UIViewController {
    private let presenter: CategoryFilterViewOutput
    private var viewModel = CategoryFilterViewModel(title: .empty, applyButtonTitle: .empty, rows: [])

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        return label
    }()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        return button
    }()

    init(presenter: CategoryFilterViewOutput) {
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
        configureTable()
        presenter.viewDidLoad()
    }
}

private extension CategoryFilterViewController {
    func configureUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(applyButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.Spx3)
            make.leading.trailing.equalToSuperview().inset(CGFloat.Spx4)
        }

        applyButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(CGFloat.Spx4)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.Spx3)
            make.height.equalTo(CGFloat.Spx8 + CGFloat.Spx3)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(CGFloat.Spx2)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(applyButton.snp.top).offset(-CGFloat.Spx2)
        }

        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
    }

    func configureTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseID.categoryCell)
        tableView.dataSource = self
        tableView.delegate = self
    }

    @objc func applyTapped() {
        presenter.didTapApply()
    }
}

extension CategoryFilterViewController: CategoryFilterViewInput {
    func configure(_ viewModel: CategoryFilterViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        applyButton.setTitle(viewModel.applyButtonTitle, for: .normal)
        tableView.reloadData()
    }
}

extension CategoryFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseID.categoryCell, for: indexPath)
        let row = viewModel.rows[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.image = UIImage(systemName: row.iconSystemName)
        content.imageProperties.tintColor = row.tint
        cell.contentConfiguration = content
        cell.accessoryType = row.isSelected ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didToggleCategory(at: indexPath.row)
    }
}

private enum ReuseID {
    static let categoryCell = "CategoryFilterCell"
}
