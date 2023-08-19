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


    function testOnlyOwnerCanAddDynamicConsecutiveSegment() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addDynamicConsecutiveSegment(string)", "DCS002"));
        Assert.equal(success, false, "Only the owner should be able to add a dynamic consecutive segment");
    }

    function testUserInBlacklistCannotBuyTicket() public {
        address user = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; 
        trainsOracle.addToBlacklist(user);
        (bool success,) = address(trainsOracle).call(abi.encodeWithSignature("buyDynamicTicket(string,string[])", "ticket1", new string[](1)));
        Assert.equal(success, false ,"Blacklisted user could buy a ticket");
    }

    function testCalculateTotalTicketPrice() public {
        string[] memory segments = new string[](1);
        segments[0] = "segment1";
        uint32 price = trainsOracle.buyTicketStep("ticket1", segments[0]);
        Assert.equal(price, 100, "Total ticket price calculated is incorrect");
    }

    function testCannotBuyTicketIfTrainIsFull() public {
        (bool success,) = address(trainsOracle).call(abi.encodeWithSignature("buyDynamicTicket(string,string[])", "ticket2", new string[](1)));
        Assert.equal(success, false ,"User could buy a ticket even though train is full");
    }

}
