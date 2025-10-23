// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {HelloWorld} from "./HelloWorld.sol";

contract HelloWorldFactory{
    HelloWorld hw;
    HelloWorld[] hws;

    function createHw() public{
        hw = new HelloWorld();
        hws.push(hw);
    }

    function callHelloWorldSetHelloWorld(uint256 _index, uint256 _id, string memory _sayStr) public{
        hws[_index].setHello(_id, _sayStr);
    }

    function callHelloWorldSayHello(uint256 _index, uint256 _id) public view returns(string memory){
        return hws[_index].sayHello(_id);
    }
}