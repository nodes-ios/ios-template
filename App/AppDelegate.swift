//
//  AppDelegate.swift
//  InStoreApp
//
//  Created by Jakob Mygind on 15/11/2021.
//

import APIClientLive
import AppFeature
import Combine
import Localizations
import PersistenceClient
import Style
import SwiftUI

@main
final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        return true
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var localizations: ObservableLocalizations = .init(.bundled)
    var tokenCancellable: AnyCancellable?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: scene)

        self.setupNStack()
        self.registerFonts()
        self.startAppView()
    }
}

// MARK: - Dependencies setup

extension SceneDelegate {

    /// Allows using project specific fonts int the same way you use any of the iOS-provided fonts.
    /// Custom fonts should be located on the `Style`.
    fileprivate func registerFonts() {
        CustomFonts.registerCustomFonts()
    }

    /// Handles setup of [NStack](https://nstack.io) services.
    /// This example demonstrates [Localization](https://nstack-io.github.io/docs/docs/features/localize.html) service activation.
    fileprivate func setupNStack() {
        localizations = startNStackSDK(
            appId: <#appID#>,
            restAPIKey: <#restAPIKey#>
        )
    }

    /// Defines content view of the window assigned to the scene with the required dependencies.
    /// This is the entry point for the app which defines the source of truth for related environment settings.
    fileprivate func startAppView() {
        let baseURL = Configuration.API.baseURL

        let persistenceClient = PersistenceClient.live(keyPrefix: Bundle.main.bundleIdentifier!)

        let authHandler = AuthenticationHandler(
            refreshURL: <#refreshURL#>,
            tokens: persistenceClient.tokens.load()
        )
        tokenCancellable = authHandler.tokenUpdatePublisher.sink(
            receiveValue: persistenceClient.tokens.save)

        let environment = AppEnvironment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            apiClient: .live(baseURL: baseURL, authenticationHandler: authHandler),
            date: Date.init,
            calendar: .autoupdatingCurrent,
            localizations: localizations,
            appVersion: .live,
            persistenceClient: persistenceClient,
            tokenUpdatePublisher: authHandler.tokenUpdatePublisher.eraseToAnyPublisher(),
            networkMonitor: .live(queue: .main)
        )

        let apiEnvironments = Configuration.API.environments

        let vm = AppViewModel(environment: environment)
        #if RELEASE
            let appView = AppView(viewModel: vm)
                .environmentObject(localizations)
        #else
            let appView = AppView(viewModel: vm)
                .environmentObject(localizations)
                .environment(\.apiEnvironments, apiEnvironments)
        #endif

        self.window?.rootViewController = UIHostingController(rootView: appView)
        self.window?.makeKeyAndVisible()
    }
}
