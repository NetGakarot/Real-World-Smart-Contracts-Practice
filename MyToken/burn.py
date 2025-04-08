from ape import accounts, project

def main():

    contract = project.MyToken.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    _sender = contract.owner()

    amount = 30

    print(f"Total supply before burn:{contract.totalSupply()}")
    print(f"Balance of owner before burn:{contract.balanceOf(_sender)}")

    burn = contract.burn(amount,sender=_sender)

    print(f"Total supply after burn:{contract.totalSupply()}")
    print(f"Balance of owner after burn:{contract.balanceOf(_sender)}")