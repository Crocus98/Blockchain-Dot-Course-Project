import logging
from rich.console import Console
from rich.prompt import Prompt
from rich.logging import RichHandler
from web3 import Web3
from dotenv import load_dotenv, find_dotenv
import os
from Utility.SmartContractUtility import SmartContractUtility

logging.basicConfig(level=logging.INFO, handlers=[RichHandler()])
logger = logging.getLogger(__name__)

load_dotenv()
console = Console()

class Company:

    def __init__(self):
        self.web3 = SmartContractUtility.web3_instance(os.getenv("RPCPROVIDERHOST") + ":"+ os.getenv("RPCPROVIDERPORT"))
        self.dot_env_path = find_dotenv()
        self.contract_address = os.getenv("CONTRACTADDRESS")
        self.contract_abi_path = os.getenv("CONTRACTABIPATH")
        self.contract_bytecode_path = os.getenv("CONTRACTBYTECODEPATH")
        self.contract_source_path = os.getenv("CONTRACTSOURCEPATH")
        self.company_private_key = os.getenv("PRIVATEKEY0")
        self.contract_name = os.getenv("CONTRACTNAME")
    
        if self.contract_address:
            self.contract_abi = SmartContractUtility.get_contract_abi(self.contract_abi_path)
            self.contract_source_code = SmartContractUtility.get_contract_source_code(self.contract_source_path)
            self.contract_bytecode = SmartContractUtility.get_contract_bytecode(self.contract_bytecode_path)
        else:
            self.contract_source_code, self.contract_abi, self.contract_bytecode = SmartContractUtility.compile_contract(self.web3, self.contract_source_path, self.contract_abi_path, self.contract_bytecode_path, self.contract_name)
            self.contract_address = SmartContractUtility.deploy_contract(self.web3, self.contract_abi, self.contract_bytecode, self.company_private_key)
            SmartContractUtility.set_contract_address_in_env(self.contract_address, self.dot_env_path)
            console.print(f"Contract deployed at address {self.contract_address}", style="bold green")

        self.contract = SmartContractUtility.get_contract_instance(self.web3, self.contract_address, self.contract_abi)
        console.print(f"Contract instance obtained for contract at address {self.contract_address}", style="bold green")

