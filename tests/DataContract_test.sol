// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;


// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import ".deps/remix-tests/remix_accounts.sol";
import "SmartContracts/DataContract.sol"; // Assicurati che il percorso sia corretto

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    TrainsOracle trainsOracle;
    address payable trainCompanyAddress;
    address acc0;
    address acc1; // non-owner

    event LogAccount(string description, address account);



    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        emit LogAccount("Account 0: ", acc0);
        
        trainsOracle = new TrainsOracle();
        trainCompanyAddress = payable(acc0);  // set acc0 as the owner
        
        acc1 = TestsAccounts.getAccount(1);  // non owner
        emit LogAccount("Account 1: ", acc1);
    }

      function beforeEach() public {
          acc0 = TestsAccounts.getAccount(0);
          emit LogAccount("Account 0: ", acc0);
        
          // trainsOracle = new TrainsOracle();
          trainCompanyAddress = payable(acc0);  // set acc0 as the owner
        
          acc1 = TestsAccounts.getAccount(1);  // non owner
         emit LogAccount("Account 1: ", acc1);
      }


       /// #sender: acc0
    function testOwnerPermissions() public {
        // Add a train
        bool success = true;
        try trainsOracle.addTrain("Train1", "Fast Train", 100) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a train");

        // Add stations
        try trainsOracle.addStation("Rome") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");

        try trainsOracle.addStation("Florence") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");

        

        // Add a consecutive segment
        try trainsOracle.addConsecutiveSegment("CS001", "Train1", "Rome", "Florence", block.timestamp + 1 hours, 100) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a consecutive segment");

        // Add a dynamic consecutive segment
        try trainsOracle.addDynamicConsecutiveSegment("DCS001", "CS001") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a dynamic consecutive segment");

        // Add a dynamic segment
        try trainsOracle.addDynamicSegment("DS001") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a dynamic segment");

        // Add the dynamic consecutive segment to the dynamic segment
        try trainsOracle.addDynamicConsecutiveSegmentToDynamicSegment("DS001", "DCS001", true) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a dynamic consecutive segment to a dynamic segment");
    }

    /// #sender: acc0
    function testCalculateTotalTicketPrice() public {
        // Ensure that the testOwnerPermissions has run to set up the necessary dynamic segments and consecutive segments
        // You should ensure that the dynamic segment "DS001" contains dynamic consecutive segments with known prices (100 in this case)

        // Call the contract function to get the price
        uint32 calculatedPrice = trainsOracle.buyTicketStep("ticket1", "DS001");

        // Manually calculate the expected price based on the dynamic consecutive segments that make up "DS001"
        uint32 expectedPrice = 100;  // The price of consecutive segment "CS001" is 100

        // Check if the calculated price matches the expected price
        Assert.equal(calculatedPrice, expectedPrice, "Total ticket price calculated is incorrect");
    }

    /// #sender: account-1
    function testNonOwnerPermissions() public {
        bool success = true;

        // Try to add a train
        try trainsOracle.addTrain("Train2", "Slow Train", 50) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, false, "Non-owner should not be able to add a train"  );

        // Try to add a station
        try trainsOracle.addStation("Rome") {
            success = true;
        } catch {
             success = false;
        }
        Assert.equal(success, false, "Non-owner should not be able to add a station");

        try trainsOracle.addStation("Florence") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, true, "Owner should be able to add a station");


        // Try to add a consecutive segment
        try trainsOracle.addConsecutiveSegment("CS002", "Train2", "Rome", "Florence", block.timestamp + 1 hours, 100) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, false, "Non-owner should not be able to add a consecutive segment");

        // Try to add a dynamic consecutive segment
        try trainsOracle.addDynamicConsecutiveSegment("DCS002", "CS002") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, false, "Non-owner should not be able to add a dynamic consecutive segment");

        // Try to add a dynamic segment
        try trainsOracle.addDynamicSegment("DS002") {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, false, "Non-owner should not be able to add a dynamic segment");

        // Try to add the dynamic consecutive segment to the dynamic segment
        try trainsOracle.addDynamicConsecutiveSegmentToDynamicSegment("DS002", "DCS002", true) {
            success = true;
        } catch {
            success = false;
        }
        Assert.equal(success, false, "Non-owner should not be able to add a dynamic consecutive segment to a dynamic segment");
            
    }

    function testCannotAddConsecutiveSegmentWithNonExistentStations() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addConsecutiveSegment(string,string,string)", "burubbu", "barabba", "biribbi"));
        Assert.equal(success, false, "Should not be able to add a consecutive segment with non-existent stations");
    }

    /// #sender: acc1
    function testUserInBlacklistCannotBuyTicket() public {
        address user = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; 
        trainsOracle.addToBlacklist(user);
        (bool success,) = address(trainsOracle).call(abi.encodeWithSignature("buyDynamicTicket(string,string[])", "ticket1", new string[](1)));
        Assert.equal(success, false ,"Blacklisted user could buy a ticket");
    }

    /// #sender: acc2
    function testOnlyOwnerCanAddOrRemoveFromBlacklist() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("addToBlacklist(address)",0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db));
        Assert.equal(success,false,"Only the owner should be able to add or remove a user from the blacklist");
        (bool success2, ) = address(trainsOracle).call(abi.encodeWithSignature("removeToBlacklist(address)",0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db));
        Assert.equal(success2,false,"Only the owner should be able to add or remove a user from the blacklist");
    }

     function testCannotBuyTicketIfTrainIsFull() public {
        (bool success,) = address(trainsOracle).call(abi.encodeWithSignature("buyDynamicTicket(string,string[])", "ticket2", new string[](1)));
        Assert.equal(success, false ,"User could buy a ticket even though train is full");
    }

    /// #sender: acc1
    function testBuyDynamicTicketWithSufficientEther() public {
        string[] memory segments = new string[](1);
        segments[0] = "segment1";
        (bool success, ) = address(trainsOracle).call{value: 50}(
            abi.encodeWithSignature(
                "buyDynamicTicket(string,string[])",
                "ticket1",
                segments
            )
        );
        Assert.equal(
            success,
            true,
            "Couldn't buy a ticket with sufficient Ether"
        );
    }

    
    /// #sender: acc0
    function testRefundsCalculatedCorrectlyBasedOnDelay() public {
        uint256 initialBalance = address(trainsOracle).balance;

        // Simulate delay and set arrival time
        trainsOracle.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicSegment1",
            block.timestamp + 2000
        );

        uint256 finalBalance = address(trainsOracle).balance;

        // Suppose the expected refund per ticket is 0.01 Ether
        uint256 expectedRefundAmount = 0.01 ether;

        // Calculate the actual refunded amount
        uint256 actualRefundAmount = initialBalance - finalBalance;

        // Check if the actual refund amount is correct
        Assert.equal(
            actualRefundAmount,
            expectedRefundAmount,
            "Refund amount calculated incorrectly based on delay"
        );
    }

    /// #sender: acc0
    function testRefundsTransferredCorrectlyToUserAddresses() public {
        uint256 initialBalance = address(this).balance;
        trainsOracle.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicSegment1",
            block.timestamp + 2000
        );
        uint256 finalBalance = address(this).balance;
        Assert.equal(
            finalBalance > initialBalance,
            true,
            "Refunds were not transferred correctly to user addresses"
        );
    }

    /// #sender: acc0
    function testOnlyOwnerCanModifyArrivalTime() public {
        (bool success, ) = address(trainsOracle).call(abi.encodeWithSignature("modifyArrivalTime(uint256)", block.timestamp + 2 hours));
        Assert.equal(success, false, "Only the owner should be able to modify the arrival time");
    }
 
    /// #sender: acc0
    function testModifiedArrivalTimeIsSavedCorrectly() public {
        uint256 newTime = block.timestamp + 2 hours;
        trainsOracle.setArrivalTimeAndCheckRequiredRefunds(
            "dynamicConsecutiveSegment1",
            newTime
        );

        (
            string memory consecutiveSegmentId,
            uint16 passengersNumber,
            uint256 actualArrivalTime,
            bool isSet
        ) = trainsOracle.dynamicConsecutiveSegments(
                "dynamicConsecutiveSegment1"
            );

        TrainsOracle.DynamicConsecutiveSegment memory segment = TrainsOracle
            .DynamicConsecutiveSegment(
                consecutiveSegmentId,
                passengersNumber,
                actualArrivalTime,
                isSet
            );

        uint256 savedTime = segment._actualArrivalTime;
        Assert.equal(
            savedTime,
            newTime,
            "Modified arrival time was not saved correctly"
        );
    }

     /// #sender: acc0
    function testOnlyOwnerCanExecuteFunctionsRequiringOnlyOwner() public {
        address nonOwner = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        (bool success, ) = address(nonOwner).call(
            abi.encodeWithSignature("addToBlacklist(address)", nonOwner)
        );
        Assert.equal(
            success,
            false,
            "Non-owner could execute function requiring onlyOwner"
        );
    }

    /// #sender: acc0
    function testContractInitialization() public {
        trainsOracle.setOwner(trainCompanyAddress); // Only for debugging
        address owner = trainsOracle.owner();
        Assert.equal(
            owner,
            trainCompanyAddress,
            "The owner address should be set correctly during contract creation"
        );
    }




}


