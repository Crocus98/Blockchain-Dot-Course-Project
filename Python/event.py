from rich.console import Console
from dotenv import load_dotenv
from Utility.SmartContractUtility import SmartContractUtility
import os

load_dotenv()
console = Console()


class EventListener:
    def __init__(self):
        if any(var == "" for var in [os.getenv("RPCPROVIDERHOST"), os.getenv("RPCPROVIDERPORT"), os.getenv("CONTRACTABIPATH")]):
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
        console.print(
            f"Listening for events from contract at address {self.contract_address}", style="bold green")

    def listen_for_refund_added(self):
        event_filter = self.contract.events.RefundAdded.create_filter(
            fromBlock='latest')
        console.print(
            "[bold yellow]Listening for RefundAdded events...[/bold yellow]")
        while True:
            for event in event_filter.get_new_entries():
                console.print(
                    f"[bold blue]Event Received:[/bold blue] {event['event']} with data: {event['args']}", style="bold green")


# instance of EventListener class and start listening for events
listener = EventListener()
listener.listen_for_refund_added()
