// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@tests";
import "@accounts";
//import "remix_accounts.sol";
//import "remix_tests.sol";

import "SmartContracts/DataContract.sol";
import "Tests/DataContractTestUser.sol";

contract Test1 {
    address public owner;
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
    function testAddEntitiesWithOwnerPermissions() public {
        bool success = true;

        try trainsContract.addTrain("T1", "Fast Train", 2) {
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
                5
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
                3
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
            "Should not have been able to add a consecutive segment with a null (or negative) price"
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

    function testCannotBuyTicketWithInsufficientFundsOrWrongParams() public {
        bool success = true;
        string[] memory dynamicSegmentsIds = new string[](1);
        dynamicSegmentsIds[0] = "DS1";
        try
            trainsContract.buyDynamicTicket{value: 3}(
                "TKT1",
                dynamicSegmentsIds
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "User should not be able to buy a ticket without paying full price"
        );

        dynamicSegmentsIds[0] = "DS3";
        try
            trainsContract.buyDynamicTicket{value: 8}(
                "TKT1",
                dynamicSegmentsIds
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "User should not be able to buy a ticket for non existent segments"
        );
    }

    function testBuyTicket() public {
        bool success = true;
        string[] memory dynamicSegmentsIds = new string[](1);
        dynamicSegmentsIds[0] = "DS1";
        try
            trainsContract.buyDynamicTicket{value: 9}(
                "TKT1",
                dynamicSegmentsIds
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "User should be able to buy a ticket");
    }

    function testBuyTicketThatAlreadyExist() public {
        bool success = true;
        string[] memory dynamicSegmentsIds = new string[](1);
        dynamicSegmentsIds[0] = "DS1";
        try
            trainsContract.buyDynamicTicket{value: 9}(
                "TKT1",
                dynamicSegmentsIds
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "User should not be able to buy a ticket that already has been already sold"
        );
    }

    function testRefundsCalculatedCorrectly() public {
        uint256 simulatedArrivalTime = internalTimeTest + 4000;
        uint256 initialBalance = address(this).balance;
        trainsContract.setArrivalTimeAndCheckRequiredRefunds(
            "DCS1",
            simulatedArrivalTime - 2000
        );
        trainsContract.setArrivalTimeAndCheckRequiredRefunds(
            "DCS2",
            simulatedArrivalTime
        );
        uint256 finalBalance = address(this).balance;

        (, , , uint256 actualArrivalTime, , ) = trainsContract
            .consecutiveSegments("CS1");

        uint256 delay = simulatedArrivalTime > actualArrivalTime
            ? simulatedArrivalTime - actualArrivalTime
            : 0;
        uint8 refundPercentage;
        if (delay == 0) {
            refundPercentage = 0;
        } else if (delay <= 600) {
            refundPercentage = 20;
        } else if (delay <= 1800) {
            refundPercentage = 50;
        } else {
            refundPercentage = 100;
        }

        uint32 ticketPrice = trainsContract.dynamicSegmentPrices("DS1");
        ticketPrice += trainsContract.dynamicSegmentPrices("DS2");
        uint256 expectedRefundAmount = (ticketPrice * refundPercentage) / 100;
        uint256 actualRefundAmount = initialBalance - finalBalance;

        Assert.equal(
            actualRefundAmount,
            expectedRefundAmount,
            "Refund amount calculated incorrectly based on delay"
        );
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
}
