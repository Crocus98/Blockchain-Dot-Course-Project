// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// This import is automatically injected by Remix

import "remix_tests.sol";

// This import is required to use custom transaction context

// Although it may fail compilation in 'Solidity Compiler' plugin

// But it will work fine in 'Solidity Unit Testing' plugin

import "remix_accounts.sol";

import "../Tests/DataContract_test.sol";

import "SmartContracts/DataContract.sol"; // Assicurati che il percorso sia corretto

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts

contract testSuite {
    TrainsOracle trainsOracle;

    address payable trainCompanyAddress;

    address acc0; // owner

    address acc1; // non-owner

    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);

        acc1 = TestsAccounts.getAccount(1);

        trainsOracle = new TrainsOracle();
    }

    /// #sender: acc0

    function testAddTrain() public {
        string memory trainId = "Train1";

        string memory trainName = "Fast Train";

        uint16 maxPassengersNumber = 100;

        trainsOracle.addTrain(trainId, trainName, maxPassengersNumber);

        string memory returnedTrainName;

        uint16 returnedMaxPassengers;

        bool isSet;

        (returnedTrainName, returnedMaxPassengers, isSet) = trainsOracle.trains(
            trainId
        );

        Assert.equal(
            returnedTrainName,
            trainName,
            "The train name should match"
        );

        Assert.equal(
            returnedMaxPassengers,
            maxPassengersNumber,
            "The max passengers number should match"
        );

        Assert.equal(isSet, true, "The train should be set");
    }

    /// #sender: acc1

    function testOnlyOwnerCanAddTrain() public {
        string memory trainId = "Train2";

        string memory trainName = "Slow Train";

        uint16 maxPassengersNumber = 50;

        trainsOracle.addTrain(trainId, trainName, maxPassengersNumber);

        string memory returnedTrainName;

        uint16 returnedMaxPassengers;

        bool isSet;

        (returnedTrainName, returnedMaxPassengers, isSet) = trainsOracle.trains(
            trainId
        );

        Assert.equal(isSet, false, "The train should be set");
    }

    function testAddStation() public {
        string memory stationId = "ST001";

        trainsOracle.addStation(stationId);

        Assert.equal(
            trainsOracle.stations(stationId),
            true,
            "The station should be added"
        );
    }

    function testOnlyOwnerCanAddStation() public {
        (bool success, ) = address(trainsOracle).call(
            abi.encodeWithSignature("addStation(string)", "ST002")
        );

        Assert.equal(
            success,
            false,
            "Only the owner should be able to add a station"
        );
    }

    function testAddConsecutiveSegment() public {
        string memory consecutiveSegmentId = "CS001";

        string memory trainId = "TR001";

        string memory startingStationId = "ST001";

        string memory arrivingStationId = "ST002";

        uint256 expectedArrivalTime = block.timestamp + 1 days;

        uint32 expectedPrice = 1000;

        trainsOracle.addTrain(trainId, "Express", 300);

        trainsOracle.addStation(startingStationId);

        trainsOracle.addStation(arrivingStationId);

        trainsOracle.addConsecutiveSegment(
            consecutiveSegmentId,
            trainId,
            startingStationId,
            arrivingStationId,
            expectedArrivalTime,
            expectedPrice
        );

        (
            string memory actualTrainId,
            string memory actualStartingStationId,
            string memory actualArrivingStationId,
            uint256 actualArrivalTime,
            uint32 actualPrice,
            bool isSet
        ) = trainsOracle.consecutiveSegments(consecutiveSegmentId);

        Assert.equal(actualTrainId, trainId, "Train ID mismatch");

        Assert.equal(
            actualStartingStationId,
            startingStationId,
            "Starting Station ID mismatch"
        );

        Assert.equal(
            actualArrivingStationId,
            arrivingStationId,
            "Arriving Station ID mismatch"
        );

        Assert.equal(
            actualArrivalTime,
            expectedArrivalTime,
            "Arrival Time mismatch"
        );

        Assert.equal(actualPrice, expectedPrice, "Price mismatch");

        Assert.equal(isSet, true, "Segment should be set");
    }

    function testOnlyOwnerCanAddConsecutiveSegment() public {
        (bool success, ) = address(trainsOracle).call(
            abi.encodeWithSignature(
                "addConsecutiveSegment(string,string,string)",
                "CS002",
                "ST002",
                "ST003"
            )
        );

        Assert.equal(
            success,
            false,
            "Only the owner should be able to add a consecutive segment"
        );
    }

    function testCannotAddConsecutiveSegmentWithNonExistentStations() public {
        (bool success, ) = address(trainsOracle).call(
            abi.encodeWithSignature(
                "addConsecutiveSegment(string,string,string)",
                "CS003",
                "ST099",
                "ST100"
            )
        );

        Assert.equal(
            success,
            false,
            "Should not be able to add a consecutive segment with non-existent stations"
        );
    }

    function testAddDynamicConsecutiveSegment() public {
        string memory dynamicConsecutiveSegmentId = "DCS001";

        string memory consecutiveSegmentId = "CS001";

        trainsOracle.addDynamicConsecutiveSegment(
            dynamicConsecutiveSegmentId,
            consecutiveSegmentId
        );

        // Simulate retrieving the dynamic consecutive segment from the mapping and verify it has been saved correctly

        (
            string memory actualConsecutiveSegmentId,
            uint16 actualPassengersNumber,
            uint256 actualActualArrivalTime,
            bool actualIsSet
        ) = trainsOracle.dynamicConsecutiveSegments(
                dynamicConsecutiveSegmentId
            );

        Assert.equal(
            actualConsecutiveSegmentId,
            consecutiveSegmentId,
            "The consecutive segment ID does not match"
        );

        Assert.equal(
            actualPassengersNumber,
            uint16(0),
            "Initial passengers number is not set to 0"
        );

        Assert.equal(
            actualActualArrivalTime,
            uint256(0),
            "Initial actual arrival time is not set to 0"
        );

        Assert.equal(
            actualIsSet,
            true,
            "The dynamic consecutive segment should be set to true"
        );
    }

    function testOnlyOwnerCanAddDynamicConsecutiveSegment() public {
        (bool success, ) = address(trainsOracle).call(
            abi.encodeWithSignature(
                "addDynamicConsecutiveSegment(string)",
                "DCS002"
            )
        );

        Assert.equal(
            success,
            false,
            "Only the owner should be able to add a dynamic consecutive segment"
        );
    }

    function testUserInBlacklistCannotBuyTicket() public {
        address user = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        trainsOracle.addToBlacklist(user);

        (bool success, ) = address(trainsOracle).call(
            abi.encodeWithSignature(
                "buyDynamicTicket(string,string[])",
                "ticket1",
                new string[](1)
            )
        );

        Assert.equal(success, false, "Blacklisted user could buy a ticket");
    }

    function testCalculateTotalTicketPrice() public {
        string[] memory segments = new string[](1);

        segments[0] = "segment1";

        uint32 price = trainsOracle.buyTicketStep("ticket1", segments[0]);

        Assert.equal(price, 100, "Total ticket price calculated is incorrect");
    }

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

    function testBuyDynamicTicketWithSufficientEther() public {
        string[] memory segments = new string[](1);

        segments[0] = "segment1";

        (bool success, ) = address(trainsOracle).call{value: 200}(
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

    function testRefundsTransferredCorrectlyToUserAddresses() public {
        uint256 initialBalance = address(this).balance;

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

    function testOnlyOwnerCanAddOrRemoveFromBlacklist() public {
        (bool success, ) = address(trainsOracle).call(
            abi.encodeWithSignature(
                "addToBlacklist(address)",
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
            )
        );

        Assert.equal(
            success,
            false,
            "Only the owner should be able to add or remove a user from the blacklist"
        );
    }

    function testUserCannotBuyTicketWhenAddedToBlacklist() public {
        address user = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        trainsOracle.addToBlacklist(user);

        string[] memory segments = new string[](1);

        segments[0] = "segment1";

        (bool success, ) = address(user).call(
            abi.encodeWithSignature(
                "buyDynamicTicket(string,string[])",
                "ticket1",
                segments
            )
        );

        Assert.equal(success, false, "Blacklisted user could buy a ticket");
    }

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

    function testOnlyOwnerCanExecuteFunctionsRequiringOnlyOwner() public {
        address nonOwner = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        (bool success, ) = address(nonOwner).call(
            abi.encodeWithSignature("addToBlacklist(address)", nonOwner)
        );

        Assert.equal(
            success,
            false,
            "Non-owner could execute function requiring onlyOwner"
        );
    }

    function testContractInitialization() public {
        address owner = trainsOracle.owner();

        Assert.equal(
            owner,
            trainCompanyAddress,
            "The owner address should be set correctly during contract creation"
        );
    }
}
