//
//  CardDetailViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/29/25.
//

import UIKit

final class CardDetailViewController: UIViewController {
    weak var coordinator: CardDetailCoordinating?
    private let viewModel: CardDetailViewModel
    private let customView = CardDetailView()
    
    // MARK: - Initializer
    init(viewModel: CardDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("CardDetailViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        
    }
    
}
