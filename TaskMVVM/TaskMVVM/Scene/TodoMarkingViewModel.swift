//
//  TodoMarkingViewModel.swift
//  TaskMVVM
//
//  Copyright (c) 2025 Jeremy All rights reserved.
    

import Foundation

final class TodoMarkingViewModel {
    
    // MARK: Property(s)
    
    var onTodoMark: ((UUID, Bool) -> Void)?
    var onItemsAdded: (([UUID]) -> Void)?
    var onTodoCreate: ((UUID) -> Void)?
    var onCompleteCountUpdate: ((Int) -> Void)?
    
    private var identifiers: [Todo.ID] = []
    private var todoItems: [Todo.ID: Todo] = [:]
    
    private let todoStorage: TodoStorage
    
    init(todoStorage: TodoStorage) {
        self.todoStorage = todoStorage
    }
    
    // MARK: Function(s)
    
    func completedCount() -> Int {
        return todoItems.values.filter { !$0.isCompleted }.count
    }
    
    func needItems() {
        todoStorage.fetchTodos { [weak self] fetchedTodos in
            DispatchQueue.main.async {
                self?.addNewItems(fetchedTodos)
            }
        }
    }
    
    func createNewTask(_ todoTitle: String) {
        let createdTodoIdentifier = todoStorage.create(with: todoTitle)
        onItemsAdded?([createdTodoIdentifier])
        onCompleteCountUpdate?(completedCount())
    }
    
    func selectTodo(_ identifier: UUID) {
        guard var selectedItem = todoStorage.read(for: identifier) else {
            return
        }
        
        selectedItem.isCompleted = selectedItem.isCompleted ? false : true
        let isUpdated = todoStorage.update(selectedItem)
        
        if isUpdated {
            onTodoMark?(selectedItem.id, selectedItem.isCompleted)
        }
    }
    
    func titleFor(_ todoIdentifier: UUID) -> String? {
        return todoStorage.read(for: todoIdentifier)?.description
    }
    
    func isMarked(_ todoIdentifier: UUID) -> Bool {
        guard let item = todoStorage.read(for: todoIdentifier) else {
            return false
        }
        return item.isCompleted
    }
    
    // MARK: Private Function(s)
    
    private func addNewItems(_ newTodoItems: [Todo]) {
        let newItemIdentifiers = newTodoItems.map { $0.id }
        identifiers.append(contentsOf: newItemIdentifiers)
        newTodoItems.forEach { todoItems[$0.id] = $0 }
        onItemsAdded?(identifiers)
    }
}
