// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract TrainsOracle {
    address public trainCompanyAddress;
    string public trainCompanyName = "ItalyTrains";

    mapping(address => bool) public blackList;

    struct Train {
        string _trainName;
        uint16 _maxPassengersNumber;
        bool _isSet;
    }
    mapping(string => Train) public trains;

    mapping(string => bool) public stations;

    struct ConsecutiveSegment {
        string _trainId;
        string _startingStationId;
        string _arrivingStationId;
        uint256 _arrivalTime;
        uint32 _price;
        bool _isSet;
    }
    mapping(string => ConsecutiveSegment) public consecutiveSegments;

    struct DynamicConsecutiveSegment {
        string _consecutiveSegmentId;
        uint16 _passengersNumber;
        uint256 _actualArrivalTime;
        bool _isSet;
    }
    mapping(string => DynamicConsecutiveSegment)
        public dynamicConsecutiveSegments;
    //It maps to the consecutive segments ids all the dynamic segments ids that have the specific consecutive segment as last.
    mapping(string => string[])
        public lastDynamicConsecutiveSegmentIdToDynamicSegmentIds;

    struct DynamicSegment {
        string[] _dynamicConsecutiveSegmentIds;
        address[] _passengerAddresses;
        bool _isSet;
    }
    mapping(string => DynamicSegment) public dynamicSegments;
    mapping(string => uint32) public dynamicSegmentPrices;

    struct DynamicTicket {
        string[] _dynamicSegmentIds;
        bool _isSet;
    }
    mapping(string => DynamicTicket) public dynamicTickets;

    modifier onlyOwner() {
        require(
            msg.sender == trainCompanyAddress,
            "Only the owner of the contract can call this function"
        );
        _;
    }

    modifier notBlacklisted() {
        require(!blackList[msg.sender], "This passenger is blacklisted");
        _;
    }

    constructor() payable {
        trainCompanyAddress = msg.sender;
    }

    function setNewOwner(address newOwner) public onlyOwner {
        trainCompanyAddress = newOwner;
    }

    function addToBlacklist(address toBlackList) public onlyOwner {
        blackList[toBlackList] = true;
    }

    function removeFromBlacklist(address toBlackList) public onlyOwner {
        blackList[toBlackList] = false;
    }

    function addTrain(
        string calldata trainId,
        string calldata trainName,
        uint16 maxPassengersNumber
    ) public onlyOwner {
        trains[trainId] = Train(trainName, maxPassengersNumber, true);
    }

    function addStation(string calldata stationId) public onlyOwner {
        stations[stationId] = true;
    }

    function addConsecutiveSegment(
        string calldata consecutiveSegmentId,
        string calldata trainId,
        string calldata startingStationId,
        string calldata arrivingStationId,
        uint256 arrivalTime,
        uint32 price
    ) public onlyOwner {
        require(trains[trainId]._isSet, "Train does not exist");
        require(stations[startingStationId], "Starting station does not exist");
        require(stations[arrivingStationId], "Arriving station does not exist");
        require(
            keccak256(bytes(startingStationId)) !=
                keccak256(bytes(arrivingStationId)),
            "Starting station and arriving station cannot be the same"
        );
        require(price > 0, "Price cannot be negative or null");
        require(
            arrivalTime > block.timestamp,
            "Arrival time cannot be in the past"
        );
        consecutiveSegments[consecutiveSegmentId] = ConsecutiveSegment(
            trainId,
            startingStationId,
            arrivingStationId,
            arrivalTime,
            price,
            true
        );
    }

    function addDynamicConsecutiveSegment(
        string calldata dynamicConsecutiveSegmentId,
        string calldata consecutiveSegmentId
    ) public onlyOwner {
        require(
            consecutiveSegments[consecutiveSegmentId]._isSet,
            "Consecutive segment does not exist"
        );
        dynamicConsecutiveSegments[
            dynamicConsecutiveSegmentId
        ] = DynamicConsecutiveSegment(consecutiveSegmentId, 0, 0, true);
    }

    function addDynamicSegment(
        string calldata dynamicSegmentId
    ) public onlyOwner {
        dynamicSegments[dynamicSegmentId] = DynamicSegment(
            new string[](0),
            new address[](0),
            true
        );
    }

    function addDynamicConsecutiveSegmentToDynamicSegment(
        string calldata dynamicSegmentId,
        string calldata dynamicConsecutiveSegmentId,
        bool lastSegmentStop
    ) public onlyOwner {
        require(
            dynamicSegments[dynamicSegmentId]._isSet,
            "Dynamic segment does not exist"
        );
        require(
            dynamicConsecutiveSegments[dynamicConsecutiveSegmentId]._isSet,
            "Dynamic consecutive segment does not exist"
        );
        dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds.push(
            dynamicConsecutiveSegmentId
        );
        if (lastSegmentStop) {
            lastDynamicConsecutiveSegmentIdToDynamicSegmentIds[
                dynamicConsecutiveSegmentId
            ].push(dynamicSegmentId);
        }

        dynamicSegmentPrices[dynamicSegmentId] += consecutiveSegments[
            dynamicConsecutiveSegments[dynamicConsecutiveSegmentId]
                ._consecutiveSegmentId
        ]._price;
    }

    function buyTicketStep(
        string calldata ticketId,
        string calldata dynamicSegmentId
    ) internal notBlacklisted returns (uint32) {
        require(
            dynamicSegments[dynamicSegmentId]._isSet,
            "Dynamic segment does not exist"
        );

        uint16 maxPassengers = trains[
            consecutiveSegments[
                dynamicConsecutiveSegments[
                    dynamicSegments[dynamicSegmentId]
                        ._dynamicConsecutiveSegmentIds[0]
                ]._consecutiveSegmentId
            ]._trainId
        ]._maxPassengersNumber;

        for (
            uint i = 0;
            i <
            dynamicSegments[dynamicSegmentId]
                ._dynamicConsecutiveSegmentIds
                .length;
            i++
        ) {
            uint16 currentPassengersCount = dynamicConsecutiveSegments[
                dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds[
                    i
                ]
            ]._passengersNumber;
            require(
                currentPassengersCount <= maxPassengers,
                "The train has not enough space available"
            );
        }

        dynamicSegments[dynamicSegmentId]._passengerAddresses.push(msg.sender);

        for (
            uint i = 0;
            i <
            dynamicSegments[dynamicSegmentId]
                ._dynamicConsecutiveSegmentIds
                .length;
            i++
        ) {
            dynamicConsecutiveSegments[
                dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds[
                    i
                ]
            ]._passengersNumber++;
        }

        if (!dynamicTickets[ticketId]._isSet) {
            dynamicTickets[ticketId] = DynamicTicket(new string[](0), true);
        }

        dynamicTickets[ticketId]._dynamicSegmentIds.push(dynamicSegmentId);

        return dynamicSegmentPrices[dynamicSegmentId];
    }

    // Add the notBlacklisted modifier to the function signature
    function buyDynamicTicket(
        string calldata ticketId,
        string[] calldata dynamicSegmentsIds
    ) public payable notBlacklisted {
        require(!dynamicTickets[ticketId]._isSet, "Ticket already sold");
        uint32 totalPrice = 0;
        for (uint i = 0; i < dynamicSegmentsIds.length; i++) {
            totalPrice += buyTicketStep(ticketId, dynamicSegmentsIds[i]);
        }
        require(msg.value >= totalPrice, "Not enough money");
    }

    function setArrivalTimeAndCheckRequiredRefunds(
        string calldata dynamicConsecutiveSegmentId,
        uint256 actualArrivalTime
    ) public onlyOwner {
        require(
            dynamicConsecutiveSegments[dynamicConsecutiveSegmentId]._isSet,
            "DynamicConsecutiveSegment does not exist"
        );

        dynamicConsecutiveSegments[dynamicConsecutiveSegmentId]
            ._actualArrivalTime = actualArrivalTime;

        ConsecutiveSegment memory segment = consecutiveSegments[
            dynamicConsecutiveSegments[dynamicConsecutiveSegmentId]
                ._consecutiveSegmentId
        ];

        uint256 delay = 0;
        if (actualArrivalTime > segment._arrivalTime) {
            delay = actualArrivalTime - segment._arrivalTime;
        }

        if (delay == 0) {
            return;
        }

        uint8 refundPercentage;
        if (delay <= 600) {
            refundPercentage = 20;
        } else if (delay <= 1800) {
            refundPercentage = 50;
        } else {
            refundPercentage = 100;
        }

        string[]
            memory affectedDynamicSegmentIds = lastDynamicConsecutiveSegmentIdToDynamicSegmentIds[
                dynamicConsecutiveSegmentId
            ];
        for (uint i = 0; i < affectedDynamicSegmentIds.length; i++) {
            DynamicSegment memory dynamicSegment = dynamicSegments[
                affectedDynamicSegmentIds[i]
            ];
            for (
                uint j = 0;
                j < dynamicSegment._passengerAddresses.length;
                j++
            ) {
                address passenger = dynamicSegment._passengerAddresses[j];
                uint32 segmentPrice = consecutiveSegments[
                    dynamicConsecutiveSegments[
                        dynamicSegments[affectedDynamicSegmentIds[i]]
                            ._dynamicConsecutiveSegmentIds[0]
                    ]._consecutiveSegmentId
                ]._price;
                uint256 refundAmount = (segmentPrice * refundPercentage) / 100;
                payable(passenger).transfer(refundAmount);
            }
        }
    }
}
