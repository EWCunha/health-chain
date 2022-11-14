// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IManagement.sol";

contract MedicalHistory {
    // --- STATE VARIABLES ---
    address public immutable owner; // owner's/patient's address.
    IManagment immutable management; // management contract pointer.
    string public uri; // medical history IPFS URI.
    bool public allowAll; // allows anyone to see the IPFS URI.
    bool public considerTrustedParties; // consider the management contract list of trusted parties.
    mapping(address => string) public allowedParties; // mapping from parties addresses to encrypted IPFS URIs.
    uint256 public immutable specialtyId; // specialty ID of this medical history contract.
    uint256 public dataFee;

    // --- EVENTS ---
    event UpdatedURI(address indexed responsible, string _uri);
    event UpdatedParty(address indexed party, string _uri);
    event RequestedApprovalParty(address indexed party);
    event PaidForData(address indexed buyer);

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
        uri = _uri;
        owner = _owner;
        management = IManagment(msg.sender);
        specialtyId = _specialtyId;
    }

    // --- EXTERNAL FUNCTIONS ---
    /**
    @notice setDataFee: sets a value for the dataFee variable. Only the owner can call this function.
    @param _dataFee: new value for dataFee
    */
    function setDataFee(uint256 _dataFee) external onlyOwner {
        dataFee = _dataFee;
    }

    /**
    @notice getURI: returns the IPFS URI of the medical history for the owner or allowed parties.
    */
    function getURI() external view returns (string memory) {
        if (msg.sender == owner || allowAll || _getGeneralTrustedParty()) {
            return uri;
        } else {
            return allowedParties[msg.sender];
        }
    }

    /**
    @notice updateURI: updates the IPFS URI of the medical history.
    */
    function updateURI(string memory _newURI) external {
        if (msg.sender == owner) {
            uri = _newURI;
        } else if (bytes(allowedParties[msg.sender]).length != 0) {
            allowedParties[msg.sender] = _newURI;
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
        allowedParties[_party] = _uri;

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
    @notice patient concents to sell his own exams data as long as dataFee > 0. He also needs to be sure
    that no sensitive data is on the exams.
    */
    receive() external payable {
        require(dataFee > 0, "Not available");
        require(!(msg.value < dataFee), "Not enough paid");

        emit PaidForData(msg.sender);
    }
}
