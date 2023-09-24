from rich.console import Console
from dotenv import load_dotenv
from Utility.SmartContractUtility import SmartContractUtility
import os
import threading
import time

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

    def listen_for_event(self, event_name):
        event_filter = getattr(self.contract.events,
                               event_name).create_filter(fromBlock='latest')
        console.print(
            f"[bold yellow]Listening for {event_name} events...[/bold yellow]")
        while True:
            for event in event_filter.get_new_entries():
                console.print(
                    f"[bold blue]Event Received:[/bold blue] {event['event']} with data: {event['args']}", style="bold green")
            time.sleep(2)

    def start_listening(self, event_names):
        threads = []
        for event_name in event_names:
            t = threading.Thread(
                target=self.listen_for_event, args=(event_name,))
            threads.append(t)
            t.start()


# Create an instance of the EventListener class and start listening for events
listener = EventListener()
# Here you can add any other events you want to listen to.
listener.start_listening(["RefundAdded", "RefundTaken"])
