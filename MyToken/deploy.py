from ape import accounts, project

def main():
    account = accounts.test_accounts[0]
    contract = project.MyToken.deploy(1_000_000, sender=account)
    print(f"✅ Deployed at: {contract.address}")