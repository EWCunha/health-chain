// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IManagement.sol";

contract MedicalHistory {
    address public immutable owner;
    IManagment immutable management;
    bytes32 public uri;
    bool public allowAll;
    bool public considerTrustedParties;
    mapping(address => bytes32) public allowedParties;
    uint256 public immutable specialtyId;

    event UpdatedURI(address indexed responsible, string uri);
    event UpdatedParty(address indexed party);

    constructor(
        string memory _uri,
        address _owner,
        uint256 _specialtyId
    ) {
        uri = _stringToBytes32(_uri);
        owner = _owner;
        management = IManagment(msg.sender);
        specialtyId = _specialtyId;
    }

    function getURI() external view returns (string memory) {
        if (
            msg.sender == owner ||
            allowAll ||
            management.generalTrustedParty(msg.sender)
        ) {
            return _bytes32ToString(uri);
        } else {
            return _bytes32ToString(allowedParties[msg.sender]);
        }
    }

    function updateURI(string memory _newURI) external {
        if (msg.sender == owner) {
            uri = _stringToBytes32(_newURI);
        } else if (allowedParties[msg.sender] != bytes32(0)) {
            allowedParties[msg.sender] = _stringToBytes32(_newURI);
        } else {
            revert("Not allowed");
        }

        emit UpdatedURI(msg.sender, _newURI);
    }

    function updateAllowedParty(string memory _uri, address _party) external {
        require(msg.sender == owner, "Not allowed");
        allowedParties[_party] = _stringToBytes32(_uri);

        emit UpdatedParty(_party);
    }

    function _bytes32ToString(bytes32 _bytes32)
        internal
        pure
        returns (string memory)
    {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function _stringToBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
