from ape import accounts, project

def main():

    contract = project.MyToken.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    owner = contract.owner()
    new_owner = accounts.test_accounts[1]

    transfer_owner = contract.transferOwnership(new_owner,sender=owner)
    print(f"Old owner:{owner}")
    print(f"New owner:{contract.owner()}")