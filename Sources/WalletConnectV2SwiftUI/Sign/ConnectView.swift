//
//  ConnectView.swift
//  WalletConnectV2
//
//  Created by Aakif Nadeem on 03/07/2023.
//

import UIKit
import SwiftUI
import Combine
import Foundation
import WalletConnectModal
import Web3Modal
import Auth

public class WalletConnectView: ObservableObject {
    var requiredNamespaces: [String: ProposalNamespace] = [:]
    let optionalNamespaces: [String: ProposalNamespace] = [
        "eip155": ProposalNamespace(
            chains: [
                Blockchain("eip155:80001")!,        //Polygon Testnet
                Blockchain("eip155:421613")!        //Arbitrum Testnet
            ],
            methods: [
                "personal_sign"
            ], events: []
        )
    ]
    
    @Published public var account: [Account] = []
    @Published public var rejectedReason: String = ""
    var publishers = [AnyCancellable]()
    
    public init(projectId: String,
                name: String,
                description: String,
                url: String,
                icons: [String],
                groupIdentifier: String = "",
                redirect: String = "",
                supportedChainIds: [String: ProposalNamespace])
    {
        self.requiredNamespaces = supportedChainIds
        Networking.configure(groupIdentifier: groupIdentifier, projectId: projectId, socketFactory: DefaultSocketFactory())
        Auth.configure(crypto: DefaultCryptoProvider())
        
        let metaData = AppMetadata(
            name: name,
            description: description,
            url: url,
            icons: icons,
            redirect: AppMetadata.Redirect(native: redirect, universal: nil)
        ) 
        
        WalletConnectModal.configure(
            projectId: projectId,
            metadata: metaData
        )
        
        configureSignIn()
    }
    
    func configureSignIn() {
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { session in
                self.account = session.accounts
            }
            .store(in: &publishers)
        
        Sign.instance.sessionRejectionPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (session, reason) in
                self.rejectedReason = reason.message
            })
            .store(in: &publishers)
        
        Sign.instance.logsPublisher.sink { log in
            switch log {
            case .error(let logMessage):
                print(logMessage.message)
            default: return
            }
        }.store(in: &publishers)

        Sign.instance.socketConnectionStatusPublisher.sink { status in
            switch status {
            case .connected:
                print("Your web socket has connected")
            case .disconnected:
                print("Your web socket is disconnected")
            }
        }.store(in: &publishers)
    }
    
    public func connectWithWallet() {
        Task {
            WalletConnectModal.set(sessionParams: .init(
                requiredNamespaces: requiredNamespaces,
                optionalNamespaces: optionalNamespaces,
                sessionProperties: nil
            ))
            
            let _ = try await WalletConnectModal.instance.connect(topic: nil)
        }
        
        DispatchQueue.main.async {
            WalletConnectModal.present()
        }
    }
    
    public func connectWithSequence(onCompletion: @escaping (URL) -> Void) {
        Task {
            WalletConnectModal.set(sessionParams: .init(
                requiredNamespaces: requiredNamespaces,
                optionalNamespaces: optionalNamespaces,
                sessionProperties: nil
            ))
            let uri = try await WalletConnectModal.instance.connect(topic: nil)
            
            DispatchQueue.main.async {
                if let urlString = uri?.deeplinkUri, let url = URL(string: "https://sequence.app/wc?uri=\(urlString)") {
                    print("URL: ", url)
                    onCompletion(url)
//                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

class WebSocketFactoryMock: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        WebSocketMock()
    }
}

class WebSocketMock: WebSocketConnecting {
    var request: URLRequest = .init(url: URL(string: "wss://relay.walletconnect.com")!)

    var onText: ((String) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var sendCallCount: Int = 0
    var isConnected: Bool = false

    func connect() {}
    func disconnect() {}
    func write(string: String, completion: (() -> Void)?) {}
}

