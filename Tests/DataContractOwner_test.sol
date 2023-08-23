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
    TestUser1 testUser1;
    TestUser2 testUser2;
    TrainsOracle trainsContract;

    uint256 internalTimeTest = 1704067200;

    function beforeAll() public {
        owner = address(this);
        trainsContract = new TrainsOracle();
        testUser1 = new TestUser1(address(trainsContract));
        testUser2 = new TestUser2(address(trainsContract));
    }

    function beforeEach() public {}

    //TEST FOR OWNER
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

    function testAddEntitiesWithOwnerPermissions() public {
        bool success = true;

        try trainsContract.addTrain("T1", "Fast Train", 1) {
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

        try trainsContract.addStation("S3") {
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
                internalTimeTest + 1800,
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
            "Owner should be able to add a consecutive segment"
        );

        try
            trainsContract.addConsecutiveSegment(
                "CS2",
                "T1",
                "S2",
                "S3",
                internalTimeTest + 3600,
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

        try trainsContract.addDynamicConsecutiveSegment("DCS2", "CS2") {
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
                false
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

        try
            trainsContract.addDynamicConsecutiveSegmentToDynamicSegment(
                "DS1",
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
            true,
            "Owner should be able to add a dynamic consecutive segment to a dynamic segment"
        );
    }

    function testCannotAddConsecutiveSegmentWithWrongParams() public {
        bool success = false;
        try
            trainsContract.addConsecutiveSegment(
                "CS3",
                "T1",
                "S1",
                "S2",
                internalTimeTest + 20,
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
            "Should not have been able to add a consecutive segment with non-existent consecutive segment"
        );

        try
            trainsContract.addConsecutiveSegment(
                "CS1",
                "T2",
                "S1",
                "S2",
                internalTimeTest + 20,
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
                internalTimeTest + 20,
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
                "S4",
                "S3",
                internalTimeTest + 20,
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
                "CS1",
                "T1",
                "S2",
                "S2",
                internalTimeTest + 20,
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

        try
            trainsContract.addConsecutiveSegment(
                "CS1",
                "T1",
                "S1",
                "S2",
                block.timestamp - 10,
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
            "Should not have been able to add a consecutive segment with an arrival time in the past"
        );

        try
            trainsContract.addConsecutiveSegment(
                "CS1",
                "T1",
                "S1",
                "S2",
                internalTimeTest + 20,
                0
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not have been able to add a consecutive segment with a null price"
        );
    }

    function testCannotAddDynamicConsecutiveSegmenWithWrongParams() public {
        bool success = false;
        try trainsContract.addDynamicConsecutiveSegment("DCS3", "CS3") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not have been able to add a dynamic consecutive segment without a corresponding static one"
        );
    }

    function testCannotAddDCStoDSWithWrongParams() public {
        bool success = false;
        try
            trainsContract.addDynamicConsecutiveSegmentToDynamicSegment(
                "DS1",
                "DCS3",
                false
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not be able to add a non existent DCS to a DS"
        );

        try
            trainsContract.addDynamicConsecutiveSegmentToDynamicSegment(
                "DS2",
                "DCS1",
                false
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not be able to add a DCS to a non existent DS"
        );
    }

    function testBuyTicket() public {
        bool success = true;
        string[] memory consecutiveSegmentsIds = new string[](1);
        consecutiveSegmentsIds[0] = "CS1";
        try trainsContract.buyDynamicTicket("TKT1", consecutiveSegmentsIds) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "User should be able to buy a ticket");
    }

    function testCannotBuyTicketWithoutSpace() public {
        bool success = true;
        string[] memory consecutiveSegmentsIds = new string[](1);
        consecutiveSegmentsIds[0] = "CS1";
        try trainsContract.buyDynamicTicket("TKT2", consecutiveSegmentsIds) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "User should not be able to buy a ticket if the train is full"
        );
    }

    function testRefundCalculatedCorrectly() public {}

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
    function testUserNonOwnerPermissions() public {
        testUser1.testUserNonOwnerPermissions();
    }

    function testUserShouldNotAddOrRemoveFromBlacklist() public {
        testUser1.testUserShouldNotAddOrRemoveFromBlacklist();
    }

    //TEST FOR USER 2
    function testUserInBlacklistCannotBuyTicket() public {
        testUser2.testUserInBlacklistCannotBuyTicket();
    }
}
