from ape import project,accounts

def main():

    contract = project.Voting.at("0x5FbDB2315678afecb367f032d93F642f64180aa3")

    _sender = contract.owner()

    name = "Couple"

    add_candidate = contract.addCandidate(name,sender= _sender)
    print("Candidate added successfully")
    print(f"Candidate Total Count:{contract.candidatesCount()}")