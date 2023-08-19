from web3 import Web3
import json

# Connetti al nodo Ethereum
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Indirizzo del contratto e ABI
contract_address = "0xYourContractAddressHere"
contract_abi = json.loads('YourContractABIHere')

# Crea un oggetto contratto
contract = w3.eth.contract(address=contract_address, abi=contract_abi)


def main():
    while True:
        print("\nMenu:")
        print("1. Aggiungi alla blacklist")
        print("2. Rimuovi dalla blacklist")
        print("3. Aggiungi un treno")
        print("4. Aggiungi una stazione")
        print("5. Aggiungi un segmento consecutivo")
        print("6. Aggiungi un segmento consecutivo dinamico")
        print("7. Aggiungi un segmento dinamico")
        print("8. Aggiungi un segmento consecutivo dinamico a un segmento dinamico")
        print("9. Compra un biglietto step-by-step")
        print("10. Compra un biglietto dinamico")
        print("11. Imposta orario di arrivo e verifica rimborsi")
        print("12. Esci")

        choice = input("Seleziona un'opzione: ")

        if choice == "1":
            address = input(
                "Inserisci l'indirizzo da aggiungere alla blacklist: ")
            tx_hash = contract.functions.addToBlacklist(address).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "2":
            address = input(
                "Inserisci l'indirizzo da rimuovere dalla blacklist: ")
            tx_hash = contract.functions.removeFromBlacklist(
                address).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "3":
            train_id = input("Inserisci l'ID del treno: ")
            train_name = input("Inserisci il nome del treno: ")
            max_passengers = int(
                input("Inserisci il numero massimo di passeggeri: "))
            tx_hash = contract.functions.addTrain(
                train_id, train_name, max_passengers).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "4":
            station_id = input("Inserisci l'ID della stazione: ")
            tx_hash = contract.functions.addStation(station_id).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "5":
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

        elif choice == "6":
            dynamic_consecutive_segment_id = input(
                "Inserisci l'ID del segmento consecutivo dinamico: ")
            consecutive_segment_id = input(
                "Inserisci l'ID del segmento consecutivo associato: ")
            tx_hash = contract.functions.addDynamicConsecutiveSegment(
                dynamic_consecutive_segment_id, consecutive_segment_id).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "7":
            dynamic_segment_id = input(
                "Inserisci l'ID del segmento dinamico: ")
            tx_hash = contract.functions.addDynamicSegment(
                dynamic_segment_id).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "8":
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

        elif choice == "9":
            ticket_id = input("Inserisci l'ID del biglietto: ")
            dynamic_segment_id = input(
                "Inserisci l'ID del segmento dinamico: ")
            tx_hash = contract.functions.buyTicketStep(
                ticket_id, dynamic_segment_id).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "10":
            ticket_id = input("Inserisci l'ID del biglietto: ")
            dynamic_segments_ids = input(
                "Inserisci gli ID dei segmenti dinamici separati da virgole: ").split(',')
            tx_hash = contract.functions.buyDynamicTicket(
                ticket_id, dynamic_segments_ids).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "11":
            dynamic_consecutive_segment_id = input(
                "Inserisci l'ID del segmento consecutivo dinamico: ")
            actual_arrival_time = int(
                input("Inserisci l'orario di arrivo effettivo (timestamp UNIX): "))
            tx_hash = contract.functions.setArrivalTimeAndCheckRequiredRefunds(
                dynamic_consecutive_segment_id, actual_arrival_time).transact()
            receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            print("Transazione completata con stato:", receipt['status'])

        elif choice == "12":
            print("Uscita.")
            break

        else:
            print("Opzione non valida. Riprova.")


if __name__ == "__main__":
    main()
