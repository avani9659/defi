// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * This is an upgradable smart contract
 * (Code which will evolve as the project grows)
 */
contract Governance is Initializable {
    uint16 flaggingThreshold;
    uint16 currentFlags;
    bool public isPlatformEnabled;

    /**
     * Since we cannot have constructors in upgradeable smart contracts, to set the initial values we make use of 'initialize' function
     * 'initializer' modifier make this function act as constructor
     */
    function initialize(uint16 _flaggingThreshold) public initializer {
        flaggingThreshold = _flaggingThreshold;
        currentFlags = 0;
        isPlatformEnabled = true;
    }

    function flag() external returns (bool success) {
        currentFlags += 1;

        if (currentFlags > flaggingThreshold) {
            isPlatformEnabled = false;
        }

        return true;
    }

    // function enableFlag() external returns (bool success) {
    //     currentFlags += 1;

    //     if (currentFlags > flaggingThreshold) {
    //         isPlatformEnabled = true;
    //     }

    //     return true;
    // }

    function changePlatformState(
        bool newState
    ) external returns (bool success) {
        isPlatformEnabled = newState;

        return true;
    }
}
