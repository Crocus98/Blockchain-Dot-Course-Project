// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

//Contract that gives data about trains
contract TrainsOracle{
    address payable public trainCompanyAddress;
    string public trainCompanyName = "ItalyTrains";

    //event mttq o signalR

    //for blaclisting bad passengers
    mapping(address => bool) public blackList;

    struct Train {
        string _trainName;
        uint16 _maxPassengersNumber;
        bool _isSet;
    }
    mapping (string => Train) public trains;

    mapping (string => bool) public stations;

    struct ConsecutiveSegment{
        string _trainId;

        string _startingStationId;
        string _arrivingStationId;

        uint256 _arrivalTime;

        uint32 _price;
        
        bool _isSet;
    }
    mapping (string => ConsecutiveSegment) public consecutiveSegments;

    struct DynamicConsecutiveSegment{
        string _consecutiveSegmentId;

        uint16 _passengersNumber;

        uint256 _actualArrivalTime;

        bool _isSet;
    }
    mapping (string => DynamicConsecutiveSegment) public dynamicConsecutiveSegments;
    //It maps to the consecutive segments ids all the dynamic segmentsc ids that have the specific consecutive segment as last. 
    mapping(string => string[]) public lastDynamicConsecutiveSegmentIdToDynamicSegmentIds;

    struct DynamicSegment{
        string [] _dynamicConsecutiveSegmentIds;

        address [] _passengerAddresses;

        bool _isSet;
    }
    mapping (string => DynamicSegment) public dynamicSegments;

    struct DynamicTicket {
        string [] _dynamicSegmentIds;

        bool _isSet;
    }
    mapping (string => DynamicTicket) public dynamicTickets;

    modifier onlyOwner {
        require(msg.sender == trainCompanyAddress, string.concat(string.concat("Only ",trainCompanyName)," can call this function"));
        _;
    }

    constructor() {
        trainCompanyAddress = payable(msg.sender);
    }

    function addToBlacklist (address toBlackList) public onlyOwner {
        blackList[toBlackList] = true;
    }

    function removeFromBlacklist (address toBlackList) public onlyOwner {
        blackList[toBlackList] = false;
    }

    function addTrain(string calldata trainId, string calldata trainName, uint16 maxPassengersNumber) public onlyOwner {
        trains[trainId] = Train(trainName, maxPassengersNumber, true);
    }

    function addStation(string calldata stationId) public onlyOwner {
        stations[stationId] = true;
    }


    function addConsecutiveSegment(string calldata consecutiveSegmentId, string calldata trainId, string calldata startingStationId, string calldata arrivingStationId, uint256 arrivalTime, uint32 price) public onlyOwner {
        require(trains[trainId]._isSet, "Train does not exist");
        require(stations[startingStationId],"Starting station does not exist");
        require(stations[arrivingStationId], "Arriving station does not exist");
        require(price > 0, "Price cannot be negative or null");
        require(arrivalTime> block.timestamp, "Arrival time cannot be in the past");
        consecutiveSegments[consecutiveSegmentId] = ConsecutiveSegment(trainId, startingStationId, arrivingStationId, arrivalTime, price, true);
    }

    function addDynamicConsecutiveSegment(string calldata dynamicConsecutiveSegmentId, string calldata consecutiveSegmentId) public onlyOwner {
        require(consecutiveSegments[consecutiveSegmentId]._isSet, "Consecutive segment does not exist");
        dynamicConsecutiveSegments[dynamicConsecutiveSegmentId] = DynamicConsecutiveSegment(consecutiveSegmentId,0, 0, true);
    }

    function addDynamicSegment(string calldata dynamicSegmentId) public onlyOwner {
        dynamicSegments[dynamicSegmentId] = DynamicSegment(new string[](0), new address[](0), true);
    }

    function addDynamicConsecutiveSegmentToDynamicSegment(string calldata dynamicSegmentId, string calldata dynamicConsecutiveSegmentId, bool lastSegmentStop)public onlyOwner{
        require(dynamicSegments[dynamicSegmentId]._isSet, "Dynamic segment does not exist");
        require(dynamicConsecutiveSegments[dynamicConsecutiveSegmentId]._isSet, "Dynamic consecutive segment does not exist");
        dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds.push(dynamicConsecutiveSegmentId);
        if(lastSegmentStop){
            lastDynamicConsecutiveSegmentIdToDynamicSegmentIds[dynamicConsecutiveSegmentId].push(dynamicSegmentId);
        }
    }


    function buyTicketStep(string calldata ticketId, string calldata dynamicSegmentId) public returns (uint32){
        require(dynamicSegments[dynamicSegmentId]._isSet, "Dynamic segment does not exist");
        require(!blackList[msg.sender], "This passenger is blacklisted");

        // Check if there's room on the segment
        uint16 maxPassengers = trains[consecutiveSegments[dynamicConsecutiveSegments[dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds[0]]._consecutiveSegmentId]._trainId]._maxPassengersNumber;
        
        uint32 totalPrice = 0;

        for (uint i = 0; i < dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds.length; i++) {
            uint16 currentPassengersCount = dynamicConsecutiveSegments[dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds[i]]._passengersNumber;
            require(currentPassengersCount <= maxPassengers,"The train has not enought space available");
            totalPrice +=consecutiveSegments[dynamicConsecutiveSegments[dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds[i]]._consecutiveSegmentId]._price;
        }

        // Add the passenger to the dynamic segment
        dynamicSegments[dynamicSegmentId]._passengerAddresses.push(msg.sender);

        // Update the passenger count in dynamicConsecutiveSegment
        for (uint i = 0; i < dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds.length; i++) {
            dynamicConsecutiveSegments[dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds[i]]._passengersNumber++;
        }

        // Update the DynamicTicket for the passenger
        if(!dynamicTickets[ticketId]._isSet) {
            dynamicTickets[ticketId] = DynamicTicket(new string[](0), true);
        }
        
        //Add the segment to the ticket
        dynamicTickets[ticketId]._dynamicSegmentIds.push(dynamicSegmentId);

        return totalPrice;
    }

    function buyDynamicTicket (string calldata ticketId, string [] calldata dynamicSegmentsIds) public payable{
        uint32 totalPrice = 0;
        for (uint i = 0; i < dynamicSegmentsIds.length; i++) {
            totalPrice += this.buyTicketStep(ticketId, dynamicSegmentsIds[i]);
        }
        require(msg.value >= totalPrice, "Not enought money");
    }

    function setArrivalTimeAndCheckRequiredRefunds(string calldata dynamicConsecutiveSegmentId, uint256 actualArrivalTime) public onlyOwner{
        //require dynamicConsecutivesegmentId exists

        //Set dynamicConsecutiveSegemens[dynamicConsecutiveSegmentId] with actualArrivalTime


        //Check that the corresponding non dynamic consecutive segment arrival time is consistent with the actuallArrivalTime
        //If the train is on time end the function otherwise continue...

        //Find all addresses of people that have that dynamicconsecutivesegment as last of a dynamic segment and check for the refund...
        //If the train is late for less than 10 min refund 20% of the segment.
        //If the train is late for more than 10 and less than 30 min refund 50% of the segment.
        //If the train is late for more than 30 min refunt 100% of the segment.
        
        //Check if those people have some other dynamic segments and refund them if the train delay does not allow them to catch the following train.
        //In that case give full refund of all following dynamic segments included into the ticket

    }

}