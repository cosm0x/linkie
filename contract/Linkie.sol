// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//TODOS: add events
contract Linkie {
  uint256 systemFee;
  address owner;

  struct Campaign {
    string id;
    address creator;
    address creative;
    uint256 milestoneCount;
    uint256 paymentCount;
    uint256 amount;
    bool isCompleted;
  }

  struct Creative {
    uint256 xp;
  }

  mapping(string => Campaign) campaigns;
  mapping(address => Creative) public creatives;

  constructor(uint256 _systemFee) {
    systemFee = _systemFee;
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner allowed");
    _;
  }

  //this activates the campaign
  function activateCampaign(
    string calldata campaignId,
    uint256 milestoneCount
  ) external payable {
    require(msg.value > 1000000000000000, "Least amount is 0.001 tBNB");
    //saves the campaign on-chain
    campaigns[campaignId] = Campaign({
      id: campaignId,
      creator: msg.sender,
      creative: address(0),
      amount: msg.value,
      milestoneCount: milestoneCount,
      paymentCount: 0,
      isCompleted: false
    });
  }

  //matches a creative to a campaign
  function matchCampaign(
    string calldata campaignId,
    address creative
  ) external {
    require(campaigns[campaignId].creator == msg.sender, "Not permitted");
    campaigns[campaignId].creative = creative;
  }

  //pays each milestone on creator/business approval
  function payMilestone(string calldata campaignId) external {
    Campaign memory campaign = campaigns[campaignId];

    require(campaigns[campaignId].creator == msg.sender, "Not permitted");

    require(
      campaign.paymentCount < campaign.milestoneCount,
      "Payment already completed"
    );

    uint256 creativeTotalPayment = campaign.amount -
      ((systemFee * campaign.amount) / 100);

    //transfers payment to creative wallet
    (bool success, ) = payable(campaign.creative).call{
      value: creativeTotalPayment / campaign.milestoneCount
    }("");
    require(success, "Transfer failed.");

    //checks if it is the last payment
    if (campaign.paymentCount + 1 == campaign.milestoneCount) {
      //handle rating logic
      creatives[campaign.creative].xp += 20;

      //mark campaign as completed
      campaigns[campaignId].isCompleted = true;
    }

    //update campaign record
    campaigns[campaignId].paymentCount++;
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
