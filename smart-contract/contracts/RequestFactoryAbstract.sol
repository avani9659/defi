// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "./LendingRequestContract.sol";

/**
 * This is going to be an abstract contract (contract which never gets deployed on the network)
 * This will be used in other contracts as part of inheritance
 *
 * This contract will not have a constructor as it will be never be deployed
 */
abstract contract RequestFactory {
    /**
     * This function will be called from the defi platform when a user initiates a lending request.
     *
     * This will be an internal function, as this written inside an abstract contract.
     * External accounts are not supposed to use this function
     */
    function createLendingRequest(
        uint256 _amount,
        uint256 _paybackAmount,
        string memory _purpose,
        address payable _origin,
        address payable _token,
        uint256 _collateral,
        uint256 _collateralCollectionTimestamp
    ) internal returns (address payable lendingRequest) {
        //lending request instance will return the address in hex form. This needs to be converted to address datatype,
        //which is then converted uint160 (since addresses are 160 byte), then again to address datatype and finally payable type

        //direct conversions are not allowed with newer versions of solidity. Conversions need to be atomic
        //hence to get payable address, conversions will be as follows: address -> uint160 -> address -> payable
        return
            lendingRequest = payable(
                address(
                    uint160(
                        address(
                            //value: msg.value - indicates the amount of ethers sent by the user.
                            // Amount of ethers sent is captured in the global context 'msg'
                            new LendingRequest{value: msg.value}(
                                _origin,
                                _amount,
                                _paybackAmount,
                                _purpose,
                                //defines who is the owner of contract.
                                //It is converted to payable type, as the the constructor accepts payable address of owner

                                //address(this) - defines the address of current contract
                                //since this is a abstract contract, it will not have its own address, instead it will the address of the contract
                                //which will inherit this abstract contract
                                payable(address(this)),
                                _token,
                                _collateral,
                                _collateralCollectionTimestamp
                            )
                        )
                    )
                )
            );
    }
}
