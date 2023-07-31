# Wallet Connect V2 SwiftUI
Plug and Play Library for Wallet Connect V2 SwiftUI

    import WalletConnectV2Swift

Add Packages to your SwiftUI: https://github.com/AakifNadeem/WalletConnectV2SwiftUI


Create an Instance:

    @StateObject var walletConnect = WalletConnectView(
                                                projectId: "1234123123",
                                                name: "App",
                                                description: "WalletConnect to App",
                                                url: "www.walletconnect.com",
                                                icons: [""],
                                                supportedChainIds: [
                                                "eip155": ProposalNamespace(
                                                    chains: [
                                                        Blockchain("eip155:137")!
                                                    ],
                                                    methods: [
                                                        "personal_sign"
                                                    ], events: []
                                                )])
Call to get all Wallets Listing:

    Button {
         walletConnect.connectWithWallet()
    } label: {
         Text("Connect To Wallet")
    }

![IMG_34D7DB59C9A9-1](https://github.com/AakifNadeem/WalletConnectV2SwiftUI/assets/58801997/98b43d74-f7a4-4f91-b993-1e7b3d862f45)


Additional Call to connect to Sequence Wallet:

    Button {
         walletConnect.connectWithSequence()
    } label: {
         Text("Connect To Wallet")
    }

Get Your Required Wallet Address: 

    .onChange(of: walletConnect.account, perform: { accounts in
            print("Wallet Address: ", accounts.first?.address ?? "")
    })

Get Rejected Reason: 
    
    .onChange(of: walletConnect.rejectedReason, perform: { reason in
            print("Wallet Connection Error", reason)
        })
