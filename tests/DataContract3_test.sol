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
    address acc2; // non owner

    event LogAccount(string description, address account);



    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        emit LogAccount("Account 0: ", acc0);
        
        trainsOracle = new TrainsOracle();
        trainCompanyAddress = payable(acc0);  // set acc0 as the owner
        
        acc1 = TestsAccounts.getAccount(1);  // non owner
        emit LogAccount("Account 1: ", acc1);

        acc2 = TestsAccounts.getAccount(2);  // non owner
        emit LogAccount("Account 2: ", acc2);
    }

     function beforeEach() public {
        acc0 = TestsAccounts.getAccount(0);
        emit LogAccount("Account 0: ", acc0);
        
        trainsOracle = new TrainsOracle();
        trainCompanyAddress = payable(acc0);  // set acc0 as the owner
        
        acc1 = TestsAccounts.getAccount(1);  // non owner
        emit LogAccount("Account 1: ", acc1);
    }


    function testCannotAddConsecutiveSegmentWithNonExistentStations() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addConsecutiveSegment(string,string,string)", "burubbu", "barabba", "biribbi"));
        Assert.equal(success, false, "Should not be able to add a consecutive segment with non-existent stations");
    }

    /// #sender: acc1
    function testUserInBlacklistCannotBuyTicket() public {
        address user = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; 
        trainsOracle.addToBlacklist(user);
        (bool success,) = address(trainsOracle).call(abi.encodeWithSignature("buyDynamicTicket(string,string[])", "ticket1", new string[](1)));
        Assert.equal(success, false ,"Blacklisted user could buy a ticket");
    }

    /// #sender: acc2
    function testOnlyOwnerCanAddOrRemoveFromBlacklist() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addToBlacklist(address)",0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db));
        Assert.equal(success,false,"Only the owner should be able to add or remove a user from the blacklist");
        (bool success2, ) = address(trainsOracle).call(abi.encodeWithSignature("removeToBlacklist(address)",0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db));
        Assert.equal(success2,false,"Only the owner should be able to add or remove a user from the blacklist");
    }


}


