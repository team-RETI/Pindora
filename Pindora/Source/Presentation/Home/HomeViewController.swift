//  HomeViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    
    // UI Components
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 장소가 필요하세요?"
        label.font = UIFont(name: "Inter 24pt", size: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0 // 줄바꿈 허용 (Line height가 Auto인 경우 필요)
        return label
    }()
    
    private let blackHeaderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
        view.clipsToBounds = false
        return view
    }()
    
    private let searchBarView = SearchBarView()
    private let categoryListView = CategoryCellListView()
    private let recommendLabel = UILabel()
    private let buttonLabel = UILabel()
    private let sortButton = UIButton()
    private let placeListView = CardCellListView()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HomeViewController")
    }
    
    
    // UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(blackHeaderContainerView)
        blackHeaderContainerView.addSubview(headerLabel)
        blackHeaderContainerView.addSubview(searchBarView)
        blackHeaderContainerView.addSubview(categoryListView)
        
        view.addSubview(recommendLabel)
        view.addSubview(buttonLabel)
        view.addSubview(sortButton)
        view.addSubview(placeListView)
        
        recommendLabel.text = "장소추천"
        recommendLabel.font = .boldSystemFont(ofSize: 20)
        recommendLabel.textColor = .black
        
        buttonLabel.text = "거리순"
        buttonLabel.font = .systemFont(ofSize: 12)
        buttonLabel.textColor = .black
        sortButton.setImage(UIImage(named: "Vector"), for: .normal)
    }
    
    private func setupLayout() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        categoryListView.translatesAutoresizingMaskIntoConstraints = false
        blackHeaderContainerView.translatesAutoresizingMaskIntoConstraints = false
        recommendLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        placeListView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 검정 컨테이너
            blackHeaderContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            blackHeaderContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackHeaderContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blackHeaderContainerView.bottomAnchor.constraint(equalTo: categoryListView.bottomAnchor, constant: 20),
            
            headerLabel.topAnchor.constraint(equalTo: blackHeaderContainerView.topAnchor, constant: 65),
            headerLabel.centerXAnchor.constraint(equalTo: blackHeaderContainerView.centerXAnchor),
            
            searchBarView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 19),
            searchBarView.leadingAnchor.constraint(equalTo: blackHeaderContainerView.leadingAnchor, constant: 16),
            searchBarView.trailingAnchor.constraint(equalTo: blackHeaderContainerView.trailingAnchor, constant: -16),
            searchBarView.heightAnchor.constraint(equalToConstant: 34),
            
            categoryListView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 26),
            categoryListView.leadingAnchor.constraint(equalTo: blackHeaderContainerView.leadingAnchor),
            categoryListView.trailingAnchor.constraint(equalTo: blackHeaderContainerView.trailingAnchor),
            categoryListView.heightAnchor.constraint(equalToConstant: 30),
            
            // 추천 라벨, 정렬 버튼
            recommendLabel.topAnchor.constraint(equalTo: blackHeaderContainerView.bottomAnchor, constant: 20),
            recommendLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            sortButton.centerYAnchor.constraint(equalTo: recommendLabel.centerYAnchor),
            sortButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonLabel.centerYAnchor.constraint(equalTo: recommendLabel.centerYAnchor),
            buttonLabel.trailingAnchor.constraint(equalTo: sortButton.leadingAnchor, constant: -2),
            
            // 장소 리스트 뷰
            placeListView.topAnchor.constraint(equalTo: recommendLabel.bottomAnchor, constant: 12),
            placeListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

#Preview {
    HomeViewController(viewModel: HomeViewModel())
}
