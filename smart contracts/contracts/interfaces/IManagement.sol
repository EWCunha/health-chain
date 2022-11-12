// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IManagment {
    function generalTrustedParty(address _party) external view returns (bool);
}
