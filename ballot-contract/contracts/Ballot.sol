// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0;

contract Ballot{

    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }

    struct Proposal{
        uint voteCount;
    }

    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;

    enum Phase {Init, Regs, Vote, Done}
    Phase public state = Phase.Init;

    modifier validPhase(Phase reqPhase){
        require(state == reqPhase);
        _;
    }

    // modifier onlyChair(){
    //     require(msg.sender == chairperson);
    //     _;
    // }

    // 데이터 요소 및 투표 단계 상태 초기화
    constructor (uint numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 2;
        for (uint prop=0; prop < numProposals; prop++) {
            proposals.push(Proposal(0));
        }
        // state = Phase.Regs;
    }

    function changeState(Phase x) public {
        if (msg.sender != chairperson)  revert();
        if (x < state)  revert();
        // require (x > state);
        state = x;
    }
    
    function register(address voter) public validPhase(Phase.Regs) {
        // require (!voters[voter].voted);
        if (msg.sender != chairperson || voters[voter].voted)   revert();
        voters[voter].weight = 1;
        voters[voter].voted = false;
    }

    function vote(uint toProposal) public validPhase(Phase.Vote) {
        Voter memory sender = voters[msg.sender];
        // require (!sender.voted);
        // require (toProposal < proposals.length);
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }

    // 읽기용 함수, 체인에 Tx를 기록하지지 않음
    function reqWinner() public validPhase(Phase.Done) view returns (uint winningProposal) {
        uint winningVoteCount = 0;
        for (uint prop = 0; prop < proposals.length; prop++) {
            if (proposals[prop].voteCount > winningProposal) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
        }
        //assert(winningVoteCount >= 3);
    }

    // 해당 account가 의장(true)인지 일반투표자(false)인지 확인
    function who(address voter) public view returns (bool chairpersonOrNot) {
        if (voters[voter].weight == 2)   return true;
        else if (voters[voter].weight == 1)  return false; 
    }
}

// BallotV3
// Deploy: 0(Init), numProposals: 8, Deploy -chairperson accont
// chairperson: only one account

// changeState: 1 (Regs) -chairperson
// register: other accounts -chairperson

// changeState: 2 (Vote) -chairperson
// vote: choose from 0 to 7(= numProposals-1) -other accounts

// changeState: 3 (Done)
// reqWinner -chairperson

// 등록되지 않은 투표자(account)는 가중치(weight)가 0으로 처리되기 때문에 투표(vote)를 하더라도 결과(reqWinner)에 영향을 미치지 않음.