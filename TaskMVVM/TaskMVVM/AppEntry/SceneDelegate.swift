//
//  SceneDelegate.swift
//  TaskMVVM
//
//  Copyright (c) 2025 Jeremy All rights reserved.
    

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: Property(s)
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let rootViewController = TodoMarkingViewController()
        let viewModel = TodoMarkingViewModel(todoStorage: TodoStorageImplementation())
        rootViewController.viewModel = viewModel
        let window = UIWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        window.rootViewController = UINavigationController(rootViewController: rootViewController)
        self.window = window
    }
}

