// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract DataRequest is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    mapping(address => uint256) public requestedValue;
    uint256 public data;
    bytes32 private jobId;
    uint256 private fee;

    event RequestData(bytes32 indexed requestId, uint256 _data);

    constructor(
        address _node,
        address _chainLinkToken,
        bytes32 _jobId,
        uint256 _fee
    ) {
        setChainlinkToken(_chainLinkToken);
        setChainlinkOracle(_node); // set correct node address
        jobId = _jobId;
        fee = _fee;
    }

    function requestVolumeData(string memory _endpoint, string memory _path)
        public
        returns (bytes32 requestId)
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on
        req.add("get", _endpoint);
        req.add("path", _path);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId, uint256 _data) public {
        emit RequestData(_requestId, _data);
        data = _data;
    }
}
