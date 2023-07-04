# WalletConnectSwiftUIV2
Plug and Play Library for Wallet Connect V2 SwiftUI

    import WalletConnectV2Swift

Add Packages to your SwiftUI: https://github.com/AakifNadeem/WalletConnectSwiftUIV2


Create an Instance:

    @State var walletConnect = WalletConnectView(projected: "//Your Project ID")

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
        
    .onChange(of: walletConnect.address, perform: { address in
        print("Wallet Address: ", address ?? "")
    })
