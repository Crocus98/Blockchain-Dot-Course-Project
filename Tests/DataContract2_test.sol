// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@tests";
import "@accounts";
//import "remix_accounts.sol";
//import "remix_tests.sol";

import "SmartContracts/DataContract.sol";
import "Tests/DataContractTestUser.sol";

contract Test2 {
    address public owner;
    TestUser1 testUser1;
    TestUser2 testUser2;
    TrainsOracle trainsContract;

    function beforeAll() public {
        owner = address(this);
        trainsContract = new TrainsOracle();
        testUser1 = new TestUser1(payable(trainsContract));
        testUser2 = new TestUser2(payable(trainsContract));
    }

    function beforeEach() public {}

    function testAddOrRemoveFromBlacklist() public {
        bool success = true;
        try trainsContract.addToBlacklist(address(testUser1)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "The owner should be able to add or remove a user from the blacklist"
        );
        try trainsContract.removeFromBlacklist(address(testUser1)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "The owner should be able to add or remove a user from the blacklist"
        );
        try trainsContract.addToBlacklist(address(testUser2)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            true,
            "The owner should be able to add or remove a user from the blacklist"
        );
    }

    function testCannotSetActualArrivalTimeOfNonExistentSegment() public {
        bool success = true;
        uint256 simulatedArrivalTime = block.timestamp + 5 hours;
        try
            trainsContract.setArrivalTimeAndCheckRequiredRefunds(
                "DCS3",
                simulatedArrivalTime - 2000
            )
        {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(
            success,
            false,
            "Should not be able to set the actual arrival time for a non existent CS"
        );
    }

    function testOwnershipTransfer() public {
        address newOwner = TestsAccounts.getAccount(10);
        trainsContract.setNewOwner(newOwner);
        address contractOwner = trainsContract.trainCompanyAddress();
        Assert.equal(
            newOwner,
            contractOwner,
            "The owner address should be set correctly during ownership transfer"
        );
    }

    //TEST FOR USER 1
    function testUserNonOwnerPermissions() public {
        testUser1.testUserNonOwnerPermissions();
    }

    //TEST FOR USER 2
    function testUserInBlacklistCannotBuyTicketOrGetRefund() public {
        testUser2.testUserInBlacklistCannotBuyTicketOrGetRefund();
    }
}
