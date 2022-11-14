// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./MedicalHistory.sol";

contract Management {
    // --- STATE VARIABLES ---
    /**
    note
    0: CARDIO
    1: NEURO
    2: ORTO
    3: DERMATO
    4: PNEUMO
    5: GASTRO
    6: PED
    7: PSY
    .
    .
    .
    */

    /**
    @notice mapping from patient to specialty contract (patient >> specialtyId >> contract address)
    */
    mapping(address => mapping(uint256 => address)) public histories;
    /**
    @notice mapping of general trusted parties allowed to retrieve the medical history of all registered patients
    */
    mapping(address => bool) public generalTrustedParty;
    /**
    @notice mapping of the managers addresses of this contract
    */
    mapping(address => bool) public managers;

    // --- EVENTS ---
    event UpdatedTrustedParty(address indexed party, bool status);
    event HistoryDeployed(
        address indexed history,
        address indexed owner,
        uint256 specialtyId
    );
    event ManagerUpdated(
        address indexed manager,
        address indexed updated,
        bool status
    );

    constructor() {
        managers[msg.sender] = true;
    }

    /**
    @notice only allowed manager address
    */
    modifier onlyAllowed() {
        require(managers[msg.sender], "Not allowed");
        _;
    }

    // --- FUNCTIONS ---
    /**
    @notice updateTrustedParty: updates the trusted parties mapping
    only allowed managers can call this function
    @param _party: party address
    @param _status: status to be updated
    */
    function updateTrustedParty(address _party, bool _status)
        external
        onlyAllowed
    {
        require(!generalTrustedParty[_party], "Party already in");
        generalTrustedParty[_party] = _status;

        emit UpdatedTrustedParty(_party, _status);
    }

    /**
    @notice deployHistory: deploys new contract for the medical history of the given specialty. Each address can deploy
    only one contract for each medical specialty
    @param _uri: medical history IPFS URI
    @param _specialtyId: ID of the medical hisotry specialty
    */
    function deployHistory(string memory _uri, uint256 _specialtyId) external {
        require(
            histories[msg.sender][_specialtyId] == address(0),
            "Already deployed"
        );

        MedicalHistory history = new MedicalHistory(
            _uri,
            msg.sender,
            _specialtyId
        );
        histories[msg.sender][_specialtyId] = address(history);

        emit HistoryDeployed(address(history), msg.sender, _specialtyId);
    }

    /**
    @notice updateManager: updates a manager status. Only managers are allowed to call this function.
    @param _manager: the manager's address
    @param _status: the new manager's status
    */
    function updateManager(address _manager, bool _status)
        external
        onlyAllowed
    {
        managers[_manager] = _status;

        emit ManagerUpdated(msg.sender, _manager, _status);
    }
}
