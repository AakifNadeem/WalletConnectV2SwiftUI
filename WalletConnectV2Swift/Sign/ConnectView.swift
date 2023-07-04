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


public class WalletConnectView: ObservableObject {
    var namespaces: [String: ProposalNamespace] = [
        "eip155": ProposalNamespace(
            chains: [
                Blockchain("eip155:80001")!,
//                Blockchain("eip155:421613")!
            ],
            methods: [
//                "eth_sendTransaction",
                "personal_sign",
//                "eth_signTypedData"
            ], events: []
        )
    ]
    
    var publishers = [AnyCancellable]()
    
    @Published public var address: String?
    @Published public var uri : WalletConnectURI?
    @Published var viewController: UIViewController?
    
    public init(projectId: String) {
        Networking.configure(projectId: projectId, socketFactory: DefaultSocketFactory())
        let metadata = AppMetadata(
            name: "Swift Dapp",
            description: "WalletConnect DApp sample",
            url: "wallet.connect",
            icons: ["https://avatars.githubusercontent.com/u/37784886"]
        )
        
        WalletConnectModal.configure(projectId: projectId, metadata: metadata)
        
        start()
    }
    
    func start() {
        let metadata = AppMetadata(
            name: "Navigate App",
            description: "WalletConnect to Navigate App",
            url: "https://nvg8.io",
            icons: ["https://nvg8.io/assets/Nvg8-Logo.svg"]
        )
        
        Pair.configure(metadata: metadata)
        
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
            }.store(in: &publishers)
        
        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
            }.store(in: &publishers)
        
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { session in
                print("\n\nAddress: ", session.accounts.first?.address ?? "", " \n\n\n")
            }.store(in: &publishers)
    }
    
    public func connectWithWallet() {
        Task {
            WalletConnectModal.set(sessionParams: .init(
                requiredNamespaces: namespaces,
                optionalNamespaces: nil,
                sessionProperties: nil
            ))
            
            let _ = try await WalletConnectModal.instance.connect(topic: nil)
        }
        
        DispatchQueue.main.async {
            WalletConnectModal.present()
        }
    }
    
    public func connectWithSequence() {
        Task {
            WalletConnectModal.set(sessionParams: .init(
                requiredNamespaces: namespaces,
                optionalNamespaces: nil,
                sessionProperties: nil
            ))
            uri = try await WalletConnectModal.instance.connect(topic: nil)
            
            DispatchQueue.main.async {
                if let urlString = self.uri?.deeplinkUri, let url = URL(string: "https://sequence.app/wc?uri=\(urlString)") {
                    print("URL: ", url)
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}
