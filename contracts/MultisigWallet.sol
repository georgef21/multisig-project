// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// MultisigWallet contract that allows multiple signers to approve and execute transactions
contract MultisigWallet {
    
    // Struct representing a transaction in the multisig wallet
    struct Transaction {
        address target; // Target address where the transaction will be sent
        uint256 value; // Amount of Ether to send in the transaction
        bytes data; // Data to call the target address with
        uint8 approvals; // Number of approvals the transaction has received
        bool executed; // Whether the transaction has been executed or not
    }

    // Struct representing an update to the list of signers or required signatures
    struct SignerUpdate {
        address[] newSigners; // New list of signers
        uint256 newRequiredSignatures; // New number of required approvals
        uint8 approvals; // Number of approvals the signer update has received
        bool executed; // Whether the signer update has been executed
    }

    // List of signers and the required number of approvals for a transaction
    address[] public signers;
    uint256 public requiredSignatures;
    
    // Mappings to store whether an address is a signer and whether they have approved a transaction
    mapping(address => bool) public isSigner;
    mapping(uint256 => mapping(address => bool)) public approved; // Tracks approvals for each transaction
    mapping(uint256 => mapping(address => bool)) public signerUpdateApproved; // Tracks approvals for signer updates
    
    // Arrays storing all transactions and signer updates
    Transaction[] public transactions;
    SignerUpdate[] public signerUpdates;

    // Events to emit for various actions
    event TransactionCreated(uint256 indexed txId, address indexed target, uint256 value);
    event TransactionApproved(uint256 indexed txId, address indexed signer);
    event TransactionExecuted(uint256 indexed txId);
    event SignerUpdateProposed(uint256 indexed updateId, address[] newSigners, uint256 newRequiredSignatures);
    event SignerUpdateApproved(uint256 indexed updateId, address indexed signer);
    event SignerUpdateExecuted(uint256 indexed updateId);

    // Modifier to ensure only authorized signers can perform certain actions
    modifier onlySigner() {
        require(isSigner[msg.sender], "Not an authorized signer");
        _;
    }

    // Constructor to initialize the wallet with signers and the required number of approvals
    constructor(address[] memory _signers, uint256 _requiredSignatures) {
        require(_signers.length > 0, "Signers required");
        require(_requiredSignatures > 0 && _requiredSignatures <= _signers.length, "Invalid signatures count");

        for (uint256 i = 0; i < _signers.length; i++) {
            isSigner[_signers[i]] = true; // Mark each address as a valid signer
        }

        signers = _signers;
        requiredSignatures = _requiredSignatures;
    }

    // Function to submit a new transaction to be approved by signers
    function submitTransaction(address _target, uint256 _value, bytes memory _data) public onlySigner returns (uint256) {
        transactions.push(Transaction({
            target: _target,
            value: _value,
            data: _data,
            approvals: 0,
            executed: false
        }));

        uint256 txId = transactions.length - 1;
        emit TransactionCreated(txId, _target, _value); // Emit an event for the new transaction
        return txId;
    }

    // Function for a signer to approve a transaction
    function approveTransaction(uint256 _txId) public onlySigner {
        require(_txId < transactions.length, "Invalid transaction ID");
        require(!transactions[_txId].executed, "Transaction already executed");
        require(!approved[_txId][msg.sender], "Already approved");

        approved[_txId][msg.sender] = true; // Mark the signer as having approved the transaction
        transactions[_txId].approvals++; // Increment the number of approvals

        emit TransactionApproved(_txId, msg.sender); // Emit event for approval
    }

    // Function to execute a transaction if enough approvals are received
    function executeTransaction(uint256 _txId) public onlySigner {
        require(_txId < transactions.length, "Invalid transaction ID");
        require(!transactions[_txId].executed, "Transaction already executed");
        require(transactions[_txId].approvals >= requiredSignatures, "Not enough approvals");

        Transaction storage txn = transactions[_txId];
        txn.executed = true; // Mark the transaction as executed

        // Execute the transaction (send Ether to the target address and call the provided data)
        (bool success, ) = txn.target.call{value: txn.value}(txn.data);
        require(success, "Transaction failed");

        emit TransactionExecuted(_txId); // Emit event for successful execution
    }

    // Function to propose an update to the list of signers or the required number of approvals
    function proposeSignerUpdate(address[] memory _newSigners, uint256 _newRequiredSignatures) public onlySigner returns (uint256) {
        require(_newSigners.length > 0, "Signers required");
        require(_newRequiredSignatures > 0 && _newRequiredSignatures <= _newSigners.length, "Invalid signatures count");

        signerUpdates.push(SignerUpdate({
            newSigners: _newSigners,
            newRequiredSignatures: _newRequiredSignatures,
            approvals: 0,
            executed: false
        }));

        uint256 updateId = signerUpdates.length - 1;
        emit SignerUpdateProposed(updateId, _newSigners, _newRequiredSignatures); // Emit event for proposed signer update
        return updateId;
    }

    // Function for a signer to approve a signer update
    function approveSignerUpdate(uint256 _updateId) public onlySigner {
        require(_updateId < signerUpdates.length, "Invalid update ID");
        require(!signerUpdates[_updateId].executed, "Update already executed");
        require(!signerUpdateApproved[_updateId][msg.sender], "Already approved");

        signerUpdateApproved[_updateId][msg.sender] = true; // Mark the signer as having approved the update
        signerUpdates[_updateId].approvals++; // Increment the number of approvals

        emit SignerUpdateApproved(_updateId, msg.sender); // Emit event for approval of the signer update
    }

    // Function to execute a signer update once enough approvals are received
    function executeSignerUpdate(uint256 _updateId) public onlySigner {
        require(_updateId < signerUpdates.length, "Invalid update ID");
        require(!signerUpdates[_updateId].executed, "Update already executed");
        require(signerUpdates[_updateId].approvals >= requiredSignatures, "Not enough approvals");

        SignerUpdate storage update = signerUpdates[_updateId];
        update.executed = true; // Mark the signer update as executed

        // Update the list of signers and the required number of signatures
        for (uint256 i = 0; i < signers.length; i++) {
            isSigner[signers[i]] = false; // Remove the old signers
        }
        signers = update.newSigners; // Set the new list of signers
        requiredSignatures = update.newRequiredSignatures; // Set the new required signatures
        for (uint256 i = 0; i < signers.length; i++) {
            isSigner[signers[i]] = true; // Add the new signers to the mapping
        }

        emit SignerUpdateExecuted(_updateId); // Emit event for successful signer update execution
    }

    // Fallback function to accept Ether sent directly to the contract
    receive() external payable {}
}
