pragma solidity 0.8.9;

import "../../../PaymentProcessorSaleScenarioBase.t.sol";

contract AcceptSingleItemLevelOfferMarketplaceAndRoyaltyFeeColdPurchase is PaymentProcessorSaleScenarioBase {

    function setUp() public virtual override {
        super.setUp();

        erc721Mock.mintTo(sellerEOA, _getNextAvailableTokenId(address(erc721Mock)));
        erc721Mock.mintTo(sellerEOA, _getNextAvailableTokenId(address(erc721Mock)));
    }

    function test_executeSale() public {
        MatchedOrder memory saleDetails = MatchedOrder({
            sellerAcceptedOffer: true,
            collectionLevelOffer: false,
            protocol: TokenProtocols.ERC721,
            paymentCoin: address(approvedPaymentCoin),
            tokenAddress: address(erc721Mock),
            seller: sellerEOA,
            privateBuyer: address(0),
            buyer: buyerEOA,
            delegatedPurchaser: address(0),
            marketplace: address(marketplaceMock),
            marketplaceFeeNumerator: 500,
            maxRoyaltyFeeNumerator: 1000,
            listingNonce: _getNextNonce(sellerEOA),
            offerNonce: _getNextNonce(buyerEOA),
            listingMinPrice: 1 ether,
            offerPrice: 1 ether,
            listingExpiration: type(uint256).max,
            offerExpiration: type(uint256).max,
            tokenId: _getNextAvailableTokenId(address(erc721Mock)),
            amount: 1
        });

        _mintAndDealTokensForSale(saleDetails.protocol, address(royaltyReceiverMock), saleDetails);

        vm.prank(saleDetails.seller);
        paymentProcessor.buySingleListing(
            saleDetails, 
            _getSignedListing(sellerKey, saleDetails), 
            _getSignedOffer(buyerKey, saleDetails));

        assertEq(erc721Mock.balanceOf(sellerEOA), 2);
        assertEq(erc721Mock.balanceOf(buyerEOA), 1);

        assertEq(erc721Mock.ownerOf(0), sellerEOA);
        assertEq(erc721Mock.ownerOf(1), sellerEOA);
        assertEq(erc721Mock.ownerOf(2), buyerEOA);

        assertEq(approvedPaymentCoin.balanceOf(sellerEOA), 0.85 ether);
        assertEq(approvedPaymentCoin.balanceOf(buyerEOA), 0 ether);
        assertEq(approvedPaymentCoin.balanceOf(address(marketplaceMock)), 0.05 ether);
        assertEq(approvedPaymentCoin.balanceOf(address(royaltyReceiverMock)), 0.1 ether);
    }
}