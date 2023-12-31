// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@tests";
import "@accounts";
//import "remix_accounts.sol";
//import "remix_tests.sol";

import "SmartContracts/DataContract.sol";

contract Test1 {
    address public owner;
    TrainsOracle trainsContract;

    uint256 arrivalTimeOffset = 1704067200 + 30 minutes;
    uint256 arrivalDay = arrivalTimeOffset - (arrivalTimeOffset % 1 days);

    function beforeAll() public {
        owner = address(this);
        trainsContract = new TrainsOracle();
    }

    function beforeEach() public {}

    //TEST FOR OWNER
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
                arrivalTimeOffset,
                5000000000000000000
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
                arrivalTimeOffset + 30 minutes,
                3000000000000000000
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
            trainsContract.addDynamicConsecutiveSegment(
                "DCS1",
                "CS1",
                arrivalDay
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "Owner should be able to add a dynamic consecutive segment"
        );

        try
            trainsContract.addDynamicConsecutiveSegment(
                "DCS2",
                "CS2",
                arrivalDay
            )
        {
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
                10 hours,
                10000000000000000000
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
                10 hours,
                200000000000000000
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
                10 hours,
                10000000000000000000
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
                10 hours,
                10000000000000000000
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
                10 hours,
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
        try
            trainsContract.addDynamicConsecutiveSegment(
                "DCS3",
                "CS3",
                arrivalDay
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not have been able to add a dynamic consecutive segment without a corresponding static one"
        );

        try
            trainsContract.addDynamicConsecutiveSegment(
                "DCS3",
                "CS2",
                arrivalDay + 30 minutes
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not have been able to add a dynamic consecutive segment with an arrival time that is not a multiple of 1 day"
        );

        try
            trainsContract.addDynamicConsecutiveSegment(
                "DCS3",
                "CS2",
                block.timestamp - 2000
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not have been able to add a dynamic consecutive segment with an arrival in the past"
        );
    }

    function testCannotAddDCStoDSWithWrongParams() public {
        bool success = false;
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
            false,
            "Should not be able to add a dynamic consecutive segment to a dynamic segment twice"
        );

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

    /// #sender: account-0
    /// #value: 20000000000000000000
    function testCannotBuyTicketWithInsufficientFundsOrWrongParams() public {
        bool success = true;
        string[] memory dynamicSegmentsIds = new string[](1);
        dynamicSegmentsIds[0] = "DS1";
        try
            trainsContract.buyDynamicTicket{value: 3000000000000000000}(
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
            trainsContract.buyDynamicTicket{value: 8000000000000000000}(
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

    /// #sender: account-0
    /// #value: 10000000000000000000
    function testBuyTicket() public payable {
        bool success = true;
        string[] memory dynamicSegmentsIds = new string[](1);
        dynamicSegmentsIds[0] = "DS1";
        try
            trainsContract.buyDynamicTicket{value: 9000000000000000000}(
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

    /// #sender: account-0
    /// #value: 10000000000000000000
    function testBuyTicketThatAlreadyExist() public {
        bool success = true;
        string[] memory dynamicSegmentsIds = new string[](1);
        dynamicSegmentsIds[0] = "DS1";
        try
            trainsContract.buyDynamicTicket{value: 9000000000000000000}(
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
        uint256 simulatedArrivalTime = arrivalDay + 4000;
        //uint256 initialBalance = address(this).balance;
        trainsContract.setArrivalTimeAndCheckRequiredRefunds(
            "DCS1",
            simulatedArrivalTime - 2000
        );
        trainsContract.setArrivalTimeAndCheckRequiredRefunds(
            "DCS2",
            simulatedArrivalTime
        );
        //uint256 finalBalance = address(this).balance;

        (, , , uint256 arrivalTimeOffsetForRefund, , ) = trainsContract
            .consecutiveSegments("CS2");
        (, , uint256 arrivalDayForRefund, , ) = trainsContract
            .dynamicConsecutiveSegments("DCS2");

        uint256 delay = simulatedArrivalTime >
            (arrivalTimeOffsetForRefund + arrivalDayForRefund)
            ? simulatedArrivalTime -
                (arrivalTimeOffsetForRefund + arrivalDayForRefund)
            : 0;

        uint32 refundPercentage;
        if (delay == 0) {
            refundPercentage = 0;
        } else if (delay <= 600) {
            refundPercentage = 20;
        } else if (delay <= 1800) {
            refundPercentage = 50;
        } else {
            refundPercentage = 100;
        }

        uint256 ticketPrice = trainsContract.dynamicSegmentPrices("DS1");
        uint256 expectedRefundAmount = (ticketPrice * refundPercentage) / 100;
        uint256 actualRefundAmount = trainsContract.refunds(address(this));

        Assert.equal(
            actualRefundAmount,
            expectedRefundAmount,
            "Refund amount calculated incorrectly based on delay"
        );
    }

    /// #sender: account-0
    /// #value: 10000000000000000000
    function testCannotBuyTicketWithoutSpace() public {
        bool success = true;
        string[] memory consecutiveSegmentsIds = new string[](1);
        consecutiveSegmentsIds[0] = "CS1";
        try
            trainsContract.buyDynamicTicket{value: 9000000000000000000}(
                "TKT2",
                consecutiveSegmentsIds
            )
        {
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
}
