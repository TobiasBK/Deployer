// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

/**
 * @notice deploy any contract. Requires the contract byte code.
 */
contract Deployer {
    address public owner;

    event Deposit(address sender, uint256 value);
    event Deployed(address);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Payable so we can send the function ether.
     * returns the address of the newly deployed contract.
     * Assembly function create() is needed.
     */
    function deploy(bytes memory _codeData)
        external
        payable
        onlyOwner
        returns (address addr)
    {
        assembly {
            //The parameters for create(v, p, n). This returns an address
            //v - the amt of ether to send to the contract getting deployed. Here, callvalue = msg.value
            //p - pointer in memory for solidity showing where this code starts. _codeData is loaded in memory,
            //the first 32 bytes encodes the length of the code, so must skip the first 32 bytes. 0x20 = 32 in hexadecimal.
            //n - code size
            addr := create(callvalue(), add(_codeData, 0x20), mload(_codeData))
        }
        //if fails to deploy, will return a 0 address.
        require(addr != address(0), "failed to deploy");
        emit Deployed(addr);
    }

    /**
     * @dev Allows owner to call any function in another contract from the deployer contract.
     */
    function call(address _toCall, bytes memory _data)
        external
        payable
        onlyOwner
    {
        (bool sent, ) = _toCall.call{value: msg.value}(_data);
        require(sent, "call failed");
    }

    /**
     * @dev Allows the owner address to be changed by the current owner account.
     */
    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    /**
     * @dev Allows owner to withdraw all ether
     */
    function withdraw() external onlyOwner {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "withdraw failed");
    }
}
