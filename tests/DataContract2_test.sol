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


}


