from ape import accounts, project

def main():

    contract = project.MyToken.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    _sender = accounts.test_accounts[0]
    receiver = accounts.test_accounts[1]
    amount = 20
    print(f"Balance of sender before tx:{contract.balanceOf(_sender)}$Gak")
    print(f"Balance of receiver before tx:{contract.balanceOf(receiver)}$Gak")

    transfer = contract.transfer(receiver,amount,sender=_sender)

    print(f"Tx successfull of amount:{amount}$Gak")
    print(f"Balance of sender after tx:{contract.balanceOf(_sender)}$Gak")
    print(f"Balance of receiver after tx:{contract.balanceOf(receiver)}$Gak")