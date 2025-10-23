// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWorld{
    struct Info{
        uint256 id;
        string sayStr;
    }

    mapping ( uint256 => Info ) public sayStrs;

    function setHello(uint256 _id, string memory _sayStr) public {
        sayStrs[_id] = Info({
            id: _id,
            sayStr: _sayStr
        });
    }

    function sayHello(uint256 _id)
        public 
        view 
        returns(string memory){
            return addInfo(sayStrs[_id].sayStr);
        }

    function addInfo(string memory _str) public pure returns(string memory){
        return string(abi.encodePacked("Hello, ", _str));
    }
}