// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { AxelarExecutable } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import { IAxelarGateway } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import { IAxelarGasService } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import { ICreditBureau } from "./interfaces/ICreditBureau.sol";

contract CreditBureau is ICreditBureau, AxelarExecutable {
    IAxelarGasService public immutable gasService;

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
    }

    mapping(address reporter => bool allowed) public whitelist;
    mapping(address user => Report[] reports) public creditHistory;

    event WhitelistToggled(address indexed operator, bool status);
    event CreditReportAdded(address indexed reporter, address indexed user);

    modifier onlyWhitelisted() {
        assert(whitelist[msg.sender]);
        _;
    }

    function toggleWhitelist(address _address) public {
        whitelist[_address] = !whitelist[_address];

        emit WhitelistToggled(_address, whitelist[_address]);
    }

    function viewCreditSummary(address _wallet)
        public
        view
        returns (
            uint256 lengthOfCreditHistory,
            uint256 earliestReport,
            uint256 latestReport,
            uint256 totalOpenCreditLines,
            uint256 mostRecentCreditLineOpenDate,
            uint256 totalNumberOfRecords,
            uint256 totalNegativeReviews
        )
    {
        Report[] memory reports = creditHistory[_wallet];
        totalNumberOfRecords = reports.length;

        if (totalNumberOfRecords == 0) return (0, 0, 0, 0, 0, 0, 0);

        earliestReport = reports[0].timestamp;
        latestReport = reports[0].timestamp;

        for (uint256 i = 0; i < totalNumberOfRecords; i++) {
            if (reports[i].review == Review.NEGATIVE) totalNegativeReviews++;
            if (reports[i].status == Status.OPENED) totalOpenCreditLines++;
            if (reports[i].credit.fromDate > mostRecentCreditLineOpenDate) {
                mostRecentCreditLineOpenDate = reports[i].credit.fromDate;
            }
            if (reports[i].timestamp < earliestReport) earliestReport = reports[i].timestamp;
            if (reports[i].timestamp > latestReport) latestReport = reports[i].timestamp;
        }

        lengthOfCreditHistory = (latestReport - earliestReport) / 30 days;
    }

    function submitCreditReport(Report memory report, address user) external override onlyWhitelisted {
        _addReport(report, msg.sender, user, block.chainid);
    }

    function _addReport(Report memory report, address reporter, address user, uint256 chainId) internal {
        report.credit.chain = chainId;
        report.timestamp = block.timestamp;
        report.reporter = reporter;

        creditHistory[user].push(report);

        emit CreditReportAdded(reporter, user);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    )
        internal
        override
    {
        (Report memory report, address user) = abi.decode(payload, (Report, address));
        _addReport(report, address(bytes20(bytes(sourceAddress))), user, _getChainId(sourceChain));
    }

    function _getChainId(string memory chain) internal pure returns (uint256) {
        if (Strings.equal(chain, "Ethereum")) return 1;
        if (Strings.equal(chain, "optimism")) return 10;
        if (Strings.equal(chain, "arbitrum")) return 42_161;
        if (Strings.equal(chain, "Polygon")) return 137;
        if (Strings.equal(chain, "Avalanche")) return 43_114;
        if (Strings.equal(chain, "binance")) return 56;
        if (Strings.equal(chain, "celo")) return 42_220;
        if (Strings.equal(chain, "Fantom")) return 250;
        if (Strings.equal(chain, "linea")) return 59_144;
        if (Strings.equal(chain, "base")) return 8453;

        return 0;
    }
}
