from ape import accounts, project

def main():

    contract = project.MyToken.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    _sender = accounts.test_accounts[1]
    spender = accounts.test_accounts[2]
    amount = 5

    inc_allowance = contract.increaseAllowance(spender,amount,sender=_sender)
    print(f"Allowance of {spender}:{contract.allowance(_sender,spender)}")
    