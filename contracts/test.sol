// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract HelloWorld {

    string strVar="Hello World.";

    function sayHello() public view returns(string memory){
        return strVar;
    }

}
