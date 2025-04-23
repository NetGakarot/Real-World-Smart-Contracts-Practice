from ape import accounts, project

def main():
    account = accounts.test_accounts[0]

    logic = project.V2.deploy(sender=account)
    print(f"Logic (BoxV2) deployed at: {logic.address}")

    proxy = project.P2.deploy(sender=account)
    print(f"Proxy (P2) deployed at: {proxy.address}")

    proxy.setImplementation(logic.address, sender=account)

    logic_proxy = project.V2.at(proxy.address)

    logic_proxy.setNumber(42, sender=account)
    print("Number set via proxy.")

    print(f"Number (in proxy): {proxy.number()}",sender=account)
    print(f"Number (via proxy): {logic_proxy.getNumber()}",sender=account)
