//
//  CardCellListView.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

final class CardCellListView: UITableView {
    // MARK: - Initializer
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - (F)UI Setup
    private func setupUI() {
        let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.88
        let cardHeight: CGFloat = cardWidth * 0.58

        self.separatorStyle = .none
        self.showsVerticalScrollIndicator = false
        self.register(CardCellView.self, forCellReuseIdentifier: "CardCellView")
        self.backgroundColor = .white
        self.rowHeight = cardHeight
    }
}
