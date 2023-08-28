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
        uint256 _arrivalTimeOffset;
        uint256 _price;
        bool _isSet;
    }
    mapping(string => ConsecutiveSegment) public consecutiveSegments;

    struct DynamicConsecutiveSegment {
        string _consecutiveSegmentId;
        uint16 _passengersNumber;
        uint256 _arrivalDay;
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
    mapping(string => uint256) public dynamicSegmentPrices;

    struct DynamicTicket {
        string[] _dynamicSegmentIds;
        bool _isSet;
    }
    mapping(string => DynamicTicket) public dynamicTickets;

    mapping(address => uint256) public refunds;

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

    receive() external payable {}

    fallback() external payable {}

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
        uint256 arrivalTimeOffset,
        uint256 price
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
        consecutiveSegments[consecutiveSegmentId] = ConsecutiveSegment(
            trainId,
            startingStationId,
            arrivingStationId,
            arrivalTimeOffset,
            price,
            true
        );
    }

    function addDynamicConsecutiveSegment(
        string calldata dynamicConsecutiveSegmentId,
        string calldata consecutiveSegmentId,
        uint256 arrivalDay
    ) public onlyOwner {
        require(
            consecutiveSegments[consecutiveSegmentId]._isSet,
            "Consecutive segment does not exist"
        );
        uint256 time = block.timestamp;
        require(
            arrivalDay >= time - (time % 1 days) && arrivalDay % 1 days == 0,
            "Arrival day cannot be in the past and must be a multiple of 1 day"
        );
        dynamicConsecutiveSegments[
            dynamicConsecutiveSegmentId
        ] = DynamicConsecutiveSegment(
            consecutiveSegmentId,
            0,
            arrivalDay,
            0,
            true
        );
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
    ) internal notBlacklisted returns (uint256) {
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
                currentPassengersCount < maxPassengers,
                "The train has not enough space available"
            );
            dynamicConsecutiveSegments[
                dynamicSegments[dynamicSegmentId]._dynamicConsecutiveSegmentIds[
                    i
                ]
            ]._passengersNumber++;
        }

        dynamicSegments[dynamicSegmentId]._passengerAddresses.push(msg.sender);

        dynamicTickets[ticketId]._dynamicSegmentIds.push(dynamicSegmentId);

        return dynamicSegmentPrices[dynamicSegmentId];
    }

    function buyDynamicTicket(
        string calldata ticketId,
        string[] calldata dynamicSegmentsIds
    ) public payable notBlacklisted {
        require(!dynamicTickets[ticketId]._isSet, "Ticket already sold");
        dynamicTickets[ticketId] = DynamicTicket(new string[](0), true);
        uint256 totalPrice = 0;
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

        uint256 arrivalTime = consecutiveSegments[
            dynamicConsecutiveSegments[dynamicConsecutiveSegmentId]
                ._consecutiveSegmentId
        ]._arrivalTimeOffset +
            dynamicConsecutiveSegments[dynamicConsecutiveSegmentId]._arrivalDay;

        uint256 delay = 0;
        if (actualArrivalTime > arrivalTime) {
            delay = actualArrivalTime - arrivalTime;
        }

        string[]
            memory affectedDynamicSegmentIds = lastDynamicConsecutiveSegmentIdToDynamicSegmentIds[
                dynamicConsecutiveSegmentId
            ];

        if (delay == 0 || affectedDynamicSegmentIds.length == 0) {
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

        for (uint i = 0; i < affectedDynamicSegmentIds.length; i++) {
            address[] memory passengerAddresses = dynamicSegments[
                affectedDynamicSegmentIds[i]
            ]._passengerAddresses;
            if (passengerAddresses.length == 0) {
                continue;
            }
            uint256 originalSegmentPrice = dynamicSegmentPrices[
                affectedDynamicSegmentIds[i]
            ];
            for (uint j = 0; j < passengerAddresses.length; j++) {
                address passenger = passengerAddresses[j];

                uint256 refundAmount = (originalSegmentPrice *
                    refundPercentage) / 100;
                //payable(passenger).transfer(refundAmount);
                refunds[passenger] += refundAmount;
            }
        }
    }

    function getRefund() public notBlacklisted {
        uint256 refundAmount = refunds[msg.sender];
        require(refundAmount > 0, "No refund available");
        refunds[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }
}
