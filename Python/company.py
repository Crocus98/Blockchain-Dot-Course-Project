from rich.console import Console
from rich.prompt import Prompt
from rich.logging import RichHandler
from dotenv import load_dotenv, find_dotenv
import os
from Utility.SmartContractUtility import SmartContractUtility

load_dotenv()
console = Console()


class Company:

    def __init__(self):
        if any(var == "" for var in [os.getenv("RPCPROVIDERHOST"), os.getenv("RPCPROVIDERHOST"), find_dotenv(), os.getenv("CONTRACTABIPATH"), os.getenv("CONTRACTBYTECODEPATH"), os.getenv("CONTRACTSOURCEPATH"), os.getenv("PRIVATEKEY0"), os.getenv("CONTRACTNAME")]):
            raise Exception(
                "One or more environment variables are not set. Please complete .env file information before proceeding.")

        self.web3 = SmartContractUtility.web3_instance(
            os.getenv("RPCPROVIDERHOST") + ":" + os.getenv("RPCPROVIDERHOST"))
        self.dot_env_path = find_dotenv()
        self.contract_address = os.getenv("CONTRACTADDRESS")
        self.contract_abi_path = os.getenv("CONTRACTABIPATH")
        self.contract_bytecode_path = os.getenv("CONTRACTBYTECODEPATH")
        self.contract_source_path = os.getenv("CONTRACTSOURCEPATH")
        self.company_private_key = os.getenv("PRIVATEKEY0")
        self.contract_name = os.getenv("CONTRACTNAME")

        if self.contract_address:
            self.contract_abi = SmartContractUtility.get_contract_abi(
                self.contract_abi_path)
            self.contract_source_code = SmartContractUtility.get_contract_source_code(
                self.contract_source_path)
            self.contract_bytecode = SmartContractUtility.get_contract_bytecode(
                self.contract_bytecode_path)
        else:
            self.contract_source_code, self.contract_abi, self.contract_bytecode = SmartContractUtility.compile_contract(
                self.contract_source_path, self.contract_abi_path, self.contract_bytecode_path, self.contract_name)
            self.contract_address = SmartContractUtility.deploy_contract(
                self.web3, self.contract_abi, self.contract_bytecode, self.company_private_key)
            SmartContractUtility.set_contract_address_in_env(
                self.contract_address, self.dot_env_path)
            console.print(
                f"Contract deployed at address {self.contract_address}", style="bold green")

        self.contract = SmartContractUtility.get_contract_instance(
            self.web3, self.contract_address, self.contract_abi)
        console.print(
            f"Contract instance obtained for contract at address {self.contract_address}", style="bold green")

    def call_contract_function(self, function_name, function_params, value=None, gas_limit=None, gas_price=None):
        SmartContractUtility.call_contract_function(
            self.web3, self.contract, function_name, function_params, self.company_private_key, value, gas_limit, gas_price)

    def add_train(self, function_params=None, skip_check=False):
        if function_params is None:
            trainId = Prompt.ask("Enter the train ID")
            trainName = Prompt.ask("Enter the train name")
            maxPassengersNumber = int(Prompt.ask(
                "Enter the max passengers number"))

            function_params = [trainId, trainName, maxPassengersNumber]
        else:
            skip_check = True

        if skip_check or Prompt.ask("Are you sure you want to add this train? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function("addTrain", function_params)
                console.print(
                    f"Train {function_params[0]} - {function_params[1]} added successfully!", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to add train: {e}")
                return
        else:
            console.print("Train not added!", style="bold red")

    def add_station(self, function_params=None, skip_check=False):
        if function_params is None:
            stationId = Prompt.ask("Enter the station ID")

            function_params = [stationId]
        else:
            skip_check = True

        if skip_check or Prompt.ask("Are you sure you want to add this station? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function("addStation", function_params)
                console.print(
                    f"Station {function_params[0]} added successfully!", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to add station: {e}")
                return
        else:
            console.print("Station not added!", style="bold red")

    def add_consecutive_segment(self, function_params=None, skip_check=False):
        if function_params is None:
            consecutiveSegmentId = Prompt.ask(
                "Enter the consecutive segment ID")
            trainId = Prompt.ask("Enter the train ID")
            startingStationId = Prompt.ask("Enter the starting station ID")
            arrivingStationId = Prompt.ask("Enter the arriving station ID")
            arrivalTimeOffset = int(Prompt.ask(
                "Enter the arrival timestamp offset (Timestamp is in seconds: 1 hour = 3600s.\n E.g. train arrives at 2:00 am, offset should be 7200. Train arrives at 2 pm, offset should be 50400.)"))
            price = int(Prompt.ask(
                "Enter the price of the consecutive segment"))

            function_params = [consecutiveSegmentId, trainId,
                               startingStationId, arrivingStationId, arrivalTimeOffset, price]
        else:
            skip_check = True

        if skip_check or Prompt.ask(f"Are you sure you want to add this consecutive segment? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function(
                    "addConsecutiveSegment", function_params)
                console.print(
                    f"Consecutive Segment {function_params[0]} added successfully!", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to add consecutive segment: {e}")
                return
        else:
            console.print("Consecutive segment not added!", style="bold red")

    def add_dynamic_consecutive_segment(self, function_params=None, skip_check=False):
        if function_params is None:
            dynamicConsecutiveSegmentId = Prompt.ask(
                "Enter the dynamic consecutive segment ID")
            consecutiveSegmentId = Prompt.ask(
                "Enter the consecutive segment ID")
            arrivalDay = int(Prompt.ask(
                "Enter the arrival day timestamp (must be multiple of 86400 seconds = 1 day)"))

            function_params = [dynamicConsecutiveSegmentId,
                               consecutiveSegmentId, arrivalDay]
        else:
            skip_check = True

        if skip_check or Prompt.ask(f"Are you sure you want to add this dynamic consecutive segment? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function(
                    "addDynamicConsecutiveSegment", function_params)
                console.print(
                    f"Dynamic Consecutive Segment {function_params[0]} added successfully!", style="bold green")
            except Exception as e:
                raise Exception(
                    f"Failed to add dynamic consecutive segment: {e}")
                return
        else:
            console.print(
                "Dynamic consecutive segment not added!", style="bold red")

    def add_dynamic_segment(self, function_params=None, skip_check=False):
        if function_params is None:
            dynamicSegmentId = Prompt.ask("Enter the dynamic segment ID")

            function_params = [dynamicSegmentId]
        else:
            skip_check = True

        if skip_check or Prompt.ask("Are you sure you want to add this dynamic segment? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function(
                    "addDynamicSegment", function_params)
                console.print(
                    f"Dynamic Segment {function_params[0]} added successfully!", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to add dynamic segment: {e}")
                return
        else:
            console.print("Dynamic segment not added!", style="bold red")

    def add_dynamic_consecutive_segment_to_dynamic_segment(self, function_params=None, skip_check=False):
        if function_params is None:
            dynamicSegmentId = Prompt.ask("Enter the dynamic segment ID")
            dynamicConsecutiveSegmentId = Prompt.ask(
                "Enter the dynamic consecutive segment ID")
            lastSegmentStop = Prompt.ask(
                "Is this the last segment stop? [yes/no]", choices=["yes", "no"]) == "yes"

            function_params = [dynamicSegmentId,
                               dynamicConsecutiveSegmentId, lastSegmentStop]
        else:
            skip_check = True

        if skip_check or Prompt.ask(f"Are you sure you want to add this dynamic consecutive segment to that dynamic segment? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function(
                    "addDynamicConsecutiveSegmentToDynamicSegment", function_params)
                console.print(
                    f"Dynamic Consecutive Segment {function_params[1]} added to Dynamic Segment {function_params[0]} successfully!", style="bold green")
            except Exception as e:
                raise Exception(
                    f"Failed to add dynamic consecutive segment to dynamic segment: {e}")
                return
        else:
            console.print(
                "Dynamic consecutive segment not added to dynamic segment!", style="bold red")

    def set_arrival_time_and_check_required_refunds(self, function_params=None, skip_check=False):
        if function_params is None:
            dynamicConsecutiveSegmentId = Prompt.ask(
                "Enter the dynamic consecutive segment ID")
            actualArrivalTime = int(Prompt.ask(
                "Enter the actual arrival timestamp"))

            function_params = [dynamicConsecutiveSegmentId, actualArrivalTime]
        else:
            skip_check = True

        if skip_check or Prompt.ask(f"Are you sure you want to set this arrival time for that dynamic consecutive segment and check for refunds? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function(
                    "setArrivalTimeAndCheckRequiredRefunds", function_params)
                console.print(
                    f"Arrival time {function_params[1]} set for dynamic consecutive segment {function_params[0]} successfully and refund check completed!", style="bold green")
            except Exception as e:
                raise Exception(
                    f"Failed to set arrival time and to check for refunds: {e}")
                return
        else:
            console.print(
                "Arrival time not set and refund check not completed!", style="bold red")

    def add_user_to_blacklist(self, function_params=None, skip_check=False):
        if function_params is None:
            toBlackList = Prompt.ask(
                "Enter the address of the user you want to blacklist")

            function_params = [toBlackList]
        else:
            skip_check = True

        if skip_check or Prompt.ask(f"Are you sure you want to blacklist user {function_params[0]}? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function("addToBlacklist", function_params)
                console.print(
                    f"User {function_params[0]} added to blacklist successfully!", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to add user to blacklist: {e}")
                return
        else:
            console.print("User not added to blacklist!", style="bold red")

    def remove_user_from_blacklist(self, function_params=None, skip_check=False):
        if function_params is None:
            fromBlackList = Prompt.ask(
                "Enter the address of the user you want to remore from blacklist")

            function_params = [fromBlackList]
        else:
            skip_check = True

        if skip_check or Prompt.ask(f"Are you sure you want to remove user {function_params[0]} from the blacklist? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function(
                    "removeFromBlacklist", function_params)
                console.print(
                    f"User {function_params[0]} removed from blacklist successfully!", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to remove user from blacklist: {e}")
                return
        else:
            console.print("User not removed from blacklist!", style="bold red")

    def set_new_admin(self, function_params=None, skip_check=False):
        if function_params is None:
            newOwner = Prompt.ask(
                "Enter the address of the user you want to promote to admin (you will be demoted to user)")

            function_params = [newOwner]
        else:
            skip_check = True

        if skip_check or Prompt.ask(f"Are you sure you want to promote user {function_params[0]} to admin? [yes/no]", choices=["yes", "no"]) == "yes":
            try:
                self.call_contract_function("setNewOwner", function_params)
                console.print(
                    f"User {function_params[0]} promoted to admin!", style="bold green")
            except Exception as e:
                raise Exception(f"Failed to promote user to admin: {e}")
                return
        else:
            console.print("User not promoted to admin!", style="bold red")

    def create_scenario(self):
        # Trains: T1, T2
        self.add_train(["T1", "SlowTrain", 12])
        self.add_train(["T2", "FastTrain", 12])
        # Stations: S1, S2, S3, S4, S5
        self.add_station(["S1"])  # S1 - S2 = 1km
        self.add_station(["S2"])  # S2 - S3 = 2km
        self.add_station(["S3"])  # S3 - S4 = 1km # S3 - S5 = 3km
        self.add_station(["S4"])
        self.add_station(["S5"])
        # Consecutive Segments: CS1, CS2, CS3, CS4, CS5, CS6, CS7, CS8, CS9, CS10, CS11, CS12
        # I consider that the slow train start from S1 at 64800 (18:00) and arrive at S4 at 64800 + 7200 (20:00)
        self.add_consecutive_segment(
            ["CS1", "T1", "S1", "S2", 66600, 1000000000000000])
        self.add_consecutive_segment(
            ["CS2", "T1", "S2", "S3", 70200, 2000000000000000])
        self.add_consecutive_segment(
            ["CS3", "T1", "S3", "S4", 72000, 1000000000000000])
        # I consider that the slow train return from S4 at 75600 (21:00) and arrive back at S1 at 72000 + 7200 (23:00)
        self.add_consecutive_segment(
            ["CS4", "T1", "S4", "S3", 77400, 1000000000000000])
        self.add_consecutive_segment(
            ["CS5", "T1", "S3", "S2", 81000, 2000000000000000])
        self.add_consecutive_segment(
            ["CS6", "T1", "S2", "S1", 82800, 1000000000000000])
        # I consider that the fast train start from S1 at 61200 (17:00) and arrive at S4 at 61200 + 5400 (18:30)
        self.add_consecutive_segment(
            ["CS7", "T2", "S1", "S2", 62100, 2000000000000000])
        self.add_consecutive_segment(
            ["CS8", "T2", "S2", "S3", 63900, 4000000000000000])
        self.add_consecutive_segment(
            ["CS9", "T2", "S3", "S5", 66600, 6000000000000000])
        # I consider that the fast train return from S5 at 72000 (20:00) and arrive back at S1 at 68400 + 5400 (20:30)
        self.add_consecutive_segment(
            ["CS10", "T2", "S5", "S3", 74700, 6000000000000000])
        self.add_consecutive_segment(
            ["CS11", "T2", "S3", "S2", 76500, 4000000000000000])
        self.add_consecutive_segment(
            ["CS12", "T2", "S2", "S1", 77400, 2000000000000000])
        # Dynamic Consecutive Segments: DCS1, DCS2, DCS3, DCS4, DCS5, DCS6, DCS7, DCS8, DCS9, DCS10, DCS11, DCS12
        # Arrival Day set to  1/10/2023 - 1st october 2023
        self.add_dynamic_consecutive_segment(["DCS1", "CS1", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS2", "CS2", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS3", "CS3", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS4", "CS4", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS5", "CS5", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS6", "CS6", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS7", "CS7", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS8", "CS8", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS9", "CS9", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS10", "CS10", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS11", "CS11", 1696118400])
        self.add_dynamic_consecutive_segment(["DCS12", "CS12", 1696118400])
        # Dynamic Segments: DS1, DS2, DS3, DS4
        self.add_dynamic_segment(["DS1"])  # S1 - S2 - S3 - S4 -- SlowTrain
        self.add_dynamic_segment(["DS2"])  # S4 - S3 - S2 - S1 -- SlowTrain
        self.add_dynamic_segment(["DS3"])  # S1 - S2 - S3 - S5 -- FastTrain
        self.add_dynamic_segment(["DS4"])  # S5 - S3 - S2 - S1 -- FastTrain
        self.add_dynamic_segment(["DS5"])  # S1 - S2 - S3 -- SlowTrain
        self.add_dynamic_segment(["DS6"])  # S3 - S2 - S1 -- SlowTrain
        self.add_dynamic_segment(["DS7"])  # S3 - S4 -- SlowTrain
        self.add_dynamic_segment(["DS8"])  # S4 - S3 -- SlowTrain
        self.add_dynamic_segment(["DS9"])  # S1 - S2 - S3 -- FastTrain
        self.add_dynamic_segment(["DS10"])  # S3 - S2 - S1 -- FastTrain
        self.add_dynamic_segment(["DS11"])  # S3 - S5 -- FastTrain
        self.add_dynamic_segment(["DS12"])  # S5 - S3 -- FastTrain
        # Dynamic Consecutive Segments to Dynamic Segments
        # S1 - S2 - S3 - S4 -- SlowTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS1", "DCS1", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS1", "DCS2", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS1", "DCS3", True])
        # S4 - S3 - S2 - S1 -- SlowTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS2", "DCS4", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS2", "DCS5", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS2", "DCS6", True])
        # S1 - S2 - S3 - S5 -- FastTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS3", "DCS7", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS3", "DCS8", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS3", "DCS9", True])
        # S5 - S3 - S2 - S1 -- FastTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS4", "DCS10", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS4", "DCS11", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS4", "DCS12", True])
        # S1 - S2 - S3 -- SlowTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS5", "DCS1", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS5", "DCS2", True])
        # S3 - S2 - S1 -- SlowTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS6", "DCS5", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS6", "DCS6", True])
        # S3 - S4 -- SlowTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS7", "DCS3", True])
        # S4 - S3 -- SlowTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS8", "DCS4", True])
        # S1 - S2 - S3 -- FastTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS9", "DCS7", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS9", "DCS8", True])
        # S3 - S2 - S1 -- FastTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS10", "DCS11", False])
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS10", "DCS12", True])
        # S3 - S5 -- FastTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS11", "DCS9", True])
        # S5 - S3 -- FastTrain
        self.add_dynamic_consecutive_segment_to_dynamic_segment(
            ["DS12", "DCS10", True])
        # Add users to blacklist
        self.add_user_to_blacklist([os.getenv("ADDRESS9")])


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
        "6": "Add Dynamic Consecutive Segment To Dynamic Segment",
        "7": "Set Arrival Time And Check Required Refunds",
        "8": "Add User To Blacklist",
        "9": "Remove User From Blacklist",
        "10": "Set New Admin",
        "11": "Create Scenario",
        "12": "Exit"
    }

    try:
        company = Company()
    except Exception as e:
        console.print(
            f"Failed to inizialize program: {e}", style="bold red")
        return

    while True:
        console.print(logo, style="bold blue")
        console.print(
            "Welcome to [bold blue]Company CLI[/bold blue]!", style="bold red")
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
                company.set_arrival_time_and_check_required_refunds()
            elif choice == "8":
                company.add_user_to_blacklist()
            elif choice == "9":
                company.remove_user_from_blacklist()
            elif choice == "10":
                company.set_new_admin()
            elif choice == "11":
                company.create_scenario()
            elif choice == "12":
                console.print("Goodbye!", style="bold red")
                break
        except Exception as e:
            console.print(f"Failed to execute action: {e}", style="bold red")

        console.print(
            "Press [bold blue]ENTER[/bold blue] to continue...", style="bold")
        input()
        console.clear()


# Run the main function only if this file is being run directly (not imported from another file)
if __name__ == "__main__":
    main()
