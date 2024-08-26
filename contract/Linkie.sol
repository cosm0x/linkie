// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISuperfluid, ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

//TODOS: add events
contract Linkie {
  using SuperTokenV1Library for ISuperToken;

  uint256 systemFee;
  address owner;
  ISuperToken public usdtx; // SuperToken to be streamed

  struct Campaign {
    string id;
    address creator;
    address creative;
    uint256 milestoneCount;
    uint96 paymentCount;
    uint256 amount;
    int96 baseFlowRate;
    int96 currentFlowRate;
    bool isStreaming;
    bool isCompleted;
  }

  struct Creative {
    uint256 xp;
  }

  mapping(string => Campaign) campaigns;
  mapping(address => Creative) public creatives;

  constructor(uint256 _systemFee, ISuperToken _usdtx) {
    systemFee = _systemFee;
    owner = msg.sender;
    usdtx = _usdtx; // Initialize the SuperToken
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner allowed");
    _;
  }

  //this activates the campaign
  function createCampaign(
    string calldata _campaignId,
    uint256 _milestoneCount,
    uint256 _amount,
    int96 _baseFlowRate
  ) external payable {
    require(_amount > 0, "invalid amount");
    //saves the campaign on-chain
    campaigns[_campaignId] = Campaign({
      id: _campaignId,
      creator: msg.sender,
      creative: address(0),
      amount: msg.value,
      milestoneCount: _milestoneCount,
      paymentCount: 0,
      baseFlowRate: _baseFlowRate,
      currentFlowRate: _baseFlowRate,
      isStreaming: false,
      isCompleted: false
    });
  }

  //matches a creative to a campaign
  function matchCampaign(
    string calldata campaignId,
    address _creative
  ) external {
    require(campaigns[campaignId].creator == msg.sender, "Not permitted");
    campaigns[campaignId].creative = _creative;
  }

  //pays each milestone on creator/business approval  with Superfluid streaming
  function payMilestone(string calldata campaignId) external {
    Campaign storage campaign = campaigns[campaignId];

    require(campaign.creator == msg.sender, "Not permitted");
    require(
      campaign.paymentCount < campaign.milestoneCount,
      "Payment already completed"
    );

    // If this is the first milestone, start the stream
    if (!campaign.isStreaming) {
      usdtx.createFlow(campaign.creative, campaign.baseFlowRate);
      campaign.isStreaming = true;
    } else {
      // Increment the flow rate for the next milestone
      int96 newFlowRate = campaign.baseFlowRate *
        int96(campaign.paymentCount + 1);
      usdtx.updateFlow(campaign.creative, newFlowRate);
      campaign.currentFlowRate = newFlowRate;
    }

    // Increment the payment count and check for completion
    campaign.paymentCount++;

    if (campaign.paymentCount == campaign.milestoneCount) {
      // Complete the campaign and stop the stream
      usdtx.deleteFlow(address(this), campaign.creative);
      creatives[campaign.creative].xp += 20;

      campaign.isCompleted = true;
    }
  }

  //for showing creative campaign payments
  function getCreativeTotalPayment(
    string calldata campaignId
  ) external view returns (uint256) {
    Campaign memory campaign = campaigns[campaignId];
    return campaign.amount - ((systemFee * campaign.amount) / 100);
  }

  //get creative ratings
  function getCreativeRating(
    address _creative
  ) external view returns (uint256) {
    return creatives[_creative].xp;
  }

  function getSystemFee() external view returns (uint256) {
    return systemFee;
  }

  function getCampaign(
    string calldata campaignId
  ) external view returns (Campaign memory) {
    return campaigns[campaignId];
  }

  //to be deleted. Used for recovering testing funds
  function withdraw(address _recipient) public payable {
    payable(_recipient).transfer(address(this).balance);
  }
}
