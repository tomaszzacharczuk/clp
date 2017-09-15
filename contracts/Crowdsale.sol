pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "./DoublyLinkedList.sol";
import "./Token.sol";


contract Crowdsale is Ownable {
    using SafeMath for uint256;
    using DoublyLinkedList for DoublyLinkedList.Elements;

    Token public token;
    address public wallet;

    // look up table of pending transfers
    address[] public pendingTransfers;
    DoublyLinkedList.Elements public pendingTransfersData;
    
    uint256 public numberOfTokensToSell;
    uint256 public weiRaised;
    uint256 public rate;
    
    uint256 public startBlock;
    uint256 public endBlock;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event TokenTransfer(address indexed wallet, address indexed beneficiary, uint256 value);

    modifier purchaseValid() {
        require(startBlock <= block.number && block.number <= endBlock);
        require(msg.value != 0);
        _;
    }

    function Crowdsale(
        address _token,
        address _wallet, 
        uint256 _numberOfTokensToSell, 
        uint256 _rate,
        uint256 _startBlock,
        uint256 _endBlock
        ) {
        require(_token != 0x0);
        require(_wallet != 0x0);
        require(_rate != 0);

        token = Token(_token);

        require(token.balanceOf(_wallet) >= _numberOfTokensToSell);
        require(token.allowance(_wallet, this) >= _numberOfTokensToSell);
        require(_startBlock >= block.number);
        require(_endBlock >= _startBlock);

        wallet = _wallet;
        numberOfTokensToSell = _numberOfTokensToSell;
        rate = _rate;
        startBlock = _startBlock;
        endBlock = _endBlock;
        owner = msg.sender;
    }

    function() payable {
        buyTokens(msg.sender);
    }

    /**
     * @param beneficiary address of wallet to get token
     * @return {boolean} true if success
     */
    function buyTokens(address beneficiary) public payable purchaseValid returns (bool) {
        uint256 weiAmount = msg.value;
        weiRaised = weiRaised.add(weiAmount);
        uint256 tokenSold = weiAmount.mul(rate);

        numberOfTokensToSell.sub(tokenSold);

        pendingTransfers.push(beneficiary);
        pendingTransfersData.addElement(beneficiary, tokenSold);
        
        TokenPurchase(wallet, beneficiary, msg.value, tokenSold);
        forwardFunds();
        return true;
    }

    function transferToken(address beneficiary) public onlyOwner returns (bool success) {
        uint256 value = pendingTransfersData.getElement(beneficiary);
        pendingTransfersData.removeElement(beneficiary);
        uint256 index = 0;
        while (pendingTransfers[index] != beneficiary) {
            index++;
        }
        delete pendingTransfers[index];
        success = token.transferFrom(wallet, beneficiary, value);
        TokenTransfer(wallet, beneficiary, value);
    }

    function updateWallet(address new_wallet) public onlyOwner returns (bool) {
        require(token.balanceOf(new_wallet) >= numberOfTokensToSell);
        require(token.allowance(new_wallet, this) >= numberOfTokensToSell);
        wallet = new_wallet;
        return true;
    }

    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}