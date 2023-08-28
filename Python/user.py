import logging
from rich.prompt import Prompt
from rich.console import Console
from rich.table import Table
from rich.logging import RichHandler
from Utility.SmartContractUtility import SmartContractUtility
import os
from dotenv import load_dotenv

logging.basicConfig(level=logging.INFO, handlers=[RichHandler()])
logger = logging.getLogger("User")

load_dotenv()
console = Console()

class User:
    def __init__(self, selected_account):
        self.web3 = SmartContractUtility.web3_instance(os.getenv("RPCPROVIDERHOST") + ":"+ os.getenv("RPCPROVIDERPORT"))
        self.contract_address = os.getenv("CONTRACTADDRESS")
        self.contract_abi_path = os.getenv("CONTRACTABIPATH")
        self.contract_abi = SmartContractUtility.get_contract_abi(self.contract_abi_path)
        self.contract = SmartContractUtility.get_contract_instance(self.web3, self.contract_address, self.contract_abi)
        self.user_private_key = os.getenv(f"PRIVATEKEY"+str(selected_account))
        console.print(f"Contract instance obtained for contract at address {self.contract_address}", style="bold green")
    
    def call_contract_function(self, function_name, function_params, value=None, gas_limit=None, gas_price=None):
        SmartContractUtility.call_contract_function(self.web3, self.contract, function_name, function_params ,self.user_private_key, value, gas_limit, gas_price)

    def buy_ticket(self, function_params= None, value = 0, skip_check=False):
        if function_params is None:
            ticketId = Prompt.ask("Enter an unique id for the ticket you want to buy")
            dynamicSegmentsIds = iter(lambda: Prompt.ask("Enter a dynamic segment ID (or type 'done' to finish)"), 'done')
            value = int(Prompt.ask("Enter the value you want to pay for the ticket (in wei)", default=6000000000000000))
            function_params = [ticketId, list(dynamicSegmentsIds)]
        else:
            skip_check = True
        
        if skip_check or Prompt.ask(f"Are you sure you want to buy this ticket? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function("buyDynamicTicket", function_params, value)
                console.print(f"Ticket {function_params[0]} bought successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to buy ticket: {e}")
        else:
            console.print("Ticket not bought!", style="bold red")
    
"""
    def view_available_trains(self):
        # Display available trains, segments, and timings
        # This would require querying the blockchain for actual data.
        table = Table(title="Available Trains")
        table.add_column("Train ID")
        table.add_column("Segment")
        table.add_column("Timing")
        table.add_row("T1", "S1-S2", "10:00 AM")
        table.add_row("T2", "S2-S3", "02:00 PM")
        self.console.print(table)

    def buy_ticket(self):
        train_id = Prompt.ask("Enter the train ID you want to book")
        seat_pref = Prompt.ask("Seat Preference", choices=["window", "aisle"])
        # Execute smart contract method to buy ticket
        # Let's assume it's successful for this example
        self.console.print(
            f"Ticket booked for train {train_id} with {seat_pref} seat preference!", style="bold green")

    def cancel_ticket(self):
        ticket_id = Prompt.ask("Enter the ticket ID you want to cancel")
        # Execute smart contract method to cancel ticket
        # Let's assume it's successful for this example
        self.console.print(
            f"Ticket {ticket_id} cancelled successfully!", style="bold green")

    def set_arrival_time_and_check_refunds(self):
        # Fetch the necessary data
        dynamic_consecutive_segment_id = Prompt.ask(
            "Enter the dynamic consecutive segment ID")
        actual_arrival_time = Prompt.ask(
            "Enter the actual arrival time (UNIX timestamp)")

        # Execute the smart contract method to set the arrival time and check for refunds.
        # For simplicity, we'll assume the function is named 'setArrivalTimeAndCheckRefunds' in the smart contract.
        try:
            tx_hash = self.contract.functions.setArrivalTimeAndCheckRefunds(
                dynamic_consecutive_segment_id, int(actual_arrival_time)).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            if receipt['status'] == 1:
                self.console.print(
                    f"Arrival time set successfully for segment {dynamic_consecutive_segment_id}!", style="bold green")
            else:
                self.console.print(
                    f"Failed to set arrival time for segment {dynamic_consecutive_segment_id}!", style="bold red")
        except Exception as e:
            logger.error(f"Error setting arrival time: {str(e)}")
            self.console.print(
                f"Error setting arrival time: {str(e)}", style="bold red")
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
        "1": "Buy Ticket",
        "2": "View Available Trains",
        "3": "Buy Ticket",
        "4": "Cancel Ticket",
        "5": "Set arrival time and check refunds",
        "6": "Exit"
    }
    account_options = {}
    for i in range(1,10):
        account_options[i] = os.getenv(f"ADDRESS"+str(i))
        console.print(f"{i} - {account_options[i]}")
    selected_account = Prompt.ask("Choose your account", choices=[str(i) for i in range(1, 10)])
    console.clear()
    
    user = User(selected_account)

    while True:
        console.print(logo, style="bold blue")
        console.print("Welcome to [bold blue]User CLI[/bold blue]!", style="bold yellow")
        console.print("\n[bold green]Please choose an action:[/bold green]")
        for key, value in options.items():
            console.print(f"{key}. {value}")
        
        
        try:
            choice = Prompt.ask("Enter your choice", choices=list(options.keys()))
        except Exception:
            console.print("Invalid choice!", style="bold red")
            continue
    
        if choice == "1":
            user.buy_ticket()
        elif choice == "2":
            user.view_available_trains()
        elif choice == "3":
            user.buy_ticket()
        elif choice == "4":
            user.cancel_ticket()
        elif choice == "5":
            user.set_arrival_time_and_check_refunds()
        elif choice == "6":
            console.print("Goodbye!", style="bold red")
            break
        
        input()
        console.clear()


if __name__ == '__main__':
    main()
