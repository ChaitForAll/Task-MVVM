//
//  TodoMarkingViewController.swift
//  TaskMVVM
//
//  Copyright (c) 2025 Jeremy All rights reserved.


import UIKit

final class TodoMarkingViewController: UIViewController {
    
    //MARK: Type(s)
    
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, UUID>
    private enum Section { case todos }
    
    //MARK: Property(s)
    
    var viewModel: TodoMarkingViewModel?
    
    private var headerView: SummaryHeaderView?
    private var diffableDataSource: DiffableDataSource?
    
    private let collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: .init()
    )
    
    // MARK: Override(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItems()
        configureCollectionView()
        bindViewModel()
        viewModel?.needItems()
    }
    
    // MARK: Private Function(s)
    
    @objc private func didTapCreateTaskButton() {
        let alert = UIAlertController(title: "Add Todo", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmCreateAction = UIAlertAction(title: "Add", style: .default) { action in
            guard let textField = alert.textFields?.first else {
                return
            }
            self.viewModel?.createNewTask(textField.text ?? "New Task")
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmCreateAction)
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        present(alert, animated: true)
    }
    
    private func bindViewModel() {
        viewModel?.onTodoMark = { [weak self] itemIdentifier, isMarked in
            if let cellIndex = self?.diffableDataSource?.indexPath(for: itemIdentifier),
               let cell = self?.collectionView.cellForItem(at: cellIndex) as? UICollectionViewListCell {
                cell.accessories = isMarked ? [.checkmark()] : []
            }
        }
        
        viewModel?.onItemsAdded = { [weak self] itemIdentifiers in
            self?.updateSnapShot(itemIdentifiers)
        }
        
        viewModel?.onCompleteCountUpdate = { [weak self] completedCount in
            self?.headerView?.update(tasksCount: completedCount)
        }
    }
    
    private func configureNavigationItems() {
        navigationItem.title = "My Todos"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapCreateTaskButton)
        )
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        configureDiffableDataSource()
        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource
        collectionView.collectionViewLayout = createListLayout()
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureDiffableDataSource() {
        let listCellRegistration = createListCellRegistration()
        let sectionHeaderRegistration = createSectionHeaderRegistration()
        let diffableDataSource = DiffableDataSource(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            
            collectionView.dequeueConfiguredReusableCell(
                using: listCellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }
        
        diffableDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: sectionHeaderRegistration,
                for: indexPath
            )
        }
        
        self.diffableDataSource = diffableDataSource
    }
    
    private func createSectionHeaderRegistration() -> UICollectionView.SupplementaryRegistration<SummaryHeaderView> {
        
        return .init(elementKind: UICollectionView.elementKindSectionHeader) {
            supplementaryView, elementKind, indexPath in
            
            self.headerView = supplementaryView
            if let completedCount = self.viewModel?.completedCount() {
                supplementaryView.update(tasksCount: completedCount)
            }
        }
    }
    
    private func createListLayout() -> UICollectionViewCompositionalLayout {
        let compositionalLayout = UICollectionViewCompositionalLayout { index, environment in
            let titleHeaderItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(44)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading
            )
            
            let listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            let listSection = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: environment)
            listSection.boundarySupplementaryItems = [titleHeaderItem]
            listSection.contentInsets.top = 4
            return listSection
        }
        return compositionalLayout
    }
    
    private func createListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, UUID> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let viewModel = self?.viewModel else {
                return
            }
            var content = cell.defaultContentConfiguration()
            content.text = viewModel.titleFor(itemIdentifier)
            cell.contentConfiguration = content
            cell.accessories = viewModel.isMarked(itemIdentifier) ? [.checkmark()] : []
        }
    }
    
    private func updateSnapShot(_ itemIdentifiers: [UUID]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapShot.appendSections([.todos])
        snapShot.appendItems(itemIdentifiers, toSection: .todos)
        diffableDataSource?.apply(snapShot)
    }
}

// MARK: UICollectionViewDelegate

extension TodoMarkingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itemIdentifier = diffableDataSource?.itemIdentifier(for: indexPath) {
            viewModel?.selectTodo(itemIdentifier)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
