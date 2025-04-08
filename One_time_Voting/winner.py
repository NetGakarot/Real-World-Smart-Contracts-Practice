from ape import project,accounts

def main():

    contract = project.Voting.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    winner = contract.selectWinner(sender=contract.owner())
    for i in contract.getWinners():
        print(f"Winner: {contract.candidates(i).name}")

