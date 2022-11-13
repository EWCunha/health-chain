// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IManagement.sol";

contract MedicalHistory {
    // --- STATE VARIABLES ---
    address public immutable owner; // owner's/patient's address.
    IManagment immutable management; // management contract pointer.
    bytes32 public uri; // medical history IPFS URI.
    bool public allowAll; // allows anyone to see the IPFS URI.
    bool public considerTrustedParties; // consider the management contract list of trusted parties.
    mapping(address => bytes32) public allowedParties; // mapping from parties addresses to encrypted IPFS URIs.
    uint256 public immutable specialtyId; // specialty ID of this medical history contract.

    // --- EVENTS ---
    event UpdatedURI(address indexed responsible, string uri);
    event UpdatedParty(address indexed party, string uri);
    event RequestedApprovalParty(address indexed party);

    // --- MODIFIERS ---
    /**
    @notice only owner modifier.
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

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

    // --- EXTERNAL FUNCTIONS ---
    /**
    @notice getURI: returns the IPFS URI of the medical history for the owner or allowed parties.
    */
    function getURI() external view returns (string memory) {
        if (msg.sender == owner || allowAll || _getGeneralTrustedParty()) {
            return _bytes32ToString(uri);
        } else {
            return _bytes32ToString(allowedParties[msg.sender]);
        }
    }

    /**
    @notice updateURI: updates the IPFS URI of the medical history.
    */
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

    /**
    @notice requestApprovalParty: emits event for requesting the IPFS URI
    */
    function requestApprovalParty() external {
        require(msg.sender != owner, "Cannot be owner");

        emit RequestedApprovalParty(msg.sender);
    }

    /**
    @notice updateAllowedParty: updates party URI. To not allow party anymore, set _uri to empty string.
    @param _uri: new IPFS URI.
    @param _party: party address.
    */
    function updateAllowedParty(string memory _uri, address _party)
        external
        onlyOwner
    {
        allowedParties[_party] = _stringToBytes32(_uri);

        emit UpdatedParty(_party, _uri);
    }

    /**
    @notice setAllowAll: updates allowAll variable. Only the owner is allowed.
    @param _allowAll: new boolean value for allowAll.
    */
    function setAllowAll(bool _allowAll) external onlyOwner {
        allowAll = _allowAll;
    }

    /**
    @notice setConsiderTrustedParties: updates considerTrustedParties variable. Only the owner is allowed.
    @param _considerTrustedParties: new boolean value for considerTrustedParties.
    */
    function setConsiderTrustedParties(bool _considerTrustedParties)
        external
        onlyOwner
    {
        considerTrustedParties = _considerTrustedParties;
    }

    // --- INTERNAL FUNCTIONS ---
    /**
    @notice _getGeneralTrustedParty: returns if the msg.sender is a trusted party from the management contract.
    */
    function _getGeneralTrustedParty() internal view returns (bool) {
        return
            considerTrustedParties
                ? management.generalTrustedParty(msg.sender)
                : false;
    }

    /**
    @notice _bytes32ToString: converts bytes32 to string.
    @param _bytes32: bytes32 value to be converted to string.
    */
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

    /**
    @notice _stringToBytes32: converts string to bytes32.
    @param source: string value to be converted to bytes32.
    */
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
