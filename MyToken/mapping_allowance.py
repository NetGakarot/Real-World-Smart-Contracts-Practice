from ape import accounts, project

def main():

    approver = accounts.test_accounts[0]
    spender = accounts.test_accounts[1]
    

    contract = project.MyToken.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    print(f"Allowance of {spender}:{contract.allowance(approver,spender)}")