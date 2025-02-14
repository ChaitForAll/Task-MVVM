//
//  TodoStorage.swift
//  TaskMVVM
//
//  Copyright (c) 2025 Jeremy All rights reserved.
    

import Foundation

struct Todo: Identifiable {
    let id: UUID = .init()
    let description: String
    var isCompleted: Bool = false
}

protocol TodoStorage {
    func create(with todoTitle: String) -> UUID
    func read(for todoIdentifier: UUID) -> Todo?
    func update(_ updatedTodo: Todo) -> Bool
    func delete(_ toDeleteIdentifier: UUID) -> Bool
    func fetchTodos(_ completion: @escaping ([Todo]) -> Void)
}

final class TodoStorageImplementation: TodoStorage {
    
    // MARK: Property(s)
    
    private var todoCache: [Todo.ID: Todo] = [:]
    
    // MARK: Function(s)
    
    func create(with todoTitle: String) -> UUID {
        let newTodo = Todo(description: todoTitle)
        storeCache(newTodo)
        return newTodo.id
    }
    
    func read(for todoIdentifier: UUID) -> Todo? {
        return todoCache[todoIdentifier]
    }
    
    func update(_ updatedTodo: Todo) -> Bool {
        let updatedTodo = todoCache.updateValue(updatedTodo, forKey: updatedTodo.id)
        return updatedTodo == nil ? false : true
    }
    
    func delete(_ toDeleteIdentifier: UUID) -> Bool {
        let removedTodo = todoCache.removeValue(forKey: toDeleteIdentifier)
        return removedTodo == nil ? false : true
    }
    
    func fetchTodos(_ completion: @escaping ([Todo]) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let todos = [
                Todo(description: "Write Essay"),
                Todo(description: "Buy groceries"),
                Todo(description: "Workout"),
                Todo(description: "SpaceX Research"),
                Todo(description: "Prepare for scrum"),
                Todo(description: "Do laundry"),
                Todo(description: "Book a nice hotel in Tokyo")
            ]
            todos.forEach { self.todoCache[$0.id] = $0 }
            completion(todos)
        }
    }
    
    private func storeCache(_ todo: Todo) {
        todoCache.updateValue(todo, forKey: todo.id)
    }
}
