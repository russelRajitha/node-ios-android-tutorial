//
//  EcommerceAppApp.swift
//  EcommerceApp
//
//  Created by Russel Rajitha  on 2026-05-17.
//
import SwiftData
import SwiftUI

@main
struct EcommerceAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container.modelContainer)
        }
    }
}
