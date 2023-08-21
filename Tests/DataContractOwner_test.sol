// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@tests";
import "@accounts";

import "SmartContracts/DataContract.sol";

//Run Owner - User1 - User2 in this order to properly test the contract
contract testOwner {
    address trainOracleAddress = "";
    TrainsOracle trainsContract;
    address owner;

    function beforeAll() public {
        owner = TestsAccounts.getAccount(0);

        string trainOracleAddressString = "" + trainOracleAddress;
        if (trainOracleAddressString.length == 0) {
            trainsContract = new TrainsOracle();
            trainOracleAddress = address(trainsContract);
        } else {
            //fromStringToAddress = address(bytes20(bytes(trainOracleAddressString)));
            trainsContract = TrainsOracle(address(trainOracleAddress));
        }
    }

    function beforeEach() public {}

    function testOwnerPermissions() public {
        bool success = true;

        try trainsContract.addTrain("T1", "Fast Train", 100) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a train");

        try trainsOracle.addStation("S1") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");

        try trainsOracle.addStation("S2") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");

        try
            trainsOracle.addConsecutiveSegment(
                "CS1",
                "T1",
                "S1",
                "S2",
                block.timestamp + 1 hours,
                10
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "Owner should be able to add a consecutive segment"
        );

        try trainsOracle.addDynamicConsecutiveSegment("DCS1", "CS1") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "Owner should be able to add a dynamic consecutive segment"
        );

        try trainsOracle.addDynamicSegment("DS001") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "Owner should be able to add a dynamic segment"
        );

        try
            trainsOracle.addDynamicConsecutiveSegmentToDynamicSegment(
                "DS1",
                "DCS1",
                true
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "Owner should be able to add a dynamic consecutive segment to a dynamic segment"
        );
    }

    function testCannotAddConsecutiveSegment() public {
        try
            trainsContract.addConsecutiveSegment(
                "CS2",
                "T1",
                "S2",
                "S1",
                block.timestamp + 20,
                15
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "Should have been able to add a consecutive segment with proper values"
        );

        try
            trainsContract.addConsecutiveSegment(
                "CS3",
                "T3",
                "S1",
                "S2",
                block.timestamp + 20,
                10
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not have been able to add a consecutive segment with non-existent train"
        );

        try
            trainsContract.addConsecutiveSegment(
                "CS3",
                "T1",
                "S3",
                "S4",
                block.timestamp + 20,
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
            "Should not have been able to add a consecutive segment with non-existent stations"
        );

        try
            trainsContract.addConsecutiveSegment(
                "CS3",
                "T1",
                "S2",
                "S2",
                block.timestamp + 20,
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
            "Should not have been able to add a consecutive segment with a trip from a station to the same station."
        );
    }

    function testAddOrRemoveFromBlacklist() public {
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
            true,
            "The owner should be able to add or remove a user from the blacklist"
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
            true,
            "The owner should be able to add or remove a user from the blacklist"
        );
        try
            trainsContract.removeFromBlacklist(
                0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "The owner should be able to add or remove a user from the blacklist"
        );
    }

    //TODO
    function testRefundsCalculatedCorrectlyBasedOnDelay() public {
        uint256 initialBalance = address(trainsOracle).balance;

        // Simulate delay and set arrival time
        trainsOracle.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicSegment1",
            block.timestamp + 2000
        );

        uint256 finalBalance = address(trainsOracle).balance;

        // Suppose the expected refund per ticket is 0.01 Ether
        uint256 expectedRefundAmount = 0.01 ether;

        // Calculate the actual refunded amount
        uint256 actualRefundAmount = initialBalance - finalBalance;

        // Check if the actual refund amount is correct
        Assert.equal(
            actualRefundAmount,
            expectedRefundAmount,
            "Refund amount calculated incorrectly based on delay"
        );
    }

    //TODO
    function testRefundsTransferredCorrectlyToUserAddresses() public {
        uint256 initialBalance = address(this).balance;
        //buy ticket before
        //then check the refund
        //be sure that the contract has enough funds to refund

        trainsOracle.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicSegment1",
            block.timestamp + 2000
        );
        uint256 finalBalance = address(this).balance;
        Assert.equal(
            finalBalance > initialBalance,
            true,
            "Refunds were not transferred correctly to user addresses"
        );
    }

    //TODO
    function testOnlyOwnerCanModifyArrivalTime() public {
        (bool success, ) = address(trainsOracle).call(
            abi.encodeWithSignature(
                "modifyArrivalTime(uint256)",
                block.timestamp + 2 hours
            )
        );
        Assert.equal(
            success,
            false,
            "Only the owner should be able to modify the arrival time"
        );
    }

    //TODO
    function testModifiedArrivalTimeIsSavedCorrectly() public {
        uint256 newTime = block.timestamp + 2 hours;
        trainsOracle.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicConsecutiveSegment1",
            newTime
        );

        (
            string memory consecutiveSegmentId,
            uint16 passengersNumber,
            uint256 actualArrivalTime,
            bool isSet
        ) = trainsOracle.dynamicConsecutiveSegments(
                "dynamicConsecutiveSegment1"
            );

        TrainsOracle.DynamicConsecutiveSegment memory segment = TrainsOracle
            .DynamicConsecutiveSegment(
                consecutiveSegmentId,
                passengersNumber,
                actualArrivalTime,
                isSet
            );

        uint256 savedTime = segment._actualArrivalTime;
        Assert.equal(
            savedTime,
            newTime,
            "Modified arrival time was not saved correctly"
        );
    }

    //Leave as last function since it transfer ownership of the contract
    function testOwnershipTransfer() public {
        address newOwner = TestsAccounts.getAccount(10);
        trainsContract.setOwner(newOwner);
        address contractOwner = trainsContract.trainCompanyAddress;
        Assert.equal(
            newOwner,
            contractOwner,
            "The owner address should be set correctly during ownership transfer"
        );
    }
}

