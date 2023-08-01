// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

//Contract that gives data about trains
contract TrainsOracle{
    address payable public trainCompany;
    string public trainCompanyName = "ItalyTrains";

    //event mttq o signalR
    struct Station {
        string _stationName;
        bool _stationState;
    }
    mapping (uint32 => Station) stations;

    struct Train {
        string _trainName;
        uint16 _passengersNumber;
        bool _trainState;
        uint32 [] _stationsId;
    }
    mapping (uint32 => Train) trains;

    struct Segment {
        uint32 _trainId;

        uint32 _startingStationId;
        uint32 _arrivingStationId;

        uint32 _segmentPrice;

        uint256 _segmentStartingTime;
        uint256 _segmentEndingTime;
    }
    mapping (uint256 => Segment) segments;

    struct Ticket {
        uint256 _segmentId;
        uint256 _segmentActualEndingTime;
        bool valid;
    }
    mapping (uint256 => Ticket) tickets;

    struct Trip {
        uint256 [] _ticketIds;
    }
    mapping (address=>Trip) trips;


    constructor() {
        trainCompany = payable(msg.sender);
    }

    event TrainArrivalEvent(
        uint _trainId,
        uint _tripId,
        uint _stepId,
        address _sender
    );


}