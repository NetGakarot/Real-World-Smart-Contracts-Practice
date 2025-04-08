from ape import project,accounts

def main():
    
    admin = accounts.test_accounts[0]

    contract = project.Voting.deploy(sender=admin)

    print(f"Successfully deployed:{contract.address}")