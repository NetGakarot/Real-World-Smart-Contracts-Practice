from ape import project,accounts

def main():

    contract = project.Voting.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    user1 = accounts.test_accounts[1]
    user2 = accounts.test_accounts[2]
    user3 = accounts.test_accounts[3]
    user4 = accounts.test_accounts[4]
    user5 = accounts.test_accounts[5]
    user6 = accounts.test_accounts[6]
    user7 = accounts.test_accounts[7]

    candidate_ID = 2

    contract = contract.vote(candidate_ID,sender=user6)
    print("Voted successfully")