""""
    def confirm_train_arrival(self):
        train_id = Prompt.ask("Inserisci l'ID del treno")
        dynamic_consecutive_segment_id = Prompt.ask(
            "Inserisci l'ID del segmento consecutivo dinamico")

        is_delayed = random.random() < 0.3

        if is_delayed:
            console.print(
                f"Il treno {train_id} è in ritardo!", style="bold red")
            actual_arrival_time = Prompt.ask(
                "Inserisci l'orario di arrivo effettivo (timestamp UNIX)", int)
            try:
                self.contract.functions.setArrivalTimeAndCheckRequiredRefunds(
                    dynamic_consecutive_segment_id, actual_arrival_time).transact({"from": self.web3.eth.defaultAccount})
                logger.info(f"Transazione completata per il treno {train_id}")
            except Exception as e:
                logger.error(f"Errore nella transazione: {e}")
        else:
            console.print(
                f"Il treno {train_id} è arrivato in orario!", style="bold green")

    def insert_sample_data(self):
        console.print("Inserimento dati di esempio...", style="bold yellow")
        try:
            self.contract.functions.addTrain("T1", "Express", 300).transact(
                {"from": self.web3.eth.defaultAccount})
            self.contract.functions.addStation("S1").transact(
                {"from": self.web3.eth.defaultAccount})
            self.contract.functions.addStation("S2").transact(
                {"from": self.web3.eth.defaultAccount})
            self.contract.functions.addConsecutiveSegment("CS1", "T1", "S1", "S2", int(
                time.time()) + 3600, 50).transact({"from": self.web3.eth.defaultAccount})
            self.contract.functions.addDynamicConsecutiveSegment(
                "DCS1", "CS1").transact({"from": self.web3.eth.defaultAccount})
            self.contract.functions.addDynamicSegment("DS1").transact(
                {"from": self.web3.eth.defaultAccount})
            self.contract.functions.addDynamicConsecutiveSegmentToDynamicSegment(
                "DS1", "DCS1", False).transact({"from": self.web3.eth.defaultAccount})
            console.print("Dati di esempio inseriti.", style="bold green")
        except Exception as e:
            logger.error(f"Errore nell'inserimento dei dati di esempio: {e}")

    def add_train(self):
        name = Prompt.ask("Enter the train name")
        description = Prompt.ask("Enter the train description")
        max_passengers = Prompt.ask("Enter the max passengers", int)
        if Prompt.ask("Are you sure you want to add this train? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.contract.functions.addTrain(name, description, max_passengers).transact({
                    "from": self.web3.eth.defaultAccount})
                console.print(
                    f"Train {name} added successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to add train: {e}")

    def add_station(self):
        station_id = Prompt.ask("Enter the station ID")
        if Prompt.ask("Are you sure you want to add this station? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.contract.functions.addStation(station_id).transact(
                    {"from": self.web3.eth.defaultAccount})
                console.print(
                    f"Station {station_id} added successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to add station: {e}")

    def add_consecutive_segment(self):
        segment_id = Prompt.ask("Enter the consecutive segment ID")
        train_id = Prompt.ask("Enter the train ID")
        starting_station_id = Prompt.ask("Enter the starting station ID")
        arriving_station_id = Prompt.ask("Enter the arriving station ID")
        arrival_time = Prompt.ask(
            "Enter the arrival time (UNIX timestamp)", int)
        price = Prompt.ask("Enter the price", int)

        if Prompt.ask(f"Are you sure you want to add this consecutive segment {segment_id}? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.contract.functions.addConsecutiveSegment(
                    segment_id, train_id, starting_station_id, arriving_station_id, arrival_time, price).transact({"from": self.web3.eth.defaultAccount})
                console.print(
                    f"Consecutive Segment {segment_id} added successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to add consecutive segment: {e}")

    def add_dynamic_consecutive_segment(self):
        dynamic_consecutive_segment_id = Prompt.ask(
            "Enter the dynamic consecutive segment ID")
        consecutive_segment_id = Prompt.ask("Enter the consecutive segment ID")

        if Prompt.ask(f"Are you sure you want to add this dynamic consecutive segment {dynamic_consecutive_segment_id}? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.contract.functions.addDynamicConsecutiveSegment(
                    dynamic_consecutive_segment_id, consecutive_segment_id).transact({"from": self.web3.eth.defaultAccount})
                console.print(
                    f"Dynamic Consecutive Segment {dynamic_consecutive_segment_id} added successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to add dynamic consecutive segment: {e}")

    def add_dynamic_segment(self):
        dynamic_segment_id = Prompt.ask("Enter the dynamic segment ID")
        if Prompt.ask("Are you sure you want to add this dynamic segment? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.contract.functions.addDynamicSegment(dynamic_segment_id).transact(
                    {"from": self.web3.eth.defaultAccount})
                console.print(
                    f"Dynamic Segment {dynamic_segment_id} added successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to add dynamic segment: {e}")

    def add_dynamic_consecutive_segment_to_dynamic_segment(self):
        dynamic_segment_id = Prompt.ask("Enter the dynamic segment ID")
        dynamic_consecutive_segment_id = Prompt.ask(
            "Enter the dynamic consecutive segment ID")
        last_segment_stop = Prompt.ask(
            "Is this the last segment stop? [yes/no]", choices=["yes", "no"]) == "yes"

        if Prompt.ask(f"Are you sure you want to add dynamic consecutive segment {dynamic_consecutive_segment_id} to dynamic segment {dynamic_segment_id}? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.contract.functions.addDynamicConsecutiveSegmentToDynamicSegment(
                    dynamic_segment_id, dynamic_consecutive_segment_id, last_segment_stop).transact({"from": self.web3.eth.defaultAccount})
                console.print(
                    f"Dynamic Consecutive Segment {dynamic_consecutive_segment_id} added to Dynamic Segment {dynamic_segment_id} successfully!", style="bold green")
            except Exception as e:
                logger.error(
                    f"Failed to add dynamic consecutive segment to dynamic segment: {e}")

    def list_all_users(self):
        # For simplicity, let's assume the contract has a function to list all users (addresses)
        try:
            users = self.contract.functions.listAllUsers().call()
            if len(users) == 0:
                console.print("No users found!", style="bold red")
            else:
                console.print("List of all users:", style="bold green")
                for user in users:
                    console.print(user, style="bold blue")
            return users
        except Exception as e:
            logger.error(f"Failed to list all users: {e}")
            return []

    def list_blacklisted_users(self):
        # Assuming the contract has a function to list all blacklisted users (addresses)
        try:
            blacklisted_users = self.contract.functions.listBlacklistedUsers().call()
            if len(blacklisted_users) == 0:
                console.print("No blacklisted users found!", style="bold red")
            else:
                console.print("List of blacklisted users:", style="bold green")
                for user in blacklisted_users:
                    console.print(user, style="bold blue")
            return blacklisted_users
        except Exception as e:
            logger.error(f"Failed to list blacklisted users: {e}")
            return []

    def add_user_to_blacklist(self):
        users = self.list_all_users()
        user_to_blacklist = Prompt.ask(
            "Enter the address of the user you want to blacklist", choices=users)
        if Prompt.ask(f"Are you sure you want to blacklist user {user_to_blacklist}? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.contract.functions.addUserToBlacklist(user_to_blacklist).transact({
                    "from": self.web3.eth.defaultAccount})
                console.print(
                    f"User {user_to_blacklist} added to blacklist successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to add user to blacklist: {e}")

    def remove_user_from_blacklist(self):
        blacklisted_users = self.list_blacklisted_users()
        user_to_remove = Prompt.ask(
            "Enter the address of the user you want to remove from blacklist", choices=blacklisted_users)
        if Prompt.ask(f"Are you sure you want to remove user {user_to_remove} from the blacklist? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.contract.functions.removeUserFromBlacklist(user_to_remove).transact({
                    "from": self.web3.eth.defaultAccount})
                console.print(
                    f"User {user_to_remove} removed from blacklist successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to remove user from blacklist: {e}")

    # ... Other methods se necessari savageee ...
"""

