// 2020 (c) TON Venture Studio Ltd

pragma solidity >=0.6.0;

import "DePoolLib.sol";
import "IProxy.sol";

contract AcceptBase {
    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), Errors.IS_NOT_OWNER);
        _;
    }

    constructor() public onlyOwner {
        tvm.accept();
    }
}

contract ValidatorBase {
    // Address of the validator wallet
    address m_validatorWallet;

    constructor(address validatorWallet) internal {
        m_validatorWallet = validatorWallet;
    }

    modifier onlyValidatorContract {
        require(msg.sender == m_validatorWallet, Errors.IS_NOT_VALIDATOR);
        _;
    }
}

contract ProxyBase {
    // Elector contract address.

    // Array of proxies addresses.
    address[] m_proxies;

    constructor(address proxy0, address proxy1) internal {
        m_proxies = [proxy0, proxy1];
    }

    function getProxy(uint64 roundId) internal view inline returns (address) {
        return m_proxies[roundId % 2];
    }

    function _recoverStake(address proxy, uint64 requestId, address elector) internal {
        IProxy(proxy).recover_stake{value: DePoolLib.ELECTOR_FEE + DePoolLib.PROXY_FEE}(requestId, elector);
    }

    function _sendElectionRequest(
        address proxy,
        uint64 requestId,
        uint64 validatorStake,
        DePoolLib.Request req,
        address elector
    )
        internal
    {
        // send stake + 1 ton  + 2 * 0.01 ton (proxy fee),
        // 1 ton will be used by Elector to return confirmation back to DePool contract.
        IProxy(proxy).process_new_stake{value: validatorStake + DePoolLib.ELECTOR_FEE + DePoolLib.PROXY_FEE}(
            requestId,
            req.validatorKey,
            req.stakeAt,
            req.maxFactor,
            req.adnlAddr,
            req.signature,
            elector
        );
    }

}

contract ConfigParamsBase {
    function getCurValidatorData() virtual internal returns (uint256 hash, uint32 utime_since, uint32 utime_until) {
        (TvmCell cell, bool ok) = tvm.rawConfigParam(34);
        require(ok, InternalErrors.ERROR508);
        hash = tvm.hash(cell);
        TvmSlice s = cell.toSlice();
        (, utime_since, utime_until) = s.decode(uint8, uint32, uint32);
    }

    function getPrevValidatorHash() virtual internal returns (uint) {
        (TvmCell cell, bool ok) = tvm.rawConfigParam(32);
        require(ok, InternalErrors.ERROR507);
        return tvm.hash(cell);
    }

    function roundTimeParams() virtual internal returns (
        uint32 validatorsElectedFor,
        uint32 electionsStartBefore,
        uint32 electionsEndBefore,
        uint32 stakeHeldFor
    ) {
        bool ok;
        (validatorsElectedFor, electionsStartBefore, electionsEndBefore, stakeHeldFor, ok) = tvm.configParam(15);
        require(ok, InternalErrors.ERROR509);
    }

    function getMaxStakeFactor() virtual pure internal returns (uint32) {
        (TvmCell cell, bool ok) = tvm.rawConfigParam(17);
        require(ok, InternalErrors.ERROR516);
        TvmSlice s = cell.toSlice();
        s.loadTons();
        s.loadTons();
        s.loadTons();
        return s.decode(uint32);
    }

    function getElector() virtual pure internal returns (address) {
        (TvmCell cell, bool ok) = tvm.rawConfigParam(1);
        require(ok, InternalErrors.ERROR517);
        TvmSlice s = cell.toSlice();
        uint256 value = s.decode(uint256);
        return address.makeAddrStd(-1, value);
    }
}

contract ParticipantBase {

    // Dictionary of participants for active rounds.
    mapping (address => DePoolLib.Participant) m_participants;

    function getOrCreateParticipant(address addr) internal view inline returns (DePoolLib.Participant) {
        return m_participants[addr];
    }

    function _setOrDeleteParticipant(address addr, DePoolLib.Participant participant) internal inline {
        if (participant.roundQty == 0)
            delete m_participants[addr];
        else
            m_participants[addr] = participant;
    }

}
