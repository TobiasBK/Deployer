// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./Deployer.sol";

contract Calle {
    uint256 count = 1;

    function counter(uint256 _num) public view returns (uint256) {
        uint256 newCount;
        return newCount = count + _num;
    }
}

contract NotOwner {
    Deployer private deployer;

    constructor(address _deployer) {
        deployer = Deployer(payable(_deployer));
    }

    function setOwner(address _owner) public {
        deployer.setOwner(_owner);
    }
}

contract SendEth {
    Deployer private deployer;

    constructor(address _deployer) {
        deployer = Deployer(payable(_deployer));
    }

    function send() public {
        payable(address(deployer)).transfer(1 ether);
    }
}

contract DeployerTest is DSTest {
    Deployer private deployer;
    Calle private calle;
    NotOwner private notOwner;
    SendEth private sendEth;

    function setUp() public {
        deployer = new Deployer();
        calle = new Calle();
        notOwner = new NotOwner(address(notOwner));
        sendEth = new SendEth(address(sendEth));
    }

    //UNIT TESTING

    function test_receive() public {
        assertEq((address(deployer).balance), 0);
        payable(address(deployer)).transfer(1 ether);
        assertEq(address(deployer).balance, 1 ether);
    }

    function test_setOwner() public {
        deployer.setOwner(address(0x1));
        assertEq(deployer.owner(), address(0x1));
    }

    function testFail_setOwner() public {
        notOwner.setOwner(address(notOwner));
    }

    // function test_call() public {
    //     deployer.call(address(calle), "");
    // }

    // function test_withdraw() public {
    //     payable(address(deployer)).transfer(1 ether);
    //     uint256 preBalance = address(this).balance;
    //     deployer.withdraw();
    //     uint256 postBalance = address(this).balance;
    //     assertEq(postBalance + 1 ether, preBalance);
    // }
}
