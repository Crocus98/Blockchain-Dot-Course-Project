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





}


