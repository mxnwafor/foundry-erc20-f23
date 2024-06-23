// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    error Test__ZeroAddress();

    MyToken public myToken;
    DeployMyToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        vm.prank(address(msg.sender));
        myToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, myToken.balanceOf(bob));
    }

    function testAllowanceWorks() public {
        // transferFrom()
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        // asserting if alice's balance is equal the transfer amount
        assertEq(myToken.balanceOf(alice), transferAmount);
        // asserting if bob's balance is the remainder of his initial balance - the amount the transferred
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testBalanceAfterTransfer() public {
        // Arrange: prepare transfer simulation
        // vm.deal(bob, STARTING_BALANCE);
        uint256 transferAmount = 50 ether;
        // Act: execute the transfer
        vm.prank(bob);
        myToken.transfer(alice, transferAmount);
        // Assert
        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testMsgsenderIsNotZeroAddress() public view {
        if (msg.sender == address(0)) {
            revert Test__ZeroAddress();
        }
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "MyToken";
        string memory actualName = myToken.name();

        assert(
            keccak256(abi.encodePacked(expectedName)) ==
                keccak256(abi.encodePacked(actualName))
        );
    }
}
