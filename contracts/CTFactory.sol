// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ContinousToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BondingCurveTokenFactory is Ownable {
    address[] public tokensDeployed;

    event TokenCreated(address tokenAddress);

    function createBondingCurveToken() public {
        address newToken = address(
            new ContinousToken(0, 0xaD6D458402F60fD3Bd25163575031ACDce07538D)
        );
        tokensDeployed.push(newToken);
        emit TokenCreated(newToken);
    }
}
