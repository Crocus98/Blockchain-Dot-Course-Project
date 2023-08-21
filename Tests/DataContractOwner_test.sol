// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@tests";
import "@accounts";
//import "remix_accounts.sol";
//import "remix_tests.sol";

import "SmartContracts/DataContract.sol";
import "Tests/DataContractUser.sol";

//Run Owner - User1 - User2 in this order to properly test the contract

contract TestOwner {
    address public owner; //set this only
    address public trainsOracleAddress;
    TestUser1 testUser1;
    TestUser2 testUser2;
    TrainsOracle trainsContract;

    function beforeAll() public {
        owner = address(this);
        trainsContract = new TrainsOracle();
        testUser1 = new TestUser1(trainsOracleAddress);
        testUser2 = new TestUser2(trainsOracleAddress);
        trainsOracleAddress = address(trainsContract);
    }

    function beforeEach() public {}

    //TEST FOR OWNER
    function testOwnerPermissions() public {
        bool success = true;

        try trainsContract.addTrain("T1", "Fast Train", 100) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a train");

        try trainsContract.addStation("S1") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");

        try trainsContract.addStation("S2") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");

        try
            trainsContract.addConsecutiveSegment(
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

        try trainsContract.addDynamicConsecutiveSegment("DCS1", "CS1") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "Owner should be able to add a dynamic consecutive segment"
        );

        try trainsContract.addDynamicSegment("DS1") {
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
            trainsContract.addDynamicConsecutiveSegmentToDynamicSegment(
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
        bool success = false;
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
        bool success = true;
        try trainsContract.addToBlacklist(address(testUser1)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "The owner should be able to add or remove a user from the blacklist"
        );
        try trainsContract.removeFromBlacklist(address(testUser1)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "The owner should be able to add or remove a user from the blacklist"
        );
        try trainsContract.addToBlacklist(address(testUser2)) {
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

    /*//TODO
    function testRefundsCalculatedCorrectlyBasedOnDelay() public {
        uint256 initialBalance = address(trainsContract).balance;

        // Simulate delay and set arrival time
        trainsContract.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicSegment1",
            block.timestamp + 2000
        );

        uint256 finalBalance = address(trainsContract).balance;

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
    }*/

    /*//TODO
    function testRefundsTransferredCorrectlyToUserAddresses() public {
        uint256 initialBalance = address(this).balance;
        //buy ticket before
        //then check the refund
        //be sure that the contract has enough funds to refund

        trainsContract.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicSegment1",
            block.timestamp + 2000
        );
        uint256 finalBalance = address(this).balance;
        Assert.equal(
            finalBalance > initialBalance,
            true,
            "Refunds were not transferred correctly to user addresses"
        );
    }*/

    /*//TODO
    function testOnlyOwnerCanModifyArrivalTime() public {
        (bool success, ) = address(trainsContract).call(
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
    }*/

    /*//TODO
    function testModifiedArrivalTimeIsSavedCorrectly() public {
        uint256 newTime = block.timestamp + 2 hours;
        trainsContract.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicConsecutiveSegment1",
            newTime
        );

        (
            string memory consecutiveSegmentId,
            uint16 passengersNumber,
            uint256 actualArrivalTime,
            bool isSet
        ) = trainsContract.dynamicConsecutiveSegments(
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
    }*/

    //Leave as last function of the owner since it transfer ownership of the contract
    function testOwnershipTransfer() public {
        address newOwner = TestsAccounts.getAccount(10);
        trainsContract.setNewOwner(newOwner);
        address contractOwner = trainsContract.trainCompanyAddress();
        Assert.equal(
            newOwner,
            contractOwner,
            "The owner address should be set correctly during ownership transfer"
        );
    }

    //TEST FOR USER 1
    function testNonOwnerPermissions() public {
        testUser1.testNonOwnerPermissions();
    }

    function testUserShouldNotAddOrRemoveFromBlacklist() public {
        testUser1.testUserShouldNotAddOrRemoveFromBlacklist();
    }

    //TEST FOR USER 2
    function testUserInBlacklistCannotBuyTicket() public {
        testUser2.testUserInBlacklistCannotBuyTicket();
    }
}
