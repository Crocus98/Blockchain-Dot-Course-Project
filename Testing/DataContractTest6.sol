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


    function testOnlyOwnerCanModifyArrivalTime() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("modifyArrivalTime(uint256)", block.timestamp + 2 hours));
        Assert.equal(success, false, "Only the owner should be able to modify the arrival time");
    }

    function testModifiedArrivalTimeIsSavedCorrectly() public {
        uint256 newTime = block.timestamp + 2 hours;
        trainsOracle.setArrivalTimeAndCheckRequiredRefunds("dynamicConsecutiveSegment1", newTime);
        
        (string memory consecutiveSegmentId, uint16 passengersNumber, uint256 actualArrivalTime, bool isSet) 
        = trainsOracle.dynamicConsecutiveSegments("dynamicConsecutiveSegment1");

        TrainsOracle.DynamicConsecutiveSegment memory segment 
        = TrainsOracle.DynamicConsecutiveSegment(consecutiveSegmentId, passengersNumber, actualArrivalTime, isSet);
        
        uint256 savedTime = segment._actualArrivalTime;
        Assert.equal(savedTime, newTime, "Modified arrival time was not saved correctly");
    }


    function testOnlyOwnerCanExecuteFunctionsRequiringOnlyOwner() public {
        address nonOwner = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        
        (bool success,) = address(nonOwner).call(abi.encodeWithSignature("addToBlacklist(address)", nonOwner));
        Assert.equal(success, false,"Non-owner could execute function requiring onlyOwner");
    }


    function testContractInitialization() public {
        address owner = trainsOracle.owner();
        Assert.equal(owner, trainCompanyAddress, "The owner address should be set correctly during contract creation");
    }

}
