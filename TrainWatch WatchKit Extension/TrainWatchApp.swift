//
//  TrainWatchApp.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 29.12.21.
//

import SwiftUI

@main
struct TrainWatchApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
