// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol"; // Questo importa la libreria dei test di Remix
import "SmartContracts/DataContract.sol"; // Assicurati che il percorso sia corretto

contract TrainsOracleTest {

    TrainsOracle trainsOracle;
    address payable trainCompanyAddress;

    // Questa funzione è eseguita prima di ogni test
    function beforeEach() public {
        trainCompanyAddress = payable(msg.sender);
        trainsOracle = new TrainsOracle();
    }

    function testBuyDynamicTicketWithSufficientEther() public {
        string[] memory segments = new string[](1);
        segments[0] = "segment1";
        (bool success,) = address(trainsOracle).call{value: 200}(abi.encodeWithSignature("buyDynamicTicket(string,string[])", "ticket1", segments));
        Assert.equal(success, true ,"Couldn't buy a ticket with sufficient Ether");
    }

    function testRefundsCalculatedCorrectlyBasedOnDelay() public {
        uint256 initialBalance = address(trainsOracle).balance;
        
        // Simulate delay and set arrival time
        trainsOracle.setArrivalTimeAndCheckRequiredRefunds("dynamicSegment1", block.timestamp + 2000);
        
        uint256 finalBalance = address(trainsOracle).balance;
        
        // Suppose the expected refund per ticket is 0.01 Ether
        uint256 expectedRefundAmount = 0.01 ether;
        
        // Calculate the actual refunded amount
        uint256 actualRefundAmount = initialBalance - finalBalance;
        
        // Check if the actual refund amount is correct
        Assert.equal(actualRefundAmount, expectedRefundAmount, "Refund amount calculated incorrectly based on delay");
    }

    function testRefundsTransferredCorrectlyToUserAddresses() public {
        uint256 initialBalance = address(this).balance;
        trainsOracle.setArrivalTimeAndCheckRequiredRefunds("dynamicSegment1", block.timestamp + 2000);
        uint256 finalBalance = address(this).balance;
        Assert.equal(finalBalance > initialBalance, true ,"Refunds were not transferred correctly to user addresses");
    }

    function testOnlyOwnerCanAddOrRemoveFromBlacklist() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addToBlacklist(address)", 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4));
        Assert.equal(success, false, "Only the owner should be able to add or remove a user from the blacklist");
    }

    function testUserCannotBuyTicketWhenAddedToBlacklist() public {
        address user = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        trainsOracle.addToBlacklist(user);
        
        string[] memory segments = new string[](1);
        segments[0] = "segment1";
        
        (bool success,) = address(user).call(abi.encodeWithSignature("buyDynamicTicket(string,string[])", "ticket1", segments));
        Assert.equal(success, false ,"Blacklisted user could buy a ticket");
    }


}
