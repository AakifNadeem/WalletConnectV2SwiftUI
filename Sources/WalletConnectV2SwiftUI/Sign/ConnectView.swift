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
                supportedChainIds: [String: ProposalNamespace])
    {
        self.requiredNamespaces = supportedChainIds
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
