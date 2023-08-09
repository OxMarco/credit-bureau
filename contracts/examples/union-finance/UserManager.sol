// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ICreditBureau } from "../../interfaces/ICreditBureau.sol";

/** 
 * @title Union Finance implementation
 * @dev Extending the debtWriteOff function to submit an automated report
 */

contract UserManager {
    ICreditBureau creditBureau; // The instance of the credit bureau contract
    address public uToken;

    struct Vouch {
        // staker receiving the vouch
        address staker;
        // trust amount
        uint96 trust;
        // amount of stake locked by this vouch
        uint96 locked;
        // only update when lockedCoinAge is updated
        uint64 lastUpdated;
    }

    event LogDebtWriteOff(address indexed staker, address indexed borrower, uint256 amount);

    // This could be set in the constructor or a setter function (e.g., setCreditBureau)
    constructor(address _creditBureauAddress) {
        creditBureau = ICreditBureau(_creditBureauAddress);
    }

    function debtWriteOff(address /*stakerAddress*/, address borrowerAddress, uint256 amount) external {
        Vouch memory vouch;
        // ... [existing logic]

        emit LogDebtWriteOff(msg.sender, borrowerAddress, amount);

        // Submit a credit Report at the end
        ICreditBureau.Credit memory credit = ICreditBureau.Credit({
            collateral: vouch.trust > 0 ? ICreditBureau.Collateral.UNDERCOLLATERALISED : ICreditBureau.Collateral.OVERCOLLATERALISED, 
            creditType: ICreditBureau.Type.FIXED, 
            fromDate: getTimestamp() - 30 days, // TODO get loan duration
            toDate: getTimestamp(),
            amount: amount,
            token: uToken,
            chain: block.chainid
        });

        ICreditBureau.Report memory report = ICreditBureau.Report({
            creditProvider: "Union Finance",
            reporter: address(this),
            review: ICreditBureau.Review.POSITIVE, 
            status: ICreditBureau.Status.REPAID,
            credit: credit,
            timestamp: getTimestamp(),
            data: ""
        });

        creditBureau.submitCreditReport(report, borrowerAddress); // Assuming this is how you submit a report
    }

    /**
     *  @dev Function to simply retrieve block timestamp
     *  This exists mainly for inheriting test contracts to stub this result.
     */
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }
}
