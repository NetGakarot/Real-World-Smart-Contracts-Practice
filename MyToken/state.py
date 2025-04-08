from ape import project, accounts

def main():
    account = accounts.test_accounts[0]

    deployed_address = "0x5FbDB2315678afecb367f032d93F642f64180aa3"

    contract = project.MyToken.at(deployed_address)

    print(f"Project Name:{contract.name()}")
    print(f"Project Symbol:{contract.symbol()}")
    print(f"Decimal Factor:{contract.decimals()}")
    print(f"Total Supply:{contract.totalSupply()}")
    print(f"Contract Owner:{contract.owner()}")


