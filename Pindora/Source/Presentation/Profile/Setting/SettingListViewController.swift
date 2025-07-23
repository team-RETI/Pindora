//
//  SettingListViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/23/25.
//

import UIKit

protocol SettingListViewControllerDelegate: AnyObject {
    /// 화면이동
    func didTapAccountSetting()
    /// 화면이동
    func didTapTermsOfService()
    /// 화면이동
    func didTapPrivacyPolicy()
    /// 화면이동
    func backButtonTapped()
}

final class SettingListViewController: UITableViewController {
    weak var delegate: SettingListViewControllerDelegate?
    
    private let viewModel: SettingListViewModel
    private let customView = SettingListView()
    
    // MARK: - Initializer
    init(viewModel: SettingListViewModel) {
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
        customView.navigationBarView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customView.accountButton.addTarget(self, action: #selector(didtapAccountSetting), for: .touchUpInside)
        customView.privacyButton.addTarget(self, action: #selector(didTapPrivacyPolicy), for: .touchUpInside)
        customView.termsButton.addTarget(self, action: #selector(didTapTermsOfService), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SettingListViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }

    @objc private func didtapAccountSetting() {
        delegate?.didTapAccountSetting()
    }
    
    @objc private func didTapTermsOfService() {
        delegate?.didTapTermsOfService()
    }
    
    @objc private func didTapPrivacyPolicy() {
        delegate?.didTapPrivacyPolicy()
    }
    
    @objc private func backButtonTapped() {
        delegate?.backButtonTapped()
    }
}
