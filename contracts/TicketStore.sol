// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TicketStore is ERC1155, ERC1155Holder, Ownable  {

    constructor() ERC1155("") {}

    using Counters for Counters.Counter; 
    Counters.Counter private _eventId;

    struct Event {
        uint id;
        uint price;
        uint ticketSupply;
        string singer;
    }

    mapping(uint => Event) private _idToEvent;
    mapping(address => uint) private _pendingWithdrawals;

    event eventCreated(uint indexed id, uint price, uint ticketSupply, string indexed singer);
    event ticketBuyed(uint indexed id, address _buyer, uint _amount);

    function createEvent(uint _price, uint _ticketSupply, string memory _singer) onlyOwner public {
        require(_price > 0, "Price must be greater than 0");
        require(_ticketSupply > 0, "Ticket supply must be greater than 0");

        uint _id = _eventId.current();
        _eventId.increment();
        _mint(address(this), _id, _ticketSupply, "");
        _idToEvent[_id] = Event(
            _id,
            _price,
            _ticketSupply,
            _singer
        );

        emit eventCreated(_id, _price, _ticketSupply, _singer);
    }

    function buyEvent(uint _id, uint _amount) public payable {
        Event memory _event = _idToEvent[_id];
        require(_event.ticketSupply > 0 && _amount <= _event.ticketSupply, "Supply for this ticket is not enough");
        require(msg.value == _event.price * _amount, "Transaction value not equal to price required");

        _safeTransferFrom(address(this), msg.sender, _event.id, _amount, "");
        _event.ticketSupply -= _amount;
        _idToEvent[_id] = _event;

        emit ticketBuyed(_id, msg.sender, _amount);
    }

    function withdraw() public {
        uint amount = _pendingWithdrawals[msg.sender];
        _pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, ERC1155Receiver)
        returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}