from web3 import Web3
import json
import time
import random
from dotenv import load_dotenv


# Connetti al nodo Ethereum
w3 = Web3(Web3.HTTPProvider('HTTP://127.0.0.1:7545'))

# Indirizzo del contratto e ABI
contract_address = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
# Load environment variables from .env file
load_dotenv()

# Get the ABI from the environment variables
contract_abi_json = os.getenv("CONTRACT_ABI")

# Parse the JSON string to get the ABI
contract_abi = json.loads('ABI.json')

# Crea un oggetto contratto
contract = w3.eth.contract(address=contract_address, abi=contract_abi)


def confirm_train_arrival(train_id, dynamic_consecutive_segment_id):
    # Simula l'arrivo del treno con un ritardo casuale del 30% delle volte
    is_delayed = random.random() < 0.3

    if is_delayed:
        print(f"Il treno {train_id} è in ritardo!")
        actual_arrival_time = int(
            input("Inserisci l'orario di arrivo effettivo (timestamp UNIX): "))
        tx_hash = contract.functions.setArrivalTimeAndCheckRequiredRefunds(
            dynamic_consecutive_segment_id, actual_arrival_time).transact()
        receipt = w3.eth.waitForTransactionReceipt(tx_hash)
        print("Transazione completata con stato:", receipt['status'])
    else:
        print(f"Il treno {train_id} è arrivato in orario!")


def insert_sample_data():
    # Inserisce dati di esempio
    print("Inserimento dati di esempio...")

    contract.functions.addTrain("T1", "Express", 300).transact()
    time.sleep(1)

    contract.functions.addStation("S1").transact()
    time.sleep(1)

    contract.functions.addStation("S2").transact()
    time.sleep(1)

    contract.functions.addConsecutiveSegment(
        "CS1", "T1", "S1", "S2", int(time.time()) + 3600, 50).transact()
    time.sleep(1)

    contract.functions.addDynamicConsecutiveSegment("DCS1", "CS1").transact()
    time.sleep(1)

    contract.functions.addDynamicSegment("DS1").transact()
    time.sleep(1)

    contract.functions.addDynamicConsecutiveSegmentToDynamicSegment(
        "DS1", "DCS1", False).transact()
    print("Dati di esempio inseriti.")


def main():
    while True:
        print("\nMenu Italy Trains:")
        print("1. Aggiungi un treno")
        print("2. Aggiungi una stazione")
        print("3. Aggiungi un segmento consecutivo")
        print("4. Aggiungi un segmento consecutivo dinamico")
        print("5. Aggiungi un segmento dinamico")
        print("6. Aggiungi un segmento consecutivo dinamico a un segmento dinamico")
        print("7. Inserisci dati di esempio")
        print("8. Esci")

        choice = input("Seleziona un'opzione: ")

        if choice == "1":
            train_id = input("Inserisci l'ID del treno: ")
            train_name = input("Inserisci il nome del treno: ")
            max_passengers = int(
                input("Inserisci il numero massimo di passeggeri: "))
            tx_hash = contract.functions.addTrain(
                train_id, train_name, max_passengers).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "2":
            station_id = input("Inserisci l'ID della stazione: ")
            tx_hash = contract.functions.addStation(station_id).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "3":
            consecutive_segment_id = input(
                "Inserisci l'ID del segmento consecutivo: ")
            train_id = input("Inserisci l'ID del treno: ")
            starting_station_id = input(
                "Inserisci l'ID della stazione di partenza: ")
            arriving_station_id = input(
                "Inserisci l'ID della stazione di arrivo: ")
            arrival_time = int(
                input("Inserisci l'orario di arrivo (timestamp UNIX): "))
            price = int(input("Inserisci il prezzo: "))
            tx_hash = contract.functions.addConsecutiveSegment(
                consecutive_segment_id, train_id, starting_station_id, arriving_station_id, arrival_time, price).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "4":
            dynamic_consecutive_segment_id = input(
                "Inserisci l'ID del segmento consecutivo dinamico: ")
            consecutive_segment_id = input(
                "Inserisci l'ID del segmento consecutivo associato: ")
            tx_hash = contract.functions.addDynamicConsecutiveSegment(
                dynamic_consecutive_segment_id, consecutive_segment_id).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "5":
            dynamic_segment_id = input(
                "Inserisci l'ID del segmento dinamico: ")
            tx_hash = contract.functions.addDynamicSegment(
                dynamic_segment_id).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "6":
            dynamic_segment_id = input(
                "Inserisci l'ID del segmento dinamico: ")
            dynamic_consecutive_segment_id = input(
                "Inserisci l'ID del segmento consecutivo dinamico: ")
            last_segment_stop = input(
                "È l'ultima fermata del segmento? (si/no): ").lower() == 'si'
            tx_hash = contract.functions.addDynamicConsecutiveSegmentToDynamicSegment(
                dynamic_segment_id, dynamic_consecutive_segment_id, last_segment_stop).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "7":
            insert_sample_data()

        elif choice == "8":
            print("Uscita.")
            break

        else:
            print("Opzione non valida. Riprova.")


if __name__ == "__main__":
    main()
