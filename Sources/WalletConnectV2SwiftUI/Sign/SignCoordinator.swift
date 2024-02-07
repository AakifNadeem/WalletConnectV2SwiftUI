import UIKit
import Combine
import WalletConnectSign
import WalletConnectRelay
import WalletConnectPairing

final class SignCoordinator {

    private var publishers = Set<AnyCancellable>()
    let navigationController = UINavigationController()


    func start() {
        let metadata = AppMetadata(
            name: "Navigate App",
            description: "WalletConnect to Navigate App",
            url: "https://nvg8.io",
            icons: ["https://nvg8.io/assets/Nvg8-Logo.svg"], 
            redirect:  AppMetadata.Redirect(native: "navigateExplore://", universal: nil)
        )

        Pair.configure(metadata: metadata)
#if DEBUG
        if CommandLine.arguments.contains("-cleanInstall") {
            try? Sign.instance.cleanup()
        }
#endif

        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink {_ in
//                showSelectChainScreen()
            }.store(in: &publishers)

        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print("Response: ", response)
            }.store(in: &publishers)

        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { session in
                print("\n\nAddress: ", session.accounts.first?.address ?? "", " \n\n\n")
            }.store(in: &publishers)

        if let session = Sign.instance.getSessions().first {
            print("\n\nSessions: ", session, " \n\n")
//            _ = showAccountsScreen(session)
        } else {
//            showSelectChainScreen()
        }
    }
}
