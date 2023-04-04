//
//  RequestifyApp.swift
//  Requestify
//
//  Created by Kari on 4/4/23.
//

import SwiftUI

@main
struct RequestifyApp: App {
    @StateObject var spotifyController = SpotifyController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    spotifyController.setAccessToken(from: url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification)) { _ in
                    spotifyController.connect()
                }
        }
    }
}
