// 2020 (c) TON Venture Studio Ltd

pragma solidity >=0.6.0;
pragma AbiHeader expire;
pragma AbiHeader time;

interface IParticipant {
    /// @dev Send a notification message to participant with info about its stake and reward in round.
    /// @param roundId Id of completed round.
    /// @param reward Participant reward for round in nanotons
    /// @param ordinaryStake Ordinary Stake in completed round
    /// @param vestingStake Vesting stake in completed round
    /// @param lockStake Lock stake in completed round
    /// @param reinvest Are (ordinaryStake + reward) automatically reinvested (prolonged)?
    /// @param reason Reason why round is completed (See enum CompletionReason)
    function onRoundComplete(
        uint64 roundId,
        uint64 reward,
        uint64 ordinaryStake,
        uint64 vestingStake,
        uint64 lockStake,
        bool reinvest,
        uint8 reason) external;

    /// @dev Send a message with status code and certain value to participant as a result of DePool operation.
    /// @param errcode Error code of operation.
    /// @param comment Additional value for certain error code.
    function receiveAnswer(uint32 errcode, uint64 comment) external;

    function onTransfer(address source, uint128 amount) external;
}


contract Participant is IParticipant {
    function onRoundComplete(
        uint64 roundId,
        uint64 reward,
        uint64 ordinaryStake,
        uint64 vestingStake,
        uint64 lockStake,
        bool reinvest,
        uint8 reason) external override
    {

    }

    function receiveAnswer(uint32 errcode, uint64 comment) external override {

    }

    function onTransfer(address source, uint128 amount) external override {

    }
}