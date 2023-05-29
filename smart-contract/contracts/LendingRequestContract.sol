// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "hardhat/console.sol";
import "./ERC20Interface.sol";

contract LendingRequest {
    address payable private owner; //this will be address of request factory contract as this will not be deployed us but rather created when lending agreement is done
    address payable private token; //address of ERC20 token
    address payable public asker;
    address payable public lender;
    uint256 public collateral; //amount of ethers set as collateral
    uint256 public amountAsked;
    uint256 public paybackAmount;
    string public purpose;
    uint256 public collateralCollectionTimestamp; //deadline, if amount is not paid back, collateral is sent to lender's address

    bool public moneyLent;
    bool public debtSettled;
    bool public collateralCollected;

    /**
     * Caller of this contract will be another factory contract, from where we will be passing all these parameters
     * to create a lending contract.
     * Constructor call signifies an ask request.
     */
    constructor(
        address payable _asker,
        uint256 _amountAsked,
        uint256 _paybackAmount,
        string memory _purpose,
        address payable _owner,
        address payable _token,
        uint256 _collateral,
        uint256 _collateralCollectionTimestamp
    ) payable {
        asker = _asker;
        amountAsked = _amountAsked;
        paybackAmount = _paybackAmount;
        purpose = _purpose;
        owner = _owner;
        token = _token;
        collateral = _collateral;
        collateralCollectionTimestamp = _collateralCollectionTimestamp;
    }

    modifier OnlyOwner() {
        require(owner == msg.sender, "Unauthorized access");
        _;
    }

    /**
     * Lending request will only be controlled via factory contract. Most of the functions in this contract will be 'OnlyOwner'
     * (factory contract), as this contract will be deployed by factory contract
     */

    function lend(
        address payable _lender
    ) external OnlyOwner returns (bool success) {
        require(_lender != asker, "Invalid request");
        require(!moneyLent, "Money has already been lent");
        require(
            collateralCollected,
            "Collateral collected or request has been cancelled"
        );

        //check if lender has enough balance
        uint256 balance = ERC20Interface(token).allowance(
            _lender,
            address(this)
        );
        require(balance <= amountAsked, "Insufficient balance");

        require(
            ERC20Interface(token).transferFrom(_lender, asker, amountAsked),
            "Transaction failed"
        );

        moneyLent = true;
        lender = _lender; //this assignment is only done once the transfer is successful.

        return true;
    }

    function payback(
        address payable _asker
    ) external OnlyOwner returns (bool success) {
        require(asker == _asker, "Invalid asker");
        //check the state of the contract
        require(moneyLent && !debtSettled, "Debt is not settled yet");
        //if collateral is already collected (either debt is paid back or failure to pay debt resulted in collateral collection),
        //then payback is not allowed
        require(!collateralCollected, "Collateral already collected");

        uint256 balance = ERC20Interface(token).allowance(
            _asker,
            address(this)
        );
        require(balance >= paybackAmount, "Insufficient balance");

        require(
            ERC20Interface(token).transferFrom(_asker, lender, paybackAmount),
            "Transfer failed"
        );

        _asker.transfer(address(this).balance);
        collateral -= address(this).balance;

        debtSettled = true;

        return true;
    }

    function collectCollateral(
        address payable _lender
    ) external OnlyOwner returns (bool success) {
        require(lender != _lender, "Invalid lender");
        require(
            moneyLent && !debtSettled,
            "Invalid Operation, debt is settled or moeny is not lent"
        );

        require(!collateralCollected, "Collateral collected");
        require(
            block.timestamp >= collateralCollectionTimestamp,
            "Too soon to collect collateral"
        );

        collateralCollected = true;
        _lender.transfer(address(this).balance);

        return true;
    }

    function cancelRequest(
        address _asker
    ) external OnlyOwner returns (bool success) {
        /*
        Asker decides to cancel this loan request before anyone has executed it
        checks:
            Only the asker can cancel this request
            Tokens must not have already been lent
            Loan must not already have been paid back
            Collateral must not already have been collected
         */

        // Check
        require(_asker == asker, "Invalid Asker");
        require(
            moneyLent == false &&
                debtSettled == false &&
                collateralCollected == false,
            "Can not cancel now"
        );

        // Update State
        collateralCollected = true;

        // Transfer Ether back
        asker.transfer(address(this).balance);

        return true;
    }

    function getRequestParameters()
        external
        view
        OnlyOwner
        returns (
            address payable,
            address payable,
            uint256,
            uint256,
            string memory
        )
    {
        return (asker, lender, amountAsked, paybackAmount, purpose);
    }

    function getRequestState()
        external
        view
        OnlyOwner
        returns (bool, bool, uint256, bool, uint256, uint256)
    {
        return (
            moneyLent,
            debtSettled,
            collateral,
            collateralCollected,
            collateralCollectionTimestamp,
            block.timestamp
        );
    }
}
