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
    @Published public var account: [Account] = []
    
    public init(projectId: String,
                name: String,
                description: String,
                url: String,
                icons: [String])
    {
        Networking.configure(projectId: projectId, socketFactory: DefaultSocketFactory())
        
        let metaData = AppMetadata(
            name: name,
            description: description,
            url: url,
            icons: icons
        )
        
        WalletConnectModal.configure(projectId: projectId, metadata: metaData)
        configure(metaData: metaData)
    }
    
    func configure(metaData: AppMetadata) {
        Pair.configure(metadata: metaData)
        
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print("Delete Publisher: ", response)
            }.store(in: &publishers)
        
        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print("Response Publisher: ", response)
            }.store(in: &publishers)
        
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { session in
                self.account = session.accounts
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
            let uri = try await WalletConnectModal.instance.connect(topic: nil)
            
            DispatchQueue.main.async {
                if let urlString = uri?.deeplinkUri, let url = URL(string: "https://sequence.app/wc?uri=\(urlString)") {
                    print("URL: ", url)
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}
