# Wallet Connect V2 SwiftUI
Plug and Play Library for Wallet Connect V2 SwiftUI

    import WalletConnectV2Swift

Add Packages to your SwiftUI: https://github.com/AakifNadeem/WalletConnectSwiftUIV2


Create an Instance:

    @State var walletConnect = WalletConnectView(
                                                projectId: "",
                                                name: "App",
                                                description: "WalletConnect to App",
                                                url: "www.walletconnect.com",
                                                icons: [""])
Call to get all Wallets Listing:

    Button {
         walletConnect.connectWithWallet()
    } label: {
         Text("Connect To Wallet")
    }

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
