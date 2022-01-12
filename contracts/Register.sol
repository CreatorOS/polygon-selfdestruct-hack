// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
 
contract Register {
    mapping(address => bool) registered;
 
   function register() public payable {
       require(msg.value == 1 ether);
       require(address(this).balance <= 10 ether);
       registered[msg.sender] = true;
   }
 
   function getNumberOfRegistrants() public view returns (uint256) {
       return address(this).balance / (10**18);
   }
}