// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./MedicalHistory.sol";

contract Management {
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

    mapping(address => mapping(uint256 => address)) public histories;
    mapping(address => bool) public generalTrustedParty;
    mapping(address => bool) public managers;

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

    modifier onlyAllowed() {
        require(managers[msg.sender], "Not allowed");
        _;
    }

    function updateTrustedParty(address _party, bool _status)
        external
        onlyAllowed
    {
        require(!generalTrustedParty[_party], "Party already in");
        generalTrustedParty[_party] = _status;

        emit UpdatedTrustedParty(_party, _status);
    }

    function deployHistory(string memory uri, uint256 _specialtyId) external {
        require(
            histories[msg.sender][_specialtyId] == address(0),
            "Already deployed"
        );

        MedicalHistory history = new MedicalHistory(
            uri,
            msg.sender,
            _specialtyId
        );
        histories[msg.sender][_specialtyId] = address(history);

        emit HistoryDeployed(address(history), msg.sender, _specialtyId);
    }

    function updateManager(address _manager, bool _status)
        external
        onlyAllowed
    {
        managers[_manager] = _status;

        emit ManagerUpdated(msg.sender, _manager, _status);
    }
}
