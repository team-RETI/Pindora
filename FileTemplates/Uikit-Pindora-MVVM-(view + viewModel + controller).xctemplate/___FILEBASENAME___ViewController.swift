//  ___FILEBASENAME___.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import UIKit

final class ___FILEBASENAME___: UIViewController {
    #warning("ViewModel은 항상 1:1 매칭일 필요는 없습니다. 공유가 적절한 경우에는 삭제 후 기존 인스턴스를 재사용하세요.")
    private let viewModel: ___VARIABLE_productName:identifier___ViewModel
    private let customView = ___VARIABLE_productName:identifier___View()
    
    // MARK: - Initializer
    init(viewModel: ___VARIABLE_productName:identifier___ViewModel) {
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

    // MARK: - Bindings
    private func bindViewModel() {

    }
}

#Preview {
    ___FILEBASENAME___(viewModel: ___VARIABLE_productName:identifier___ViewModel())
}