def main():
    logo = """
  /$$$$$$ /$$               /$$                 /$$$$$$$$                 /$$                    
|_  $$_/| $$              | $$                |__  $$__/                |__/                    
  | $$ /$$$$$$    /$$$$$$ | $$ /$$   /$$         | $$  /$$$$$$  /$$$$$$  /$$ /$$$$$$$   /$$$$$$$
  | $$|_  $$_/   |____  $$| $$| $$  | $$         | $$ /$$__  $$|____  $$| $$| $$__  $$ /$$_____/
  | $$  | $$      /$$$$$$$| $$| $$  | $$         | $$| $$  \__/ /$$$$$$$| $$| $$  \ $$|  $$$$$$ 
  | $$  | $$ /$$ /$$__  $$| $$| $$  | $$         | $$| $$      /$$__  $$| $$| $$  | $$ \____  $$
 /$$$$$$|  $$$$/|  $$$$$$$| $$|  $$$$$$$         | $$| $$     |  $$$$$$$| $$| $$  | $$ /$$$$$$$/
|______/ \___/   \_______/|__/ \____  $$         |__/|__/      \_______/|__/|__/  |__/|_______/ 
                               /$$  | $$                                                        
                              |  $$$$$$/                                                        
                               \______/  
                                            o  o  O  O
                                        ,_____  ____    O
                                        | G V \_|[]|_'__Y
                                        |_M_S___|__|_|__|}
=========================================oo--oo==oo--OOO\\======================================
    """
    options = {
        "1": "Add Train",
        "2": "Add Station",
        "3": "Add Consecutive Segment",
        "4": "Add Dynamic Consecutive Segment",
        "5": "Add Dynamic Segment",
        "6": "Aggiungi un segmento consecutivo dinamico a un segmento dinamico",
        "7": "Conferma l'arrivo del treno",
        "8": "Inserisci dati di esempio",
        "9": "Aggiungi un utente alla blacklist",
        "10": "Rimuovi un utente dalla blacklist",
        "11": "Exit"
    }
    company = Company()

    while True:
        console.print(logo, style="bold blue")
        console.print("Welcome to [bold blue]Company CLI[/bold blue]!", style="bold red")
        console.print("\n[bold green]Please choose an action:[/bold green]")
        for key, value in options.items():
            console.print(f"{key}. {value}")
            
        try:
            choice = Prompt.ask("Enter your choice", choices=list(options.keys()))
        except Exception:
            console.print("Invalid choice!", style="bold red")
            continue

        if choice == "1":
            company.add_train()
        elif choice == "2":
            company.add_station()
        elif choice == "3":
            company.add_consecutive_segment()
        elif choice == "4":
            company.add_dynamic_consecutive_segment()
        elif choice == "5":
            company.add_dynamic_segment()
        elif choice == "6":
            company.add_dynamic_consecutive_segment_to_dynamic_segment()
        elif choice == "7":
            company.confirm_train_arrival()
        elif choice == "8":
            company.insert_sample_data()
        elif choice == "9":
            company.add_user_to_blacklist()
        elif choice == "10":
            company.remove_user_from_blacklist()
        elif choice == "11":
            console.print("Goodbye!", style="bold red")
            break
        
        console.clear()
        

# Run the main function only if this file is being run directly (not imported from another file)
if __name__ == "__main__":
    main()
