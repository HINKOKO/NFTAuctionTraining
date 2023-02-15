// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./IMdNFT.sol";

contract MdAuction is Ownable, ERC721Holder {
	// MdNft contract so we need an uinterface of MdNFT
	enum AuctionState {
		OPENED,
		EXPIRED,
		CLOSED
	}
	struct Auction {
		uint256 nftId;
		uint256 startTime;
		uint256 endTime;
		uint256 currentBid;
		address currentBidder;
	}

	mapping(uint256 => Auction) public auctions;
	uint256 public auctionLength;
	IERC20 standardToken;
	IMdNFT standardNFT;
	// mapping(address => uint256) tokenBalances;
	uint256 public durationAuction = 20 * 60;
	uint256 balances; 
	uint256 public entranceFee = 5 * 10 ** 12; // 0.000005 eth for bidding
	AuctionState public contractState;

	event newAuctionOpened(uint256 nftId, uint256 startTime, uint256 endTime);
	event newAuctionClosed(uint256 nftId, address newOwner, uint256 finalPrice);
	event newPlaceBid(uint256 nftId, address bidder, uint256 bidPrice);

	constructor(address _token, address _nft) {
		standardToken = IERC20(_token);
		standardNFT = IMdNFT(_nft);
	}

	// Receive token, msg.data is empty 
	receive() external payable {
		balances = balances + msg.value;
	}

	// Receive token, msg.data not empty
	fallback() external payable {
		balances = balances + msg.value;

	}

	function setStandardToken(address _token) public onlyOwner {
		standardToken = IERC20(_token);
	}

	function setStandardNFT(address _nft) public onlyOwner {
		standardNFT = IMdNFT(_nft);
	}

	function getBalances() public view onlyOwner returns(uint256) {
		return balances;
	}

	function openAuction(string memory _uri) public onlyOwner {
		require(checkStatus() == uint8(AuctionState.CLOSED), "Auction state must be close to become open");
		// Precondition: contractState = CLOSED
		uint256 nftId = standardNFT.mintValidTarget(address(this), _uri);
		auctions[auctionLength] = Auction(
			nftId,
			block.timestamp,
			block.timestamp + durationAuction,
			0,
			address(this)
		);
		auctionLength += 1; // now we go to new session of auction
		contractState = AuctionState.OPENED;
		emit newAuctionOpened(nftId, auctions[auctionLength - 1].startTime, auctions[auctionLength -1].endTime);
	}

	function closeAuction() public onlyOwner {
		// Precondition: contractState = EXPIRED
		// Transfer nft to new owner
		// change contract state to CLOSED
		require(checkStatus() == uint8(AuctionState.EXPIRED), "Auction not ended yet");
		if (auctions[auctionLength - 1].currentBid > 0) {
			// if anyonne bid for the session ? 
			standardNFT.safeTransferFrom(address(this), auctions[auctionLength - 1].currentBidder, auctions[auctionLength - 1].nftId);
		}
		else {
			standardNFT.burn(auctions[auctionLength - 1].nftId);
		}
		contractState = AuctionState.CLOSED;
		emit newAuctionClosed(auctions[auctionLength - 1].nftId, auctions[auctionLength - 1].currentBidder, auctions[auctionLength - 1].currentBid);

	}

	function placeBid(uint256 _amount) public payable {
		require(checkStatus() == uint8(AuctionState.OPENED), "Auction not opened");
		require(msg.value >= entranceFee, "You have to put entrance Fee + your bid");
		require(_amount > auctions[auctionLength - 1].currentBid, "Bid more than the previous guy!");
		balances += msg.value;
		uint256 allowance = standardToken.allowance(msg.sender, address(this));
		require(allowance >= _amount, "MdAuction: MDToken Overallowance");
		bool success = standardToken.transferFrom(msg.sender, address(this), _amount);
		require (success, "MDAuction: fail to transfer token");
		if (auctions[auctionLength - 1].currentBid > 0) {
			// there exists previous bidder(s)
			success = standardToken.transfer(auctions[auctionLength - 1].currentBidder, auctions[auctionLength - 1].currentBid);
			require(success, "Failed to transfer, cannot");
		}
		auctions[auctionLength - 1].currentBid = _amount;
		auctions[auctionLength - 1].currentBidder = msg.sender;
		emit newPlaceBid(auctions[auctionLength - 1].nftId, auctions[auctionLength - 1].currentBidder, auctions[auctionLength - 1].currentBid);
	} 


	function checkStatus() public view returns(uint8) {
		if (auctionLength == 0) {
			return uint8(AuctionState.CLOSED);
		}
		else if (
			block.timestamp > auctions[auctionLength - 1].endTime &&
			contractState == AuctionState.OPENED) {
			// that means we reached endTime , no more bids allowed
			return uint8(AuctionState.EXPIRED);
		}
		else {
			return uint8(contractState);
		}
	}

	// TESTING
	function changeState(uint8 _state) public {
		if (_state == 0) {
			contractState = AuctionState.OPENED;
		}
		else if (_state == 1) {
			contractState = AuctionState.EXPIRED;
		}
		else {
			contractState = AuctionState.CLOSED;
		}
	}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


// 1.0 open auction => mint a new nft, everybody will place bid to gain this nft


// 2. close auction => when close auction, nft transfered to winner/highestbidder

// 3. place bid: put a new bid on the auction running
