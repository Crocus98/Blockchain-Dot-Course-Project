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
        trainsOracle.addConsecutiveSegment(consecutiveSegmentId, trainId, startingStationId, arrivingStationId, expectedArrivalTime, expectedPrice);

        (string memory actualTrainId, 
        string memory actualStartingStationId, 
        string memory actualArrivingStationId, 
        uint256 actualArrivalTime, 
        uint32 actualPrice, 
        bool isSet) = trainsOracle.consecutiveSegments(consecutiveSegmentId);

        Assert.equal(actualTrainId, trainId, "Train ID mismatch");
        Assert.equal(actualStartingStationId, startingStationId, "Starting Station ID mismatch");
        Assert.equal(actualArrivingStationId, arrivingStationId, "Arriving Station ID mismatch");
        Assert.equal(actualArrivalTime, expectedArrivalTime, "Arrival Time mismatch");
        Assert.equal(actualPrice, expectedPrice, "Price mismatch");
        Assert.equal(isSet, true, "Segment should be set");
    }

}
