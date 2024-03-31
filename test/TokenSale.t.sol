// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {EliteToken} from "../src/MyToken.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {DeployScript} from "../script/DeployScript.s.sol";
import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
contract TokenSaleTest is Test {
    EliteToken public myToken;
    TokenSale public tokenSale;
    function setUp() public {
        myToken = new EliteToken();
        tokenSale = new TokenSale(address(myToken));
        myToken.transfer(address(tokenSale), 10000 ether);  // 10000 tokens for sale
    }

    function testTokenBalance() public{
        assertEq(myToken.balanceOf(address(tokenSale)), 10000 ether);
        assertEq(myToken.balanceOf(address(this)),(100000 ether -  10000 ether));
    }

    function testInitialization() public {
        assertEq(tokenSale.owner(), address(this));
    }

    // Testing setPresaleCapacity()
    function testSetPresaleCapacity() public{
        tokenSale.setPresaleCapacity(1 ether, 10 ether);
        
        assertEq(tokenSale.presaleMinCap(), 1 ether);
        assertEq(tokenSale.presaleMaxCap(), 10 ether);
    }

    function testSetPresaleCapacityNotOwner() public {
        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.setPresaleCapacity(1 ether, 10 ether);
    }

    function testSetPresaleCapacityInvalidParams() public{
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.setPresaleCapacity(0, 10 ether);
        
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.setPresaleCapacity(0, 0);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.setPresaleCapacity(1 ether, 0);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.setPresaleCapacity(10 ether, 1 ether);

    }

    // Testing setPublicsaleCapacity()
    function testSetPublicsaleCapacity() public{
        tokenSale.setPublicsaleCapacity(1 ether, 10 ether);
        
        assertEq(tokenSale.publicsaleMinCap(), 1 ether);
        assertEq(tokenSale.publicsaleMaxCap(), 10 ether);
    }

    function testSetPublicsaleCapacityNotOwner() public {
        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.setPublicsaleCapacity(1 ether, 10 ether);
    }

    function testSetPublicsaleCapacityInvalidParams() public{
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.setPublicsaleCapacity(0, 10 ether);
        
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.setPublicsaleCapacity(0, 0);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.setPublicsaleCapacity(1 ether, 0);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.setPublicsaleCapacity(10 ether, 1 ether);
    }

    // testing Duration set
    function testSetPresaleDuration() public{
        tokenSale.setPresaleDuration(1 days);
        assertEq(tokenSale.presaleDuration(), 1 days);
    }

    function testSetPresaleDurationNotOwner() public{
        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.setPresaleDuration(1 days);
    }

    function testSetPresaleDurationInvalidDuration() public{
        vm.expectRevert(TokenSale.TokenSale_Invalid_Sale_Duration.selector);
        tokenSale.setPresaleDuration(0);
    }

    function testSetPublicsaleDuration() public{
        tokenSale.setPublicsaleDuration(1 days);
        assertEq(tokenSale.publicsaleDuration(), 1 days);
    }

    function testSetPublicsaleDurationNotOwner() public{
        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.setPresaleDuration(1 days);
    }

    function testSetPublicsaleDurationInvalidDuration() public{
        vm.expectRevert(TokenSale.TokenSale_Invalid_Sale_Duration.selector);
        tokenSale.setPublicsaleDuration(0);
    }

    // test contribution set

    function testSetContributionLimitsPresale() public{
        tokenSale.setContributionLimits(1 ether, 10 ether, true); // presale
        assertEq(tokenSale.presaleMinContribution(), 1 ether);
        assertEq(tokenSale.presaleMaxContribution(), 10 ether);
        vm.expectEmit();
        emit TokenSale.TokenSale_PreSale_Contribution_Limits_Changed(1 ether, 10 ether);
        tokenSale.setContributionLimits(1 ether, 10 ether, true); // presale
    }

    function testSetContributionLimitsNotOwnerPresale() public{
        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.setContributionLimits(1 ether, 10 ether, true); // presale

    }
    function testSetContributionLimitsPublicsale() public{
        tokenSale.setContributionLimits(1 ether, 10 ether, false); // public sale
        assertEq(tokenSale.publicsaleMinContribution(), 1 ether);
        assertEq(tokenSale.publicsaleMaxContribution(), 10 ether);
        vm.expectEmit();
        emit TokenSale.TokenSale_PublicSale_Contribution_Limits_Changed(1 ether, 10 ether);
        tokenSale.setContributionLimits(1 ether, 10 ether, false); // public sale
    }

    function testSetContributionLimitsNotOwnerPublicsale() public{
        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.setContributionLimits(1 ether, 10 ether, false); // presale

    }

    function testSetContributionLimitsCrossCheck() public{
        vm.expectEmit();
        emit TokenSale.TokenSale_PreSale_Contribution_Limits_Changed(1 ether, 10 ether);
        tokenSale.setContributionLimits(1 ether, 10 ether, true); // presale
        assertEq(tokenSale.publicsaleMinContribution(), 0);
        assertEq(tokenSale.publicsaleMaxContribution(), 0);

        tokenSale.setContributionLimits(1 ether, 10 ether, false); // presale
        assertEq(tokenSale.presaleMinContribution(), 1 ether);
        assertEq(tokenSale.presaleMaxContribution(), 10 ether);
    }

    // startPresale
    function testStartPresale() public{
        vm.expectEmit();
        emit TokenSale.TokenSale_Pre_Sale_Started(block.timestamp);
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
    }

    function testStartPresaleNotOwner() public{
        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
    }
    function testStartPresaleTime() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        assertEq(tokenSale.presaleStartTime(), block.timestamp);
    }
    function testStartPresaleInvalidCap() public{
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(100 ether, 0 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(0 ether, 1 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(1 ether, 10 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(0 ether, 0 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(100 ether, 100 ether, 1 days, 1 ether, 10 ether);
    }

    function testStartPresaleInvalidDuration() public{
        vm.expectRevert(TokenSale.TokenSale_Invalid_Sale_Duration.selector);
        tokenSale.startPreSale(100 ether, 10 ether, 0, 1 ether, 10 ether);
    }

    function testStartPresaleInvalidContribution() public{
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(100 ether, 10 ether, 1 days, 0 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(100 ether, 10 ether, 1 days, 1 ether, 0 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(100 ether, 10 ether, 1 days, 10 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(100 ether, 10 ether, 1 days, 10 ether, 1 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPreSale(100 ether, 10 ether, 1 days, 0 ether, 0 ether);

    }

    function testStartPresaleAgain() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.expectRevert(TokenSale.TokenSale_Presale_Already_Active.selector);
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
    }

    // start preSale after fisrt one over
    function testStartPresaleAgainAfterEnd() public{
        vm.expectEmit();
        emit TokenSale.TokenSale_Pre_Sale_Started(block.timestamp);
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);


        vm.warp(block.timestamp + 1 days);
        vm.expectEmit();
        emit TokenSale.TokenSale_Pre_Sale_Started(block.timestamp);
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);


        vm.warp(block.timestamp + 1 days-1);
        vm.expectRevert(TokenSale.TokenSale_Presale_Already_Active.selector);
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);

        vm.warp(block.timestamp + 3 days);
        vm.expectEmit();
        emit TokenSale.TokenSale_Pre_Sale_Started(block.timestamp);
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);

        assertEq(tokenSale.presaleStartTime(), block.timestamp);

    }

     // startPublic
    function testStartPublicsale() public{
        
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);

        vm.expectEmit();
        emit TokenSale.TokenSale_Public_Sale_Started(block.timestamp);
        tokenSale.startPublicSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
    }
    function testStartPublicsaleNotOwner() public{
        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.startPublicSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
    }
    function testStartPublicsalePresaleRunning() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Presale_Already_Active.selector);
        tokenSale.startPublicSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
    }

    function testStartPublicsalePresaleNotStarted() public{
        vm.expectRevert(TokenSale.TokenSale_Presale_Not_Started.selector);
        tokenSale.startPublicSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
    }

    function testStartPublicsaleAgain() public{

        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);

        vm.warp(block.timestamp + 1 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Publicsale_Already_Active.selector);
        tokenSale.startPublicSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
    }

    function testStartPublicsaleAgainAfterEnd() public{

        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);

        vm.warp(block.timestamp + 1 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        vm.warp(block.timestamp + 2 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);
    }

    // test invalid params
     function testStartPublicsaleInvalidCap() public{
        testStartPresale();
        vm.warp(block.timestamp + 1 days);


        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(100 ether, 0 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(0 ether, 1 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(1 ether, 10 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(0 ether, 0 ether, 1 days, 1 ether, 10 ether);

        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(100 ether, 100 ether, 1 days, 1 ether, 10 ether);
    }

    function testStartPublicsaleInvalidDuration() public{
        testStartPresale();
        vm.warp(block.timestamp + 1 days);
        
        vm.expectRevert(TokenSale.TokenSale_Invalid_Sale_Duration.selector);
        tokenSale.startPublicSale(100 ether, 10 ether, 0, 1 ether, 10 ether);
    }

    function testStartPublicsaleInvalidContribution() public{
        testStartPresale();
        vm.warp(block.timestamp + 1 days);
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(100 ether, 10 ether, 1 days, 0 ether, 10 ether);

        testStartPresale();
        vm.warp(block.timestamp + 1 days);
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(100 ether, 10 ether, 1 days, 1 ether, 0 ether);

        testStartPresale();
        vm.warp(block.timestamp + 1 days);
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(100 ether, 10 ether, 1 days, 10 ether, 10 ether);

        testStartPresale();
        vm.warp(block.timestamp + 1 days);
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(100 ether, 10 ether, 1 days, 10 ether, 1 ether);

        testStartPresale();
        vm.warp(block.timestamp + 1 days);
        vm.expectRevert(TokenSale.TokenSale_Invalid_Max_Min.selector);
        tokenSale.startPublicSale(100 ether, 10 ether, 1 days, 0 ether, 0 ether);

    }

    // test Buy tokens in pre sale

    function testBuyTokensInPresale() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        hoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 1 ether}();

        assertEq(myToken.balanceOf(address(0x1)), 1 ether);
        assertEq(address(tokenSale).balance, 1 ether);
    }
    function testBuyTokensInPresaleMaxContribute() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 1 ether}();
        tokenSale.buyTokensInPresale{value: 1 ether}();
        tokenSale.buyTokensInPresale{value: 8 ether}();


        assertEq(myToken.balanceOf(address(0x1)), 10 ether);
        assertEq(address(tokenSale).balance, 10 ether);
    }
    function testBuyTokensInPresaleAfterSomeTime() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 1 ether}();
        tokenSale.buyTokensInPresale{value: 1 ether}();
        
        vm.warp(block.timestamp+1000);
        tokenSale.buyTokensInPresale{value: 8 ether}();


        assertEq(myToken.balanceOf(address(0x1)), 10 ether);
        assertEq(address(tokenSale).balance, 10 ether);
    }

    function testBuyTokensInPresaleContributeLimits() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        startHoax(address(0x1), 12 ether);

        vm.expectRevert(TokenSale.TokenSale_Contribution_Limit_Passed.selector);
        tokenSale.buyTokensInPresale{value: 11 ether}();

        vm.expectRevert(TokenSale.TokenSale_Not_Enough_Contribution.selector);
        tokenSale.buyTokensInPresale{value: 0.1 ether}();

    }

    function testBuyTokensInPresaleNotStarted() public{
        startHoax(address(0x1), 10 ether);
        vm.expectRevert(TokenSale.TokenSale_Presale_Not_Started.selector);
        tokenSale.buyTokensInPresale{value: 1 ether}();
    }

    function testBuyTokensInPresaleOver() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);

        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 1 ether}();
        assertEq(myToken.balanceOf(address(0x1)), 1 ether);

        vm.warp(block.timestamp + 1 days);

        vm.expectRevert(TokenSale.TokenSale_Presale_Not_Started.selector);
        tokenSale.buyTokensInPresale{value: 1 ether}();
    }

    function testBuyTokensInPresaleCapLimits() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 50 ether);

        startHoax(address(0x1), 60 ether);
        tokenSale.buyTokensInPresale{value: 50 ether}();
        assertEq(myToken.balanceOf(address(0x1)), 50 ether);

        startHoax(address(0x2), 60 ether);
        tokenSale.buyTokensInPresale{value: 40 ether}();
        assertEq(myToken.balanceOf(address(0x2)), 40 ether);

        startHoax(address(0x3), 60 ether);
        vm.expectRevert(TokenSale.TokenSale_Presale_Max_Cap_Passed.selector);
        tokenSale.buyTokensInPresale{value: 50 ether}();
    }

    function testBuyTokensInPresaleInsufficientBal() public{
        EliteToken _myToken = new EliteToken();
        TokenSale _tokenSale = new TokenSale(address(_myToken));
        _myToken.transfer(address(_tokenSale), 1 ether);
        _tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 50 ether);

        assertEq(_myToken.balanceOf(address(_tokenSale)), 1 ether);

        startHoax(address(0x1), 10 ether);
        vm.expectRevert(TokenSale.TokenSale_Insufficient_Token_Balance.selector);
        _tokenSale.buyTokensInPresale{value: 2 ether}();
    }

    function testBuyTokensInPresaleWhileAndAfterPublicSale() public{
        
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);

        vm.expectEmit();
        emit TokenSale.TokenSale_Public_Sale_Started(block.timestamp);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        startHoax(address(0x1), 10 ether);
        vm.expectRevert(TokenSale.TokenSale_Presale_Not_Started.selector);
        tokenSale.buyTokensInPresale{value: 2 ether}();

        vm.warp(block.timestamp + 2 days);
        vm.expectRevert(TokenSale.TokenSale_Presale_Not_Started.selector);
        tokenSale.buyTokensInPresale{value: 2 ether}();


    }

    // buy tokens in public sale
    function testBuyTokensInPublicsale() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPublicsale{value: 1 ether}();

        assertEq(myToken.balanceOf(address(0x1)), 1 ether);
        assertEq(address(tokenSale).balance, 1 ether);
    }
    function testBuyTokensInPublicsaleMaxContribute() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);        
        
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPublicsale{value: 1 ether}();
        tokenSale.buyTokensInPublicsale{value: 1 ether}();
        tokenSale.buyTokensInPublicsale{value: 8 ether}();


        assertEq(myToken.balanceOf(address(0x1)), 10 ether);
        assertEq(address(tokenSale).balance, 10 ether);
    }

    function testBuyTokensInPublicsaleContributeLimits() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        startHoax(address(0x1), 12 ether);

        vm.expectRevert(TokenSale.TokenSale_Contribution_Limit_Passed.selector);
        tokenSale.buyTokensInPublicsale{value: 11 ether}();

        vm.expectRevert(TokenSale.TokenSale_Not_Enough_Contribution.selector);
        tokenSale.buyTokensInPublicsale{value: 0.1 ether}();

    }

    function testBuyTokensInPublicsaleNotStarted() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);

        startHoax(address(0x1), 10 ether);
        vm.expectRevert(TokenSale.TokenSale_Publicsale_Not_Started.selector);
        tokenSale.buyTokensInPublicsale{value: 1 ether}();
    }



    function testBuyTokensInPublicsaleOver() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        vm.warp(block.timestamp + 2 days);
        
        startHoax(address(0x1), 10 ether);
        vm.expectRevert(TokenSale.TokenSale_Publicsale_Not_Started.selector);
        tokenSale.buyTokensInPublicsale{value: 1 ether}();
    }

    function testBuyTokensInPublicsaleCapLimits() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 50 ether);

        startHoax(address(0x1), 60 ether);
        tokenSale.buyTokensInPublicsale{value: 50 ether}();
        assertEq(myToken.balanceOf(address(0x1)), 50 ether);

        startHoax(address(0x2), 60 ether);
        tokenSale.buyTokensInPublicsale{value: 40 ether}();
        assertEq(myToken.balanceOf(address(0x2)), 40 ether);

        startHoax(address(0x3), 60 ether);
        vm.expectRevert(TokenSale.TokenSale_Publicsale_Max_Cap_Passed.selector);
        tokenSale.buyTokensInPublicsale{value: 50 ether}();
    }

    function testBuyTokensInPublicsaleInsufficientBal() public{
        EliteToken _myToken = new EliteToken();
        TokenSale _tokenSale = new TokenSale(address(_myToken));
        _myToken.transfer(address(_tokenSale), 1 ether);
        
        _tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);
        _tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        assertEq(_myToken.balanceOf(address(_tokenSale)), 1 ether);

        startHoax(address(0x1), 10 ether);
        vm.expectRevert(TokenSale.TokenSale_Insufficient_Token_Balance.selector);
        _tokenSale.buyTokensInPublicsale{value: 2 ether}();
    }

    function testBuyTokensInPrePublicsales() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 10 ether}();

        vm.warp(block.timestamp + 1 days);

        vm.startPrank(address(this));
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPublicsale{value: 9 ether}();

        assertEq(myToken.balanceOf(address(0x1)), 19 ether);

        vm.warp(block.timestamp + 2 days);
        startHoax(address(0x1), 10 ether);
        vm.expectRevert(TokenSale.TokenSale_Publicsale_Not_Started.selector);
        tokenSale.buyTokensInPublicsale{value:  1 ether}();
    }

    function testsendTokensTo() public{
        tokenSale.sendTokensTo(address(0x2), 10);
        assertEq(myToken.balanceOf(address(0x2)), 10);

        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.sendTokensTo(address(0x2), 10);   
    }

    function testReceive() public{
        startHoax(address(0x1), 10 ether);
        vm.expectEmit(true,false,false,false);
        emit TokenSale.TokenSale_Thanks_For_Donation(address(0x1));
        (bool success, ) = address(tokenSale).call{value : 10 ether}("");
        require(success);        
    }

    function testIsPresaleActive() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        // vm.warp(block.timestamp + 1 days);
        // tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);
        assertTrue(tokenSale.isPresaleActive());
        vm.warp(block.timestamp + 1 days);
        assertFalse(tokenSale.isPresaleActive());

    }

    function testIsPublicsaleActive() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        vm.warp(block.timestamp + 1 days);
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);
        
        assertFalse(tokenSale.isPresaleActive());
        
        assertTrue(tokenSale.isPublicsaleActive());
        vm.warp(block.timestamp + 2 days);
        assertFalse(tokenSale.isPublicsaleActive());

    }

    function testIsPublicsaleHappened() public{
        assertFalse(tokenSale.isPresaleHappened());

        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        
        assertFalse(tokenSale.isPresaleHappened());
        vm.warp(block.timestamp + 3 days);
        assertTrue(tokenSale.isPresaleHappened());
    }

    function testClaimRefundPresale() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 10 ether}();
        assertEq(address(0x1).balance, 0);

        vm.warp(block.timestamp + 1 days);
        tokenSale.claimRefund(true, false);
        assertEq(address(0x1).balance, 10 ether);

    }

    function testClaimRefundPresaleNotEnd() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 10 ether}();
        assertEq(address(0x1).balance, 0);

        vm.expectRevert(TokenSale.TokenSale_Presale_Already_Active.selector);
        tokenSale.claimRefund(true, false);

    }

    function testClaimRefundPublicsale() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 10 ether}();

        vm.warp(block.timestamp + 1 days);

        vm.startPrank(address(this));
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPublicsale{value: 10 ether}();

        assertEq(address(0x1).balance, 0 ether);

        vm.warp(block.timestamp + 2 days);
        tokenSale.claimRefund(false, true);
        assertEq(address(0x1).balance, 10 ether);

    }

    function testClaimRefundPrePublicsalesNotEnd() public{
        tokenSale.startPreSale(100 ether, 50 ether, 1 days, 1 ether, 10 ether);
        
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 10 ether}();

        vm.warp(block.timestamp + 1 days);

        vm.startPrank(address(this));
        tokenSale.startPublicSale(100 ether, 50 ether, 2 days, 1 ether, 10 ether);

        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPublicsale{value: 10 ether}();

        assertEq(address(0x1).balance, 0 ether);

        vm.expectRevert(TokenSale.TokenSale_Publicsale_Already_Active.selector);
        tokenSale.claimRefund(false, true);
    }

    function testClaimRefundPrePublicsalesMinCapReached() public{
        tokenSale.startPreSale(100 ether, 10 ether, 1 days, 1 ether, 10 ether);
        
        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPresale{value: 10 ether}();

        vm.warp(block.timestamp + 1 days);

        vm.startPrank(address(this));
        tokenSale.startPublicSale(100 ether, 10 ether, 2 days, 1 ether, 10 ether);

        startHoax(address(0x1), 10 ether);
        tokenSale.buyTokensInPublicsale{value: 10 ether}();

        assertEq(address(0x1).balance, 0 ether);

        vm.expectRevert(TokenSale.TokenSale_Sale_Min_Cap_Reached.selector);
        tokenSale.claimRefund(true, true);
    }

    // withdraw
    function testWithdraw() public{
        
        vm.expectEmit(true, false, false, false);
        emit TokenSale.TokenSale_Emergency_Withdraw(address(this));
        tokenSale.withdraw();


        vm.prank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1))
        );
        tokenSale.withdraw();
    }

    // test deploy script
    function testDeployScript() public{
        DeployScript script = new DeployScript();
        script.run();
        assertTrue(address(script.token()) != address(0));
        assertTrue(address(script.sale()) != address(0));
        address sale = address(script.sale());
        uint bal = script.token().balanceOf(sale);
        assertEq(bal, 10000);
    }

    receive() external payable{} // to receive withdraw amount

}
