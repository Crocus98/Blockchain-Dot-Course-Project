// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;


// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "SmartContracts/DataContract.sol"; // Assicurati che il percorso sia corretto

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    TrainsOracle trainsOracle;
    address payable trainCompanyAddress;
    address acc0;
    address acc1; // non-owner

    event LogAccount(string description, address account);



    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        emit LogAccount("Account 0: ", acc0);
        
        trainsOracle = new TrainsOracle();
        trainCompanyAddress = payable(acc0);  // set acc0 as the owner
        
        acc1 = TestsAccounts.getAccount(1);  // non owner
        emit LogAccount("Account 1: ", acc1);
    }

      function beforeEach() public {
          acc0 = TestsAccounts.getAccount(0);
          emit LogAccount("Account 0: ", acc0);
        
          // trainsOracle = new TrainsOracle();
          trainCompanyAddress = payable(acc0);  // set acc0 as the owner
        
          acc1 = TestsAccounts.getAccount(1);  // non owner
         emit LogAccount("Account 1: ", acc1);
      }


    /// #sender: acc0
    function testOnlyOwnerCanExecuteFunctionsRequiringOnlyOwner() public {
        address nonOwner = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        (bool success, ) = address(nonOwner).call(
            abi.encodeWithSignature("addToBlacklist(address)", nonOwner)
        );
        Assert.equal(
            success,
            false,
            "Non-owner could execute function requiring onlyOwner"
        );
    }

    /// #sender: acc0
    function testContractInitialization() public {
        trainsOracle.setOwner(trainCompanyAddress); // Only for debugging
        address owner = trainsOracle.owner();
        Assert.equal(
            owner,
            trainCompanyAddress,
            "The owner address should be set correctly during contract creation"
        );
    }




}


