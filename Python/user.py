from Utility.SmartContractUtility import SmartContractUtility
from rich.prompt import Prompt
from rich.console import Console
from rich.table import Table
from rich.logging import RichHandler
from dotenv import load_dotenv
import os

# from rich.traceback import install
# install()

load_dotenv()
console = Console()


class User:
    def __init__(self, selected_account):
        if any(var == "" for var in [os.getenv("RPCPROVIDERHOST"), os.getenv("RPCPROVIDERPORT"), os.getenv("CONTRACTABIPATH"), os.getenv(f"PRIVATEKEY"+str(selected_account))]):
            raise Exception(
                "One or more environment variables are not set. Please complete .env file information before proceeding.")

        self.web3 = SmartContractUtility.web3_instance(
            os.getenv("RPCPROVIDERHOST") + ":" + os.getenv("RPCPROVIDERPORT"))
        self.contract_address = os.getenv("CONTRACTADDRESS")
        self.contract_abi_path = os.getenv("CONTRACTABIPATH")
        self.contract_abi = SmartContractUtility.get_contract_abi(
            self.contract_abi_path)
        self.contract = SmartContractUtility.get_contract_instance(
            self.web3, self.contract_address, self.contract_abi)
        self.user_public_key = os.getenv("ADDRESS"+str(selected_account))
        self.user_private_key = os.getenv(f"PRIVATEKEY"+str(selected_account))
        console.print(
            f"Contract instance obtained for contract at address {self.contract_address}", style="bold green")

    def call_contract_function(self, function_name, function_params, value=None, gas_limit=None, gas_price=None):
        tx_hash, fee = SmartContractUtility.call_contract_function(
            self.web3, self.contract, function_name, function_params, self.user_private_key, value, gas_limit, gas_price)
        return tx_hash, fee

    def buy_ticket(self, function_params=None, value=0, skip_check=False):
        if function_params is None:
            ticketId = Prompt.ask(
                "Enter an unique id for the ticket you want to buy")
            dynamicSegmentsIds = iter(lambda: Prompt.ask(
                "Enter a dynamic segment ID (or type 'done' to finish)"), 'done')
            function_params = [ticketId, list(dynamicSegmentsIds)]
            value_in_eth = float(Prompt.ask(
                "Enter the value you want to pay for the ticket (in ETH) [fees will be taken additionally]", default=0.1))

            value_in_wei = int(self.web3.to_wei(value_in_eth, 'ether'))
        else:
            skip_check = True

        if skip_check or Prompt.ask(f"Are you sure you want to buy this ticket? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                _, fee = self.call_contract_function(
                    "buyDynamicTicket", function_params, value=value_in_wei)

                fee_in_eth = self.web3.from_wei(fee, 'ether')

                console.print(
                    f"Ticket {function_params[0]} bought successfully! Paid fee: {fee_in_eth} ETH.", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to buy ticket: {e}")
        else:
            console.print("Ticket not bought!", style="bold red")

    def collect_refunds_money(self):
        if Prompt.ask(f"Are you sure you want to collect all your refunds moeny? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                _, fee = self.call_contract_function(
                    "getRefund", [])
                fee_in_eth = self.web3.from_wei(fee, 'ether')
                console.print(
                    f"Refunds collected successfully from you account! Paid fee: {fee_in_eth} ETH.", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to collect refunds: {e}")
        else:
            console.print("Refunds not collected!", style="bold red")

    def get_balance(self):
        try:
            return SmartContractUtility.get_balance_from_address(self.web3, self.user_public_key)
        except Exception as e:
            raise Exception(f"Could not find balance: {e}")


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

    try:
        web3_temp = SmartContractUtility.web3_instance(
            os.getenv("RPCPROVIDERHOST") + ":" + os.getenv("RPCPROVIDERPORT"))
        for i in range(1, 10):
            account_options[i] = os.getenv(f"ADDRESS"+str(i))
            console.print(
                f"{i} - {account_options[i]} - Balance: {SmartContractUtility.get_balance_from_address(web3_temp, account_options[i])} ETH")
        web3_temp = None
        selected_account = Prompt.ask("Choose your account", choices=[
            str(i) for i in range(1, 10)])
        console.print(
            f"Selected Address: [bold blue]{account_options[int(selected_account)]}[/bold blue]")
        console.print(
            "Press [bold blue]ENTER[/bold blue] to continue...", style="bold")
        input()
        console.clear()
        user = User(selected_account)
    except Exception as e:
        console.print(
            f"Failed to inizialize program: {e}", style="bold red")
        return

    while True:
        console.print(logo, style="bold blue")
        console.print(
            "Welcome to [bold blue]User CLI[/bold blue]!", style="bold yellow")
        console.print(
            f"Current Balance of selected account is: {user.get_balance()} ETH", style="bold cyan")
        console.print("\n[bold green]Please choose an action:[/bold green]")
        for key, value in options.items():
            console.print(f"{key}. {value}")

        try:
            choice = Prompt.ask("Enter your choice",
                                choices=list(options.keys()))
        except Exception:
            console.print("Invalid choice!", style="bold red")
            continue

        try:
            if choice == "1":
                user.buy_ticket()
            elif choice == "2":
                user.collect_refunds_money()
            elif choice == "3":
                console.print("Goodbye!", style="bold blue")
                break
        except Exception as e:
            console.print(f"Failed to execute action: {e}", style="bold red")
        console.print(
            f"Updated Balance for {account_options[int(selected_account)]}: {user.get_balance()} ETH", style="bold cyan")
        console.print(
            "Press [bold blue]ENTER[/bold blue] to continue...", style="bold")
        input()
        console.clear()


if __name__ == '__main__':
    main()
