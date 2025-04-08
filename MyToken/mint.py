from ape import accounts, project

def main():

    contract = project.MyToken.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    _sender = contract.owner()

    amount = 300

    print(f"Total supply before mint:{contract.totalSupply()}")
    print(f"Balance of owner before mint:{contract.balanceOf(_sender)}")

    burn = contract.mint(amount,sender=_sender)

    print(f"Total supply after mint:{contract.totalSupply()}")
    print(f"Balance of owner after mint:{contract.balanceOf(_sender)}")