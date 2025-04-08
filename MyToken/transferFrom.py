from ape import accounts, project

def main():

    contract = project.MyToken.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    owner = accounts.test_accounts[1]
    spender = accounts.test_accounts[2]
    receiver = accounts.test_accounts[4]
    amount = 1
    
    print(f"Balanceof receiver:{contract.balanceOf(receiver)}")
    transferFrom = contract.transferFrom(owner,receiver,amount,sender=spender)
    print(f"Balanceof receiver:{contract.balanceOf(receiver)}")