// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title A simple lottery contract
/// @author Your Name
/// @notice This contract allows users to buy tickets and randomly selects a winner
/// @dev This uses a pseudo-random number generation which is not secure for production use
contract Lottery {
    address public owner;
    uint256 public ticketPrice;
    address[] public participants;
    bool public lotteryOpen;

    event TicketPurchased(address buyer);
    event WinnerSelected(address winner, uint256 amount);

    /// @notice Initializes the lottery with a ticket price
    /// @dev Sets the contract creator as the owner
    /// @param _ticketPrice The price of each lottery ticket in wei
    constructor(uint256 _ticketPrice) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        lotteryOpen = true;
    }

    /// @notice Allows a user to buy a lottery ticket
    /// @dev Adds the buyer's address to the participants array
    function buyTicket() public payable {
        require(lotteryOpen, "Lottery is closed");
        require(msg.value == ticketPrice, "Incorrect ticket price");

        participants.push(msg.sender);
        emit TicketPurchased(msg.sender);
    }

    /// @notice Selects a winner for the lottery
    /// @dev Only the owner can call this function. Uses a pseudo-random selection process.
    function selectWinner() public {
        require(msg.sender == owner, "Only owner can select winner");
        require(participants.length > 0, "No participants");

        lotteryOpen = false;
        uint256 index = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % participants.length;
        address winner = participants[index];
        uint256 prize = address(this).balance;

        (bool success, ) = winner.call{value: prize}("");
        require(success, "Failed to send prize");

        emit WinnerSelected(winner, prize);
        
        // Reset for next round
        delete participants;
        lotteryOpen = true;
    }

    /// @notice Returns the number of participants in the current lottery
    /// @return The number of participants
    function getParticipantCount() public view returns (uint256) {
        return participants.length;
    }
}
