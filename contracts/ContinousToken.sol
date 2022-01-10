// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./curves/BancorFormula.sol";

contract ContinousToken is BancorFormula, ERC20 {
    using SafeMath for uint256;

    uint256 public scale = 10**18;
    uint256 public reserveBalance = 1000 * scale;
    uint256 public reserveRatio;
    address public reserveTokenAddress;

    /**
     * @dev Fired when TOK is exchanged for ERC20 Token
     */
    event ContinuousBurn(
        address _address,
        uint256 continuousTokenAmount,
        uint256 reserveTokenAmount
    );

    /**
     * @dev Fired when ERC20 Token is exchanged for TOK
     */
    event ContinuousMint(
        address _address,
        uint256 reserveTokenAmount,
        uint256 continuousTokenAmount
    );

    /**
     * @param _reserveRatio(RR) to determine the bonding curve to be used. 50% RR = Linear Bonding Curve, 10% RR = Exponential Bonding Curve
     * @param _reserveTokenAddress Contract address of ERC20 Token to use as reserve/exchange of value e.g DAI
     */
    constructor(uint256 _reserveRatio, address _reserveTokenAddress)
        ERC20("Continous Token", "TOK")
    {
        reserveRatio = _reserveRatio;
        reserveTokenAddress = _reserveTokenAddress;
        _mint(msg.sender, 1000000 * scale);
    }

    /**
     * @dev Mint some TOK token by allowing contract to spend an amount of caller reserve tokens
     * @param _amount Number of reserve token approved for this contract to convert to TOK tokens
     */
    function mint(uint256 _amount) public returns (uint256 _amountMinted) {
        uint256 allowance = IERC20(reserveTokenAddress).allowance(
            msg.sender,
            address(this)
        );

        require(allowance >= _amount, "1");

        bool success = IERC20(reserveTokenAddress).transferFrom(
            msg.sender,
            address(this),
            allowance
        );

        if (success) {
            return _continuousMint(allowance);
        } else {
            require(allowance > 0, "2");
        }
    }

    /**
     * @dev Burn some TOK token and return reserve token based on current curve price
     * @param _amount Number of TOK token to convert to reserve tokens
     */
    function burn(uint256 _amount) public {
        uint256 returnAmount = _continuousBurn(_amount);
        IERC20(reserveTokenAddress).transfer(msg.sender, returnAmount);
    }

    function calculateContinuousMintReturn(uint256 _amount)
        public
        view
        returns (uint256 mintAmount)
    {
        return
            purchaseTargetAmount(
                totalSupply(),
                reserveBalance,
                uint32(reserveRatio),
                _amount
            );
    }

    function calculateContinuousBurnReturn(uint256 _amount)
        public
        view
        returns (uint256 burnAmount)
    {
        return
            saleTargetAmount(
                totalSupply(),
                reserveBalance,
                uint32(reserveRatio),
                _amount
            );
    }

    function _continuousMint(uint256 _deposit) internal returns (uint256) {
        require(_deposit > 0, "3");

        uint256 amount = calculateContinuousMintReturn(_deposit);
        _mint(msg.sender, amount);
        reserveBalance = reserveBalance.add(_deposit);
        emit ContinuousMint(msg.sender, _deposit, amount);
        return amount;
    }

    function _continuousBurn(uint256 _amount) internal returns (uint256) {
        require(_amount > 0, "4");
        require(balanceOf(msg.sender) >= _amount, "5");

        uint256 reimburseAmount = calculateContinuousBurnReturn(_amount);
        _burn(msg.sender, _amount);
        reserveBalance = reserveBalance.sub(reimburseAmount);
        emit ContinuousBurn(msg.sender, _amount, reimburseAmount);
        return reimburseAmount;
    }
}
