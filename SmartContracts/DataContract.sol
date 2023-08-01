// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

//Contract that gives data about trains
contract TrainsOracle{
    address payable public trainCompany;
    string public trainCompanyName = "ItalyTrains";

    struct Trip{
        uint _trainId;
        uint _tripId;
        uint _stepId;
        address _sender;
    }
    //mapping(Trip => uint) private trips;

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