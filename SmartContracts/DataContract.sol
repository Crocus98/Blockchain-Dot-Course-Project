// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

//Contract that gives data about trains
contract TrainsOracle{
    address payable public trainCompanyAddress;
    string public trainCompanyName = "ItalyTrains";

    //event mttq o signalR
    struct Station {
        string _stationName;
        bool _stationState;
        bool _isSet;
    }
    mapping (string => Station) stations;

    struct Train {
        string _trainName;
        uint16 _passengersNumber;
        bool _trainState;
        string [] _stationIds;
        bool _isSet;
    }
    mapping (string => Train) trains;

    struct Segment {
        uint32 _trainId;

        uint32 _startingStationId;
        uint32 _arrivingStationId;

        uint32 _segmentPrice;

        uint256 _segmentStartingTime;
        uint256 _segmentEndingTime;

        bool _isSet;
    }
    mapping (string => Segment) segments;

    struct Path {
        uint256 _segmentId;
        uint256 _segmentActualEndingTime;
        bool _valid;

        bool _isSet;
    }
    mapping (string => Path) paths;
    mapping(uint256 => address[]) customers;

    struct Trip {
        uint32 _tripId;
        uint256 [] _pathIds;

    }
    mapping (address=>Trip[]) trips;

    event TrainArrivalEvent(
        uint _trainId,
        uint _tripId,
        uint _stepId,
        address _sender
    );

    constructor() {
        trainCompanyAddress = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == trainCompanyAddress, string.concat(string.concat("Only ",trainCompanyName)," can call this function"));
        _;
    }

    function addStation(string calldata stationId, string calldata stationName, bool stationState) public onlyOwner {
        stations[stationId] = Station(stationName, stationState,true);
    }

    function addTrain(string calldata trainId, string memory trainName, uint16 passengersNumber, bool trainState) public onlyOwner {
        trains[trainId] = Train(trainName, passengersNumber, trainState, new string[](0),true);
    }

    function addTrainStations(string calldata trainId, string calldata stationId) public onlyOwner{
        require(trains[trainId]._isSet, "Trains does not exist");
        require(stations[stationId]._isSet,"Station does not exists");
        trains[trainId]._stationIds.push(stationId);
    }

}