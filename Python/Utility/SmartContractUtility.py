from web3 import Web3
from solcx import compile_standard
import json

class SmartContractUtility:

    @staticmethod
    def web3_instance(provider):
        return Web3(Web3.HTTPProvider(provider))

    @staticmethod
    def compile_contract(web3, contract_source_path, contract_abi_path, contract_bytecode_path, contract_name):
        contract_source_code = SmartContractUtility.get_contract_source_code(contract_source_path)

        compiled_contract = compile_standard({
            "language": "Solidity",
            "sources": {
                contract_source_path: {
                    "content": contract_source_code,
                },
            },
            "settings": {
                "outputSelection": {
                    "*": {
                        "*": ["abi", "evm.bytecode"],
                    },
                },
            },
        })
        
        contract_abi = compiled_contract["contracts"][contract_source_path][contract_name]["abi"]
        contract_bytecode = compiled_contract["contracts"][contract_source_path][contract_name]["evm"]["bytecode"]["object"]

        # Save ABI to the specified path
        with open(contract_abi_path, "w") as abi_file:
            json.dump(contract_abi, abi_file)

        # Save bytecode to the specified path
        with open(contract_bytecode_path, "w") as bytecode_file:
            bytecode_file.write(contract_bytecode)
        
        return contract_source_code, contract_abi, contract_bytecode
    
    @staticmethod
    def get_contract_abi(contract_abi_path):
        with open(contract_abi_path, "r") as abi_file:
            contract_abi = json.load(abi_file)
        return contract_abi
    
    @staticmethod
    def get_contract_bytecode(contract_bytecode_path):
        with open(contract_bytecode_path, "r") as bytecode_file:
            contract_bytecode = bytecode_file.read()
        return contract_bytecode
    
    @staticmethod
    def get_contract_instance(web3, contract_address, contract_abi):
        return web3.eth.contract(address=contract_address, abi=contract_abi)

    @staticmethod
    def get_contract_source_code(contract_source_path):
        with open(contract_source_path, "r") as source_file:
            contract_source_code = source_file.read()
        return contract_source_code

    @staticmethod
    def deploy_contract(web3, contract_abi, contract_bytecode, sender_private_key, value = None, gas_limit=None, gas_price=None):
        sender_account = web3.eth.account.from_key(str(sender_private_key))
        nonce = web3.eth.get_transaction_count(sender_account.address, "pending")

        contract = web3.eth.contract(abi=contract_abi, bytecode=contract_bytecode)
        contract_constructor = contract.constructor()
        
        if gas_price is None:
            gas_price = web3.eth.gas_price
        
        if gas_limit is None:
            gas_limit = 3000000 #contract_constructor.estimate_gas()
        
        if value is None:
            value = web3.to_wei(1, 'ether')
        
        tx_params = {
            "nonce": nonce,
            "gas": gas_limit,
            "gasPrice": gas_price,
            "value": value,
            "from": sender_account.address
        }

        tx_hash = contract_constructor.transact(tx_params)
        tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)

        return tx_receipt.contractAddress
    
    @staticmethod
    def call_contract_function(web3, contract, function_name, function_params, gas_limit=None, gas_price=None):
        function = contract.get_function_by_name(function_name)

        if gas_limit is None:
            gas_limit = function.estimateGas()

        if gas_price is None:
            gas_price = web3.eth.gasPrice

        function_call = function.buildTransaction({'gas': gas_limit}).data_in_transaction(*function_params)

        # Send the transaction
        tx_hash = web3.eth.sendTransaction({
            'to': contract.address,
            'data': function_call,
            'gas': gas_limit,
            'gasPrice': gas_price,
        })

        return tx_hash
