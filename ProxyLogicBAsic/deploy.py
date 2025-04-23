from ape import accounts, project

def main():
    account = accounts.test_accounts[0]

    # Deploy Logic contract
    logic = project.Logic.deploy(sender=account)
    print(f"Logic contract deployed at: {logic.address}")

    proxy = project.Proxy.deploy(sender=account)
    print(f"Proxy contract deployed at: {proxy.address}")

    proxy.setVars(logic.address,444, sender=account)
    print("Value set via Proxy contract.")

    print(proxy.num())