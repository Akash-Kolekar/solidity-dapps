// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract PiggyBank {
    error PiggyBank__NotAOwner();

    address public s_owner = msg.sender;

    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);

    receive() external payable {
        emit Deposit(msg.value);
    }

    function withdraw() external {
        if (s_owner != msg.sender) {
            revert PiggyBank__NotAOwner();
        }
        emit Withdraw(address(this).balance);
        selfdestruct(payable(msg.sender));
    }
}
