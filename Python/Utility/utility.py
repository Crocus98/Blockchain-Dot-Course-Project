from web3 import Web3

class SmartContractUtility:

    @staticmethod
    def compile_contract(self, contract_source_path):
        with open(contract_source_path, "r") as source_file:
            contract_source_code = source_file.read()

        compiled_contract = self.web3.eth.compileContract(contract_source_code)
        contract_abi = compiled_contract["info"]["abiDefinition"]
        contract_bytecode = compiled_contract["code"]

        return contract_abi, contract_bytecode

    @staticmethod
    def update_abi_bytecode_files(self, abi, bytecode, abi_path, bytecode_path):
        with open(abi_path, "w") as abi_file:
            json.dump(abi, abi_file)

        with open(bytecode_path, "w") as bytecode_file:
            bytecode_file.write(bytecode)

    @staticmethod
    def deploy_contract(self, private_key, contract_abi, contract_bytecode):
        # Deployment logic
        pass
