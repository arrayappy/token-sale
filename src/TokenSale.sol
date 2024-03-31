// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
    
contract TokenSale is Ownable{

    using SafeERC20 for IERC20;
    IERC20 public token;

    // capacity
    uint public presaleMaxCap;
    uint public presaleMinCap;
    uint public publicsaleMaxCap;
    uint public publicsaleMinCap;


    uint public presaleMinContribution;
    uint public presaleMaxContribution;

    uint public publicsaleMinContribution;
    uint public publicsaleMaxContribution;

    // durations
    uint public presaleDuration;
    uint public publicsaleDuration;

    // statuses
    // bool public isPresaleOver;
    // bool public isPublicsaleOver;
    // bool public isPresaleActive;
    // bool public isPublicsaleActive;

    // start and ends
    uint public presaleStartTime;
    uint public publicsaleStartTime;


    // balance tracking
    uint public amountRaisedInPresale;
    uint public amountRaisedInPublicsale;

    mapping (address => uint) public presaleContributions;
    mapping (address => uint) public publicsaleContributions;


    // Events
    event TokenSale_PreSale_Contribution_Limits_Changed(uint indexed min, uint indexed max);
    event TokenSale_PublicSale_Contribution_Limits_Changed(uint indexed min, uint indexed max);
    event TokenSale_Thanks_For_Donation(address indexed sender);
    event TokenSale_Pre_Sale_Started(uint);
    event TokenSale_Public_Sale_Started(uint);
    event TokenSale_Tokens_Sent_In_Presale(address indexed receiver, uint indexed amount);
    event TokenSale_Tokens_Sent_In_Publicsale(address indexed receiver, uint indexed amount);
    event Token_Presale_Refund_Success(address indexed receiver, uint);
    event Token_Publicsale_Refund_Success(address indexed receiver, uint);
    event TokenSale_Emergency_Withdraw(address indexed owner);
    event TokenSale_PublicSale_Cap_Set(uint min, uint max);
    event TokenSale_PreSale_Cap_Set(uint min, uint max);
    

    // Error
    error TokenSale_Invalid_Max_Min();
    error TokenSale_Invalid_Sale_Duration();
    error TokenSale_Invalid_Token();
    error TokenSale_Presale_Already_Active();
    error TokenSale_Presale_Not_Started();
    error TokenSale_Contribution_Limit_Passed();
    error TokenSale_Not_Enough_Contribution();
    error TokenSale_Presale_Max_Cap_Passed();
    error TokenSale_Insufficient_Token_Balance();
    error TokenSale_Publicsale_Not_Started();
    error TokenSale_Publicsale_Max_Cap_Passed();
    error TokenSale_Publicsale_Already_Active();
    error TokenSale_Invalid_To_Address();
    error TokenSale_Sale_Min_Cap_Reached();
    error TokenSale_InsufficientBalance(address);
    error TokenSale_Refund_Tx_Failed();
    error TokenSale_Not_Contributed();
    error TokenSale_Owner_Cant_Buy();



    // modifers
    modifier isValidCapacities(uint _min, uint _max){
        if ( (_max == 0) || ( _min == 0) || (_min >= _max) ) {
            revert TokenSale_Invalid_Max_Min();
        }
        _;
    }

    modifier isValidDuration(uint _duration) {
        if (_duration == 0){
            revert TokenSale_Invalid_Sale_Duration();
        }
        _;
    }

    constructor(address _token) Ownable(msg.sender){
        if (_token == address(0)) revert TokenSale_Invalid_Token();
        token = IERC20(_token);
    }

    // Presale
    function startPreSale(uint _presaleMaxCap, uint _presaleMinCap, uint _presaleDuration, uint _minContribution, uint _maxContribution) public onlyOwner{
        if (isPresaleActive()) revert TokenSale_Presale_Already_Active();

        setPresaleCapacity(_presaleMinCap, _presaleMaxCap);
        setPresaleDuration(_presaleDuration);
        setContributionLimits(_minContribution, _maxContribution, true); // true ==> for presale

        presaleStartTime = block.timestamp;

        emit TokenSale_Pre_Sale_Started(block.timestamp);
    }

    // pubic sale

    function startPublicSale(uint _publicsaleMaxCap, uint _publicsaleMinCap,  uint _publicsaleDuration, uint _minContribution, uint _maxContribution) public onlyOwner{
        if (isPresaleActive()) revert TokenSale_Presale_Already_Active();
        if (!isPresaleHappened()) revert TokenSale_Presale_Not_Started();
        if (isPublicsaleActive()) revert TokenSale_Publicsale_Already_Active();

        setPublicsaleCapacity(_publicsaleMinCap, _publicsaleMaxCap);
        setPublicsaleDuration(_publicsaleDuration);
        setContributionLimits(_minContribution, _maxContribution, false); // false ==> for public sale

        publicsaleStartTime = block.timestamp;

        emit TokenSale_Public_Sale_Started(block.timestamp);

    }

    function buyTokensInPresale() public payable{
        if (msg.sender == owner()) revert TokenSale_Owner_Cant_Buy();
        if (!isPresaleActive()) revert TokenSale_Presale_Not_Started();
        uint amountSent = msg.value;
        uint currentContributions = presaleContributions[msg.sender];
        if (amountSent < presaleMinContribution) revert TokenSale_Not_Enough_Contribution();
        if(amountSent + currentContributions > presaleMaxContribution) revert TokenSale_Contribution_Limit_Passed();

        if (amountSent + amountRaisedInPresale > presaleMaxCap) revert TokenSale_Presale_Max_Cap_Passed();
        if (token.balanceOf(address(this)) < amountSent) revert TokenSale_Insufficient_Token_Balance();

        amountRaisedInPresale += amountSent;
        presaleContributions[msg.sender] += amountSent;

        token.safeTransfer(msg.sender, amountSent);

        emit TokenSale_Tokens_Sent_In_Presale(msg.sender, amountSent);

    }

    function buyTokensInPublicsale() public payable{
        if (msg.sender == owner()) revert TokenSale_Owner_Cant_Buy();
        if (!isPublicsaleActive()) revert TokenSale_Publicsale_Not_Started();
        if (isPresaleActive()) revert TokenSale_Presale_Already_Active(); // Additional check
        uint amountSent = msg.value;
        uint currentContributions = publicsaleContributions[msg.sender];
        if (amountSent < publicsaleMinContribution) revert TokenSale_Not_Enough_Contribution();
        if(amountSent + currentContributions > publicsaleMaxContribution) revert TokenSale_Contribution_Limit_Passed();

        if (amountSent + amountRaisedInPublicsale > publicsaleMaxCap) revert TokenSale_Publicsale_Max_Cap_Passed();
        if (token.balanceOf(address(this)) < amountSent) revert TokenSale_Insufficient_Token_Balance();

        amountRaisedInPublicsale += amountSent;
        publicsaleContributions[msg.sender] += amountSent;

        token.safeTransfer(msg.sender, amountSent);
        emit TokenSale_Tokens_Sent_In_Publicsale(msg.sender, amountSent);
    }


    // special function

    function sendTokensTo(address _to, uint value) public onlyOwner(){
        if (_to == address(0)) revert TokenSale_Invalid_To_Address();
        if (token.balanceOf(address(this)) < value) revert TokenSale_Insufficient_Token_Balance();

        token.safeTransfer(_to, value);
    }

    // claim refund if min cap not reached
    function claimRefund(bool _preSale, bool _pubSale) public{
        uint _presaleContributedAmt = presaleContributions[msg.sender];
        uint _publicsaleContributedAmt = publicsaleContributions[msg.sender];

        if (_presaleContributedAmt == 0 && _publicsaleContributedAmt == 0) revert TokenSale_Not_Contributed();
        
        if (_preSale){

            if(isPresaleActive()) revert TokenSale_Presale_Already_Active();

            if (amountRaisedInPresale < presaleMinCap){
                presaleContributions[msg.sender] = 0;
                sendValue(payable(msg.sender), _presaleContributedAmt);
                emit Token_Presale_Refund_Success(msg.sender, _presaleContributedAmt);
            }
            else{
                revert TokenSale_Sale_Min_Cap_Reached();
            }
        
        }
        if (_pubSale){

            if(isPublicsaleActive()) revert TokenSale_Publicsale_Already_Active(); 

            if (amountRaisedInPublicsale < publicsaleMinCap){
                publicsaleContributions[msg.sender] = 0;
                sendValue(payable(msg.sender), _publicsaleContributedAmt);
                emit Token_Publicsale_Refund_Success(msg.sender, _publicsaleContributedAmt);
            }
            else{
                revert TokenSale_Sale_Min_Cap_Reached();
            }
        }
    }

    // Secure function to send value
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert TokenSale_InsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert TokenSale_Refund_Tx_Failed();
        }
    }


    // setters
    function setPresaleCapacity(uint _presaleMinCap, uint _presaleMaxCap) public 
    onlyOwner() 
    isValidCapacities(_presaleMinCap, _presaleMaxCap)
    {
        presaleMinCap = _presaleMinCap;
        presaleMaxCap = _presaleMaxCap;
        
        emit TokenSale_PreSale_Cap_Set(_presaleMinCap,_presaleMaxCap);
    }

     function setPublicsaleCapacity(uint _publicsaleMinCap, uint _publicsaleMaxCap) public 
     onlyOwner() 
     isValidCapacities(_publicsaleMinCap, _publicsaleMaxCap)
     {
        publicsaleMinCap = _publicsaleMinCap;
        publicsaleMaxCap = _publicsaleMaxCap;

        emit TokenSale_PublicSale_Cap_Set(_publicsaleMinCap,_publicsaleMaxCap);
    }

    function setPresaleDuration(uint _presaleDuration) public 
    onlyOwner()
    isValidDuration(_presaleDuration)
    {
        presaleDuration = _presaleDuration;
    }

    function setPublicsaleDuration(uint _publicsaleDuration) public 
    onlyOwner()
    isValidDuration(_publicsaleDuration)
    {
        publicsaleDuration = _publicsaleDuration;
    }

    function setContributionLimits(uint minContribution, uint maxContribution, bool forPresale) public 
    onlyOwner()
    isValidCapacities(minContribution, maxContribution)
    {
        if (forPresale){
            presaleMinContribution = minContribution;
            presaleMaxContribution = maxContribution;
            emit TokenSale_PreSale_Contribution_Limits_Changed(minContribution, maxContribution);
        }
        else{
            publicsaleMinContribution = minContribution;
            publicsaleMaxContribution = maxContribution;
            emit TokenSale_PublicSale_Contribution_Limits_Changed(minContribution, maxContribution);
        }
    }

    // getters

    function isPresaleActive() public view returns (bool){
        if ((block.timestamp - presaleStartTime < presaleDuration) && presaleStartTime != 0){
            return true;
        }
        return false;
    }

    function isPublicsaleActive() public view returns (bool){
        if ((block.timestamp - publicsaleStartTime < publicsaleDuration) && publicsaleStartTime != 0){
            return true;
        }
        return false;
    }

    function isPresaleHappened() public view returns (bool){
        if ((block.timestamp - presaleStartTime >= presaleDuration) && presaleStartTime != 0){
            return true;
        }
        return false;
    }

    // Emergency withdraw function
    function withdraw() external onlyOwner(){
        token.safeTransfer(owner(), token.balanceOf(address(this)));
        sendValue(payable(owner()), address(this).balance);
        emit TokenSale_Emergency_Withdraw(owner());

    }
    receive() external payable{
        emit TokenSale_Thanks_For_Donation(msg.sender);
    }


}
