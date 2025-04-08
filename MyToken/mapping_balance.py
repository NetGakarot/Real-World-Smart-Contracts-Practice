from ape import accounts, project

def main():

    user1 = accounts.test_accounts[1]
    user2 = accounts.test_accounts[2]
    user3 = accounts.test_accounts[3]
    user4 = accounts.test_accounts[4]
    user5 = accounts.test_accounts[5]

    user_list = [user1,user2,user3,user4,user5]

    contract = project.MyToken.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    for user in user_list:
        print(f"Balance of {user}:{contract.balanceOf(user)}")