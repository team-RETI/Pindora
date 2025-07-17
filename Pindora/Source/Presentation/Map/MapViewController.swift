//  MapViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

final class MapViewController: UIViewController {
    private let viewModel: MapViewModel
    private let customView = MapView()
    
    // MARK: - Initializer
    init(viewModel: MapViewModel) {
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
        print("MapViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {

    }
}
