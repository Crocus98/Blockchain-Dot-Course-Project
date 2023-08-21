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



}


