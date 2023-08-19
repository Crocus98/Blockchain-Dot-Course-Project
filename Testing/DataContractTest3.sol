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

    function testOnlyOwnerCanAddConsecutiveSegment() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addConsecutiveSegment(string,string,string)", "CS002", "ST002", "ST003"));
        Assert.equal(success, false, "Only the owner should be able to add a consecutive segment");
    }

    function testCannotAddConsecutiveSegmentWithNonExistentStations() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addConsecutiveSegment(string,string,string)", "CS003", "ST099", "ST100"));
        Assert.equal(success, false, "Should not be able to add a consecutive segment with non-existent stations");
    }

    function testAddDynamicConsecutiveSegment() public {
        string memory dynamicConsecutiveSegmentId = "DCS001";
        string memory consecutiveSegmentId = "CS001";
        
        trainsOracle.addDynamicConsecutiveSegment(dynamicConsecutiveSegmentId, consecutiveSegmentId);
        
        // Simulate retrieving the dynamic consecutive segment from the mapping and verify it has been saved correctly
        (string memory actualConsecutiveSegmentId, 
        uint16 actualPassengersNumber, 
        uint256 actualActualArrivalTime, 
        bool actualIsSet) = trainsOracle.dynamicConsecutiveSegments(dynamicConsecutiveSegmentId);
        
        Assert.equal(actualConsecutiveSegmentId, consecutiveSegmentId, "The consecutive segment ID does not match");
        Assert.equal(actualPassengersNumber, uint16(0), "Initial passengers number is not set to 0");
        Assert.equal(actualActualArrivalTime, uint256(0), "Initial actual arrival time is not set to 0");
        Assert.equal(actualIsSet, true, "The dynamic consecutive segment should be set to true");
    }

}
