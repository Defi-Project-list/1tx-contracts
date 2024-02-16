// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./auth/Auth.sol";

contract Registry {
    error EntryAlreadyExistsError(bytes4);
    error EntryNonExistentError(bytes4);
    error EntryNotInChangeError(bytes4);
    error ChangeNotReadyError(uint256, uint256);
    error EmptyPrevAddrError(bytes4);
    error AlreadyInContractChangeError(bytes4);
    error AlreadyInWaitPeriodChangeError(bytes4);

    event AddNewContract(address, bytes4, address, uint256);
    event RevertToPreviousAddress(address, bytes4, address, address);
    event StartContractChange(address, bytes4, address, address);
    event ApproveContractChange(address, bytes4, address, address);
    event CancelContractChange(address, bytes4, address, address);
    event StartWaitPeriodChange(address, bytes4, uint256);
    event ApproveWaitPeriodChange(address, bytes4, uint256, uint256);
    event CancelWaitPeriodChange(address, bytes4, uint256, uint256);

    event AddNewThirdPartyContract(address, bytes4, address);
    event EditThirdPartyContract(address, bytes4, address, address);

    Auth private auth;

    struct Entry {
        address contractAddr;
        uint256 waitPeriod;
        uint256 changeStartTime;
        bool inContractChange;
        bool inWaitPeriodChange;
        bool exists;
    }

    struct ThirdPartyEntry {
        address contractAddr;
        bool exists;
    }

    mapping(bytes4 => Entry) public entries;
    mapping(bytes4 => ThirdPartyEntry) public thirdPartyEntries;
    mapping(address => bool) public verifiedContracts;

    mapping(bytes4 => address) public previousAddresses;
    mapping(bytes4 => address) public pendingAddresses;
    mapping(bytes4 => uint256) public pendingWaitTimes;

    constructor(address _uAuthContract) {
        auth = Auth(_uAuthContract);
    }

    function owner() public view returns (address) {
        return auth.owner();
    }

    modifier onlyOwner() {
        require(msg.sender == auth.owner(), "UAuth: caller is not the owner");
        _;
    }

    function getAddr(bytes4 _id) public view returns (address) {
        if (entries[_id].exists) {
            return entries[_id].contractAddr;
        } else if (thirdPartyEntries[_id].exists) {
            return thirdPartyEntries[_id].contractAddr;
        } else {
            return address(0);
        }
    }

    function isVerifiedContract(bytes4 _id) public view returns (bool) {
        return entries[_id].exists;
    }

    function isVerifiedContract(address _addr) public view returns (bool) {
        return verifiedContracts[_addr];
    }

    function isRegistered(bytes4 _id) public view returns (bool) {
        if (entries[_id].exists) {
            return entries[_id].exists;
        } else if (thirdPartyEntries[_id].exists) {
            return thirdPartyEntries[_id].exists;
        } else {
            return false;
        }
    }

    /*
    Owner only Functions
        1. addNewContract
        2. revertToPreviousAddress
        3. startContractChange
        4. approveContractChange
        5. cancelContractChange
        6. startWaitPeriodChange
        7. approveWaitPeriodChange
        8. cancelWaitPeriodChange
    */

    /// @notice Adds a new contract to the registry
    /// @param _id Id of contract
    /// @param _contractAddr Address of the contract
    /// @param _waitPeriod Amount of time to wait before a contract address can be changed
    function addNewContract(bytes4 _id, address _contractAddr, uint256 _waitPeriod) public onlyOwner returns (bytes4) {
        if (entries[_id].exists) {
            revert EntryAlreadyExistsError(_id);
        }

        entries[_id] = Entry({
            contractAddr: _contractAddr,
            waitPeriod: _waitPeriod,
            changeStartTime: 0,
            inContractChange: false,
            inWaitPeriodChange: false,
            exists: true
        });
        verifiedContracts[_contractAddr] = true;
        emit AddNewContract(msg.sender, _id, _contractAddr, _waitPeriod);

        return _id;
    }

    function revertToPreviousAddress(bytes4 _id) public onlyOwner {
        if (!(entries[_id].exists)) {
            revert EntryNonExistentError(_id);
        }
        if (previousAddresses[_id] == address(0)) {
            revert EmptyPrevAddrError(_id);
        }

        address currentAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = previousAddresses[_id];
        verifiedContracts[currentAddr] = false;
        verifiedContracts[previousAddresses[_id]] = true;

        emit RevertToPreviousAddress(msg.sender, _id, currentAddr, previousAddresses[_id]);
    }

    function startContractChange(bytes4 _id, address _newContractAddr) public onlyOwner {
        if (!entries[_id].exists) {
            revert EntryNonExistentError(_id);
        }
        if (entries[_id].inWaitPeriodChange) {
            revert AlreadyInWaitPeriodChangeError(_id);
        }

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inContractChange = true;

        pendingAddresses[_id] = _newContractAddr;

        emit StartContractChange(msg.sender, _id, entries[_id].contractAddr, _newContractAddr);
    }

    function approveContractChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists) {
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inContractChange) {
            revert EntryNotInChangeError(_id);
        }
        if (block.timestamp < (entries[_id].changeStartTime + entries[_id].waitPeriod)) {
            // solhint-disable-line
            revert ChangeNotReadyError(block.timestamp, (entries[_id].changeStartTime + entries[_id].waitPeriod));
        }

        address oldContractAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = pendingAddresses[_id];
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;
        verifiedContracts[oldContractAddr] = false;
        verifiedContracts[pendingAddresses[_id]] = true;

        pendingAddresses[_id] = address(0);
        previousAddresses[_id] = oldContractAddr;

        emit ApproveContractChange(msg.sender, _id, oldContractAddr, entries[_id].contractAddr);
    }

    function cancelContractChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists) {
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inContractChange) {
            revert EntryNotInChangeError(_id);
        }

        address oldContractAddr = pendingAddresses[_id];

        pendingAddresses[_id] = address(0);
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        emit CancelContractChange(msg.sender, _id, oldContractAddr, entries[_id].contractAddr);
    }

    function startWaitPeriodChange(bytes4 _id, uint256 _newWaitPeriod) public onlyOwner {
        if (!entries[_id].exists) {
            revert EntryNonExistentError(_id);
        }
        if (entries[_id].inContractChange) {
            revert AlreadyInContractChangeError(_id);
        }

        pendingWaitTimes[_id] = _newWaitPeriod;

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inWaitPeriodChange = true;

        emit StartWaitPeriodChange(msg.sender, _id, _newWaitPeriod);
    }

    function approveWaitPeriodChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists) {
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inWaitPeriodChange) {
            revert EntryNotInChangeError(_id);
        }
        if (block.timestamp < (entries[_id].changeStartTime + entries[_id].waitPeriod)) {
            // solhint-disable-line
            revert ChangeNotReadyError(block.timestamp, (entries[_id].changeStartTime + entries[_id].waitPeriod));
        }

        uint256 oldWaitTime = entries[_id].waitPeriod;
        entries[_id].waitPeriod = pendingWaitTimes[_id];

        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        pendingWaitTimes[_id] = 0;

        emit ApproveWaitPeriodChange(msg.sender, _id, oldWaitTime, entries[_id].waitPeriod);
    }

    function cancelWaitPeriodChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists) {
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inWaitPeriodChange) {
            revert EntryNotInChangeError(_id);
        }

        uint256 oldWaitPeriod = pendingWaitTimes[_id];

        pendingWaitTimes[_id] = 0;
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        emit CancelWaitPeriodChange(msg.sender, _id, oldWaitPeriod, entries[_id].waitPeriod);
    }

    /*
    Third party functions
        1. addNewThirdPartyContract
        2. setThirdPartyContract
    */

    function addNewThirdPartyContract(address _contractAddr) public returns (bytes4) {
        bytes4 _id = bytes4(keccak256(abi.encodePacked(_contractAddr)));

        if (thirdPartyEntries[_id].exists) {
            revert EntryAlreadyExistsError(_id);
        }

        thirdPartyEntries[_id] = ThirdPartyEntry({ contractAddr: _contractAddr, exists: true });

        emit AddNewThirdPartyContract(msg.sender, _id, _contractAddr);

        return _id;
    }
}
