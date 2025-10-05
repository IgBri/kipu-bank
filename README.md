# 📘 README

## 🧾 Descripción de contrato
El presente contrato tiene la utilidad de ingresar y extraer fondos por cada usuario que deposite en el mismo. Siempre respetando los topes establecidos durante la compilación del contrato, los cuales están designados en un monto máximo por extracción de **1 ether**, y un tope máximo de almacenamiento de **5 ether**.

---

## 🚀 Instrucciones de despliegue
El contrato fue desplegado en la **testnet de Sepolia** y verificado en la misma, bajo el address 0xa6398897ee82eb5c0954780d7a32b1ef5c171b3f.

---

## ⚙️ Interacción con el contrato
El contrato ofrece distintas funciones mediante las cuales podemos interactuar con el mismo. Entre ellas estan la funcion publica `viewVault()` para acceder al monto ingresado por cada usuario (`msg.sender`); la funcion external payable `enterAmount()` para ingresar dinero, en **wei**. En esta funcion se puede generar `revert()` en el caso de alcanzar el limite establecido de **5 ether**; la funcion external `withdraw()` con la cual podemos extraer un monto designado siempre y cuando haya un capital disponible para retirar, y que el monto designado de retiro no supere el limite maximo de retiro establecido en **1 ether**; en esta ultima funcion tambien se ejecuta la funcion privada `_trasnferEther()` con la cual se ejecuta el metodo `.call()` que envia dinero al solicitante, desigando con el parametro `_to`; y por ultimo las funciones `viewBalance()` y `viewPersonalBalance()` para ver los balances del contrato y de cada usuario segun corresponda.
