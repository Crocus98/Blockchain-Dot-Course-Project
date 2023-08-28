// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@tests";
//import "remix_tests.sol";

import "SmartContracts/DataContract.sol";

//Run Owner - User1 - User2 in this order to properly test the contract

contract TestUser1 {
    TrainsOracle trainsContract;
    address user;

    constructor(address payable trainsOracleAddress) {
        user = address(this);

        trainsContract = TrainsOracle(trainsOracleAddress);
    }

    function testUserNonOwnerPermissions() public {
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
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a station"
        );

        try
            trainsContract.addConsecutiveSegment(
                "CS",
                "T2",
                "S3",
                "S4",
                5 hours,
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

        uint256 arrivalTimeDay = (block.timestamp + 2 hours) % 1 days;
        try
            trainsContract.addDynamicConsecutiveSegment(
                "DCS2",
                "CS2",
                arrivalTimeDay
            )
        {
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

        try
            trainsContract.setArrivalTimeAndCheckRequiredRefunds(
                "DCS1",
                block.timestamp + 1000
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non owner should not be able to add a new arrival time"
        );

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
}

contract TestUser2 {
    TrainsOracle trainsContract;
    address user;

    constructor(address payable trainsOracleAddress) {
        user = address(this);

        trainsContract = TrainsOracle(trainsOracleAddress);
    }

    function testUserInBlacklistCannotBuyTicketOrGetRefund() public {
        bool success = true;
        try trainsContract.buyDynamicTicket("TKT3", new string[](0)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Blacklisted user should not be able to buy a ticket"
        );

        try trainsContract.getRefund() {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Blacklisted user should not be able to obtain a refund"
        );
    }
}
