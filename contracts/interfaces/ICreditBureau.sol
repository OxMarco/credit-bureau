// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICreditBureau {
    /**
     * @title Enum representing the review of a credit report.
     */
    enum Review {
        POSITIVE,
        NEGATIVE,
        NEUTRAL
    }

    /**
     * @title Enum representing the status of a credit line.
     */
    enum Status {
        OPENED,
        REPAID,
        DEFAULTED,
        LATE_REPAY
    }

    /**
     * @title Enum representing the type of credit line.
     */
    enum Collateral {
        UNDERCOLLATERALISED, // LTV < 100%
        COLLATERALISED, // LTV = 100%
        OVERCOLLATERALISED // LTV > 100%
    }

    /**
     * @title Enum representing the duration type of a credit line (either fixed or revolving).
     */
    enum Type {
        FIXED, // defined due date
        REVOLVING // no expiration date
    }

    /**
     * @title Struct representing the details of a credit line.
     * @dev Contains information about the type, duration, dates, amount, token, and chain related to the credit line.
     * @param collateral Collateral of the credit line, e.g., collateralized or not.
     * @param creditType Type of the credit line, either fixed or revolving.
     * @param fromDate Start date of the credit line.
     * @param toDate End date of the credit line. Null if duration is REVOLVING.
     * @param amount Amount involved in the credit line.
     * @param token Address of the token involved in the credit line.
     * @param chain Chain ID of the blockchain where the credit line resides.
     */
    struct Credit {
        Collateral collateral;
        Type creditType;
        uint256 fromDate;
        uint256 toDate;
        uint256 amount;
        address token;
        uint256 chain;
    }

    /**
     * @title Struct representing a credit report related to an address.
     * @dev Contains information about the credit provider, reporter, review, status, credit details, timestamp, and
     * additional data.
     * @param creditProvider String representing the name or identification of the credit provider.
     * @param reporter Address of the entity reporting the credit information.
     * @param review Enum representing the review (POSITIVE, NEGATIVE, NEUTRAL).
     * @param status Enum representing the status of the credit line (OPENED, REPAID, DEFAULTED, LATE_REPAY).
     * @param credit Struct containing details about the credit line.
     * @param timestamp Timestamp of the credit report.
     * @param data Additional bytes field to store comments or extra information about the credit line.
     */
    struct Report {
        string creditProvider;
        address reporter;
        Review review;
        Status status;
        Credit credit;
        uint256 timestamp;
        bytes data;
    }

    function submitCreditReport(Report memory report, address user) external;
}
