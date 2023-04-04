//
//  SpotifyController.swift
//  Requestify
//
//  Created by Kari on 4/4/23.
//

import SwiftUI
import SpotifyiOS
import Combine

class SpotifyController: NSObject, ObservableObject {
    let spotifyClientID = "a7938278aa964823b0a57c187f434474"
    let spotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    
    var accessToken: String? = nil
    
    var playURI = ""
        
        private var connectCancellable: AnyCancellable?
        
        private var disconnectCancellable: AnyCancellable?
        
        override init() {
            super.init()
            connectCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.connect()
                }
            
            disconnectCancellable = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.disconnect()
                }

        }
            
        lazy var configuration = SPTConfiguration(
            clientID: spotifyClientID,
            redirectURL: spotifyRedirectURL
        )

        lazy var appRemote: SPTAppRemote = {
            let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
            appRemote.connectionParameters.accessToken = self.accessToken
            appRemote.delegate = self
            return appRemote
        }()
        
        func setAccessToken(from url: URL) {
            let parameters = appRemote.authorizationParameters(from: url)
            
            if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
                appRemote.connectionParameters.accessToken = accessToken
                self.accessToken = accessToken
            } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
                print(errorDescription)
            }
            
        }
        func connect() {
          self.appRemote.authorizeAndPlayURI(self.playURI)
        }

        
        func disconnect() {
            if appRemote.isConnected {
                appRemote.disconnect()
            }
        }
        func applicationWillResignActive(_ application: UIApplication) {
          if self.appRemote.isConnected {
            self.appRemote.disconnect()
          }
        }
    
        func applicationDidBecomeActive(_ application: UIApplication) {
          if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
          }
        }


    }

    extension SpotifyController: SPTAppRemoteDelegate {
        func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
          // Connection was successful, you can begin issuing commands
          self.appRemote.playerAPI?.delegate = self
          self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
              debugPrint(error.localizedDescription)
            }
          })
        }

        
        func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
            print("failed")
        }
        
        func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
            print("disconnected")
        }
    }

    extension SpotifyController: SPTAppRemotePlayerStateDelegate {
        func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
          debugPrint("Track name: %@", playerState.track.name)
        }

    }
