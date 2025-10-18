// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;

/// @title Kipu_Bank
/// @author Ignacio Brizuela
/// @notice This contract has the purpose of entering and withdrawing funds for each user.
contract Kipu_bank {
    /// @notice This internal variable represents the owner of the contract.
    address internal immutable s_owner;

    /// @notice This numeric immutable variable represents the fixed withdrawal limit per user.
    /// @dev The value of this variable is defined during deployment.
    uint256 internal immutable s_limitAmount; 

    /// @notice This numeric immutable variable represents the global deposit limit.
    /// @dev The value of this variable is defined during deployment.
    uint256 internal immutable s_bankCap; 

    /// @notice This internal numeric variable represents the total balance of the contract
    uint256 internal s_balanceContract = address(this).balance; 

    /// @notice This mapping type variable represents the balance of each user who enters funds.
    /// @dev In this mapping each address corresponds to a uint256.
    mapping (address owner => uint256 totalAMount) private s_balanceUser; 

    // @notice This mapppig represents a record of members enabled to transact with the contract.
    mapping (address member => bool enabledToOperate) private s_membership;

    /// @notice This numeric variable represents a record of each transaction made.
    uint256 internal s_registerTransaction = 0; 

    /// @notice This numeric variable represents a record of each extraccion made.
    uint256 internal s_registerExtraction = 0; 

    /// @notice It is thrown when an error is generated in the extraction.
    /// @param message contains a string that provides information about the error.
    /// @param addressReq represents the address that requested the extraction that generated the error.
    /// @param amount represents the requested withdrawal amount.
    error InvalidWithdraw(string message, address addressReq, uint256 amount);

    /// @notice It is raised when the entered amount is invalid.
    /// @param message contains a message about the error.
    /// @param amount contains the uint256 data that represents the amount that was to be entered.
    /// @param user contains the address of the account that wanted to enter that amount.
    error InvalidAmount(string message, uint256 amount, address user);
    
    /// @notice This error is thrown when the contract account limit has been reached.
    /// @param message contains a message about the error.
    /// @param balance ccontains the total contract balance if the transaction were to be carried out.
    error GlobalDepositLimit(string message, uint256 balance);

    /// @notice This error is thrown when an unauthorized account attempts to trade the contract.
    /// @param member represents the account that tried to operate with the contract.
    error UnauthorizedMember(address member);

    /// @notice This error is thrown when an account other than the contract owner attempts to grant permissions to other accounts.
    /// @param addressInteraction represents the unauthorized address that attempted to grant permissions.
    error UnauthorizedMemberToEnable(address addressInteraction);

    /// @notice This event is emitted when a transfer is successful.
    /// @param userClient represents the user who performs the transaction.
    /// @param amount represents the transaction amount.
    event Kipu_bank_SuccessIncome(address indexed userClient, uint256 amount);
    
    /// @notice This event is emitted when an extraction has been successful.
    /// @param userAddr represents the address that executed the extraction.
    /// @param amount represents the withdrawal amount.
    event Kipu_bank_SuccessWithdraw(address userAddr, uint256 amount);

    /// @notice This modifier validates that the address that wants to execute a function is authorized to transact with the contract.
    /// @dev This modifier is applied in the enterAmount and withdraw functions
    /// @param _member parameter represents the account to validate.
    modifier verifyMember (address _member) {
        if (!s_membership[_member]) revert UnauthorizedMember(_member);
        _;
    }

    /// @notice When the contract is executed, immutable values ​​are set to determine the contract owner (s_owner), the withdrawal limit per transaction allowed (s_limitAmount) and the contract funds storage limit (s_bankCap).
    /// @dev The contract owner is the account that deploys the contract. The values ​​for s_limitAmount and s_bankCap were entered in ether. That is, the values ​​are integers, such as 2 and 10, but are then converted to wei using "* ether."
    /// @param _amountTx parameter represents the amount assigned as the withdrawal limit per transaction.
    /// @param _bankCap parameter represents the contract's fund storage limit.
    constructor (uint256 _amountTx, uint256 _bankCap) {
        s_owner = msg.sender;
        s_limitAmount = _amountTx * 1 ether;
        s_bankCap = _bankCap * 1 ether;
    }

    /// @notice This public function provides the total balance of the requesting user.
    /// @return the numerical value of the balance
    function viewBalanceUser () public view returns(uint256) {
        return s_balanceUser[msg.sender];
    }

    /// @notice This external function provides the total balance of the contract.
    /// @return the numerical value of the balance.
    function viewBalanceContract () external view returns(uint256){
        return s_balanceContract;
    }
    
    /// @notice This external payable function executes the entry of funds into the contract. If the process is successful, an event is issued with the message "Transaction success" along with the amount entered and the account executing the transaction.
    /// @dev This function reverts if the funds to be entered are equal to or less than zero, or if the total balance of the contract exceeds the limit set in the deploy
    /// @dev when funds are deposited, the numeric variables representing the contract balance and the user balance increase their value by the same amount as the funds deposited.   
    /// @dev when funds are deposited, the variable s_registerTransactions increases its value by 1.
    function enterAmount () external payable verifyMember(msg.sender) {
        if(msg.value <= 0){
            revert InvalidAmount("Invalid amount", msg.value, msg.sender);
        }
        uint256 totalBalance = s_balanceContract + msg.value;
        if(totalBalance > s_bankCap){
            revert GlobalDepositLimit("Limit account", totalBalance);
        }
        s_balanceUser[msg.sender] += msg.value;
        s_balanceContract += msg.value;
        s_registerTransaction ++;
        emit Kipu_bank_SuccessIncome(msg.sender, msg.value);
    }
    
    /// @notice This function executes the withdrawal of funds to the account of the address that executes the function, as long as this address has previously stored funds.
    /// @dev This function follows the IEC pattern to avoid reentrancy.
    /// @dev This function can be reversed if the contract balance is 0; if the selected withdrawal amount exceeds the withdrawal limit; and if the selected withdrawal amount exceeds the balance of the requesting address.
    /// @param _amount represents the amount to be withdrawn by the address executing the function. This amount cannot exceed the withdrawal limit.
    /// @return data result obtained from the _trasnferEther function.
    function withdraw (uint256 _amount) external verifyMember(msg.sender) returns(bytes memory data) {
        data = _transferEther(msg.sender, _amount);
        emit Kipu_bank_SuccessWithdraw(msg.sender, _amount);
        return data;
    }

    /// @notice This function executes the transfer process where the amount entered by the requesting address is deducted from the contract balance and the balance of the same account registered in the contract, the variable s_balanceUser
    /// @dev This function decreases the numeric value of the variables s_balanceContract and s_balanceUser by the same number as the amount entered in the _amount parameter.
    /// @dev This function follows the CEI pattern to prevent reentrancy.
    /// @dev If the .call() method is successful, the state variable s_registerExtraction, which represents the count of extractions performed, is increased by 1.
    /// @param _to represents the address to which the .call() method is executed to send the funds.
    /// @param _amount represents the amount to be transferred.
    /// @return data obtained from the execution of the .call() method.
    function _transferEther (address _to, uint256 _amount) private returns(bytes memory) {
        // check
        if(s_balanceContract == 0) revert InvalidWithdraw("Balance contract in 0", _to, s_balanceContract);
        if(_amount > s_balanceContract) revert InvalidWithdraw("Insufficient balance", _to, _amount);
        if(_amount > s_limitAmount) revert InvalidWithdraw("Extraction limit", _to, _amount);
        if(_amount > s_balanceUser[_to]) revert InvalidWithdraw("Insufficient funds", _to, _amount);
        // effects
        s_balanceContract -= _amount;
        s_balanceUser[_to] -= _amount;
        // interactions
        (bool success, bytes memory data) = _to.call{value: _amount}("");
        if(!success) revert InvalidWithdraw("Transaction error", _to, _amount);
        s_registerExtraction ++;
        return data;
    }

    /// @notice This external function, executable only by the contract owner, authorizes another address to transact with the contract.
    /// @param _memberReq represents the account that is being requested to be authorized.
    function setMembers (address _memberReq) external {
        if(msg.sender != s_owner) revert UnauthorizedMemberToEnable(msg.sender);
        s_membership[_memberReq] = true;
    }

    /// @notice This external function provides the record of transactions carried out.
    /// @return a uint256 data type representing a count
    function returnTransactions () external view returns (uint256) {
        return s_registerTransaction;
    }

    /// @notice This external function provides the record of extractions made.
    /// @return a uint256 data type representing a count.
    function returnExtractions () external view returns (uint256) {
        return s_registerExtraction;
    }
}
