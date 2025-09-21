//  SearchViewController.swift
//  Pindora
//
//  Created by 김동현 on 9/5/25.
//

import UIKit
import Combine

final class SearchDetailViewController: UIViewController {
    private let viewModel: SearchDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private var searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private var currentKeyWords: [String] = []
    
    // MARK: - Initializer
    init(viewModel: SearchDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupTableView()
        setupSearchController()
        bindViewModel()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색어를 입력하세요"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }

    // MARK: - Bindings
    private func bindViewModel() {
        
        // 뒤로가기 버튼
        let searchTextField = searchController.searchBar.searchTextField
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .systemGray
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        searchTextField.leftView = backButton
        searchTextField.leftViewMode = .always

        let searchQuery = searchController.searchBar.searchTextField.textPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .prepend("")   // 처음에 빈 문자열 방출
            .eraseToAnyPublisher()
        
        let input = SearchDetailViewModel.Input(searchKeyword: searchQuery)
        let output = viewModel.transform(input: input)
        
        output.filteredKeywords
            .receive(on: RunLoop.main)
            .sink { [weak self] keywords in
                guard let self = self else { return }
                self.currentKeyWords = keywords
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func didTapBack() {
        // present로 열렸으면 dismiss
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            // push로 열렸으면 pop
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - DataSource
extension SearchDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentKeyWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let text = currentKeyWords[indexPath.row]
        cell.textLabel?.text = text
        return cell
    }
}

extension SearchDetailViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
}

// MARK: - Delegate
extension SearchDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = currentKeyWords[indexPath.row]
        print("선택된 셀: \(text)")
        
        // 선택된 셀 하이라이트 제거
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true)
    }
}


//#Preview {
//    SearchDetailViewController(viewModel: HomeViewModel(locationUseCase: <#T##any LocationUseCaseProtocol#>,
//                                                        searchUseCase: <#T##any SearchUseCaseProtocol#>,
//                                                        imageUseCase: <#T##any ImageUsecaseProtocol#>,
//                                                        placeUseCase: <#T##any PlaceUseCase#>))
//}