contract testUser1 {
    address trainOracleAddressString = "";
    TrainsOracle trainsContract;
    address user;

    function beforeAll() public {
        user = TestsAccounts.getAccount(1);

        trainsContract = TrainsOracle(address(trainOracleAddress));
    }

    function beforeEach() public {}

    function testNonOwnerPermissions() public {
        bool success = true;

        try trainsOracle.addTrain("T2", "Slow Train", 50) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a train"
        );

        try trainsOracle.addStation("S3") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a station"
        );

        try trainsOracle.addStation("S4") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");

        try
            trainsOracle.addConsecutiveSegment(
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

        try trainsOracle.addDynamicConsecutiveSegment("DCS2", "CS2") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Non-owner should not be able to add a dynamic consecutive segment"
        );

        try trainsOracle.addDynamicSegment("DS2") {
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
            trainsOracle.addDynamicConsecutiveSegmentToDynamicSegment(
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

        address newOwner = user;
        try trainsOracle.setOwner(user) {
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

    //TODO
    function testCalculateTotalTicketPrice() public {
        uint32 calculatedPrice = trainsOracle.buyTicketStep("ticket1", "DS1"); //buyticketstep is internal not callable

        uint32 expectedPrice = 10;

        Assert.equal(
            calculatedPrice,
            expectedPrice,
            "Total ticket price calculated is incorrect"
        );
    }

    function testUserShouldNotAddOrRemoveFromBlacklist() public {
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

    //TODO
    function testCannotBuyTicketIfTrainIsFull() public {
        (bool success, ) = address(trainsOracle).call(
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
        (bool success, ) = address(trainsOracle).call{value: 50}(
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

contract testUser2 {
    address trainOracleAddressString = "";
    TrainsOracle trainsContract;
    address user;

    //Could be useful for debugging
    //event LogAccount(string description, address account);
    //emit LogAccount("User: ", user);

    function beforeAll() public {
        user = TestsAccounts.getAccount(2);

        trainsContract = TrainsOracle(address(trainOracleAddress));
    }

    function beforeEach() public {}

    function testUserInBlacklistCannotBuyTicket() public {
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
