// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;

/// @title Kipu Bank
/// @author Ignacio Brizuela
/// @notice Este contrato tiene la utilidad de ingresar y extraer fondos para cada usuario

contract KipuBank {
    uint256 internal immutable s_limitAmount; // umbral fijo por transaccion
    uint256 internal immutable s_bankCap; //limite global de depositos
    uint256 internal s_balance = address(this).balance; // balance del contrato
    mapping (address owner => uint256 totalAMount) private s_vault; // ingresos por usuario

    error InvalidWithdraw(string);
    error GlobalDepositLimit(string);

    event SuccessIncome(string, uint256, address);
    event SuccessWithdraw(string);
    event ErrorIncome(string, address);
    event ErrorWithdraw(string, uint256);
    event ErrorTransfer(string, address);
    event InfoBalance(string, uint256);

    constructor (uint256 _amountTx, uint256 _bankCap) {
        s_limitAmount = _amountTx * 1 ether;
        s_bankCap = _bankCap * 1 ether;
    }
    function viewVault () public view returns(uint256) {
        return s_vault[msg.sender];
    }
    
    function enterAmount () external payable {
        uint256 totalBalance = s_balance + msg.value;
        if(totalBalance > s_bankCap){
            emit ErrorIncome("Esta transaccion sobrepasa el limite de deposito permitido", msg.sender);
            revert GlobalDepositLimit("Limite de la cuenta alcanzado");
        }
        s_vault[msg.sender] += msg.value;
        s_balance += msg.value;
        emit SuccessIncome("Ingreso aprobado", msg.value, msg.sender);
    }
    function withdraw (uint256 _amount) external returns(bytes memory data) {
        if(s_balance == 0){
            emit ErrorWithdraw("La extraccion es rechazada debido a balance en 0 del contraro", s_balance);
            revert InvalidWithdraw("El contrato no tiene saldo disponible para el retiro");
        }
        if(_amount > s_limitAmount) revert InvalidWithdraw("Limite maximo de retiro superado");
        emit SuccessWithdraw("Solicitud de extraccion aprobada");
        data = _transferEther(msg.sender, _amount); // interaction
        return data;
    }
    function _transferEther (address _to, uint256 _amount) private returns(bytes memory) {
        if(s_vault[_to] <= 0){
            emit ErrorTransfer("El usuario no posee registros de ingresos", _to);
            revert InvalidWithdraw("La extraccion solicitada es invalida debido a falta de fondos del solicitante");
        }
        if(_amount > s_vault[_to]){
            emit ErrorTransfer("Usuario sin fondos suficientes", _to);
            revert InvalidWithdraw("El usuario solicita extraer mas dinero del que aporto");
        } 
        (bool success, bytes memory data) = _to.call{value: _amount}("");
        if(!success){
            emit ErrorTransfer("Error en la transferencia de fondos", _to);
            revert InvalidWithdraw("Error en la funcion de extraccion: _transferEther()");
        } 
        s_vault[_to] -= _amount;
        return data;
    }
    function viewBalance () external view returns(uint256) {
        return s_balance;
    }
    function viewPersonalBalance () external view returns(uint256) {
        return s_vault[msg.sender];
    }
}
