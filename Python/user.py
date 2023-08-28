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
            function_params = [ticketId, list(dynamicSegmentsIds)]
            value = int(Prompt.ask("Enter the value you want to pay for the ticket (in wei)", default=12000000000000000))
        else:
            skip_check = True
        
        if skip_check or Prompt.ask(f"Are you sure you want to buy this ticket? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function("buyDynamicTicket", function_params, value=value, gas_limit=500000)
                console.print(f"Ticket {function_params[0]} bought successfully!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to buy ticket: {e}")
        else:
            console.print("Ticket not bought!", style="bold red")
        
    def collect_refunds_money (self) :
        if Prompt.ask(f"Are you sure you want to collect all your refunds moeny? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function("getRefund", [])
                console.print(f"Refunds collected successfully from you account!", style="bold green")
            except Exception as e:
                logger.error(f"Failed to collect refunds: {e}")
        else:
            console.print("Refunds not collected!", style="bold red")

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
        "2": "Collect Refunds Money",
        "3": "Exit"
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
            user.collect_refunds_money()
        elif choice == "3":
            console.print("Goodbye!", style="bold red")
            break
        
        input()
        console.clear()


if __name__ == '__main__':
    main()
