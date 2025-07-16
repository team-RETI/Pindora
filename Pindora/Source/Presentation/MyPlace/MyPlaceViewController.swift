//  MyPlaceViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

final class MyPlaceViewController: UIViewController {
    private let viewModel: MyPlaceViewModel
    private let customView = MyPlaceView()
    
    // MARK: - Initializer
    init(viewModel: MyPlaceViewModel) {
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
        print("MyPlaceViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
}

#Preview {
    MyPlaceViewController(viewModel: MyPlaceViewModel())
}
