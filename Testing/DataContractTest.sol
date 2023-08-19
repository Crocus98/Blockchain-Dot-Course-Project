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

    /// #sender: account_0
    function testAddTrain() public {
        string memory trainId = "Train1";
        string memory trainName = "Fast Train";
        uint16 maxPassengersNumber = 100;
        trainsOracle.addTrain(trainId, trainName, maxPassengersNumber);

        string memory returnedTrainName;
        uint16 returnedMaxPassengers;
        bool isSet;

        (returnedTrainName, returnedMaxPassengers, isSet) = trainsOracle.trains(trainId);

        Assert.equal(returnedTrainName, trainName, "The train name should match");
        Assert.equal(returnedMaxPassengers, maxPassengersNumber, "The max passengers number should match");
        Assert.equal(isSet, true, "The train should be set");
    }

    /// #sender: account_1
    function testOnlyOwnerCanAddTrain() public {
        string memory trainId = "Train2";
        string memory trainName = "Slow Train";
        uint16 maxPassengersNumber = 50;

        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addTrain(string,string,uint16)", trainId, trainName, maxPassengersNumber));
        Assert.equal(success, false, "Only the owner should be able to add trains");

    }

    function testAddStation() public {
        string memory stationId = "ST001";
        trainsOracle.addStation(stationId);
        Assert.equal(trainsOracle.stations(stationId), true, "The station should be added");
    }

    function testOnlyOwnerCanAddStation() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addStation(string)", "ST002"));
        Assert.equal(success, false, "Only the owner should be able to add a station");
    }


}
