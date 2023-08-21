// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;


// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
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

}


