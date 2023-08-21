// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@tests";
//import "remix_tests.sol";

import "SmartContracts/DataContract.sol";

//Run Owner - User1 - User2 in this order to properly test the contract

contract TestUser1 {
    address testOwnerAddress;
    TrainsOracle trainsContract;
    address user;

    constructor(address trainsOracleAddress) {
        user = address(this);

        trainsContract = TrainsOracle(trainsOracleAddress);
    }

    function testNonOwnerPermissions() public {
        bool success = true;

        try trainsContract.addTrain("T2", "Slow Train", 50) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a train"
        );

        try trainsContract.addStation("S3") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a station"
        );

        try trainsContract.addStation("S4") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");

        try
            trainsContract.addConsecutiveSegment(
                "CS",
                "T2",
                "S3",
                "S4",
                block.timestamp + 1 hours,
                100
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a consecutive segment"
        );

        try trainsContract.addDynamicConsecutiveSegment("DCS2", "CS2") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a dynamic consecutive segment"
        );

        try trainsContract.addDynamicSegment("DS2") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a dynamic segment"
        );

        try
            trainsContract.addDynamicConsecutiveSegmentToDynamicSegment(
                "DS2",
                "DCS2",
                true
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a dynamic consecutive segment to a dynamic segment"
        );

        try trainsContract.setNewOwner(user) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "The owner address should not be set by non-owner"
        );
    }

    function testUserShouldNotAddOrRemoveFromBlacklist() public {
        bool success = true;
        try
            trainsContract.addToBlacklist(
                0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Only the owner should be able to add or remove a user from the blacklist"
        );
        try
            trainsContract.removeFromBlacklist(
                0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Only the owner should be able to add or remove a user from the blacklist"
        );
    }

    /*//TODO
    function testCalculateTotalTicketPrice() public {
        uint32 calculatedPrice = trainsContract.buyTicketStep("ticket1", "DS1"); //buyticketstep is internal not callable

        uint32 expectedPrice = 10;

        Assert.equal(
            calculatedPrice,
            expectedPrice,
            "Total ticket price calculated is incorrect"
        );
    }*/

    //TODO
    function testCannotBuyTicketIfTrainIsFull() public {
        (bool success, ) = address(trainsContract).call(
            abi.encodeWithSignature(
                "buyDynamicTicket(string,string[])",
                "ticket2",
                new string[](1)
            )
        );
        Assert.equal(
            success,
            false,
            "User could buy a ticket even though train is full"
        );
    }

    //TODO
    function testCannotBuyDynamicTicketWithInsufficientEther() public {
        string[] memory segments = new string[](1);
        segments[0] = "segment1";
        (bool success, ) = address(trainsContract).call{value: 50}(
            abi.encodeWithSignature(
                "buyDynamicTicket(string,string[])",
                "ticket1",
                segments
            )
        );
        Assert.equal(
            success,
            true,
            "Couldn't buy a ticket with sufficient Ether"
        );
    }
}

contract TestUser2 {
    address testOwnerAddress;
    TrainsOracle trainsContract;
    address user;

    constructor(address trainsOracleAddress) {
        user = address(this);

        trainsContract = TrainsOracle(trainsOracleAddress);
    }

    function testUserInBlacklistCannotBuyTicket() public {
        bool success = true;
        try trainsContract.buyDynamicTicket("ticket2", new string[](0)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Blacklisted user should not be able to buy a ticket"
        );
    }
}
