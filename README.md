# 🧱 Kipu Bank - Smart Contract (Módulo 2)

El presente **smart contract** sigue los lineamientos solicitados para la entrega final del módulo 2, donde el contrato funcionará como **bóveda de activos digitales (ethers)**, los cuales pueden ser depositados por cuentas autorizadas a hacerlo.  
Esta autorización es brindada por el **propietario del contrato**, representado por la variable `s_owner`.  
La asignación del propietario a dicha variable se da durante el despliegue del contrato, siendo la cuenta (`address`) que realiza dicho despliegue la asignada como propietaria.

---

## ⚙️ Funcionalidades principales

### 🔸 Depósito de fondos (`enterAmount`)
El depósito de fondos se realiza mediante la función externa `enterAmount`, la cual posee un método de validación integrado mediante el **modificador** `verifyMember`.  
Este modificador recibe por parámetros la dirección que ejecuta dicha función y valida si la misma está autorizada a interactuar con el contrato.  
Asimismo, esta función es del tipo **payable**.

Durante su ejecución puede generarse un `revert()` por las siguientes causas:

- Si el monto a ingresar es **0**, se ejecuta un revert junto al error `InvalidAmount`, cuyos parámetros son un `shortString` informativo, el monto ingresado y la dirección que ejecuta la función.  
- Si la cantidad total de fondos almacenada (incluyendo la presente transacción) **supera el límite** establecido por la variable `s_bankCap`.  
  En este caso, el error ejecutado es `GlobalDepositLimit`.

Si el depósito se ejecuta correctamente, se emite el evento `Kipu_bank_SuccessIncome`, que contiene como parámetros la dirección que realiza el depósito y el monto ingresado.

---

### 🔸 Extracción de fondos (`withdraw`)
La extracción de fondos se realiza mediante la función externa `withdraw`, la cual también posee el modificador `verifyMember`.  
Al ejecutarse correctamente, la extracción emite el evento `Kipu_bank_SuccessWithdraw`, con los parámetros que representan la dirección que realiza la operación y el monto extraído.

Además, esta función ejecuta una función interna `_transferEther`, la cual sigue el **patrón Check-Effects-Interactions** para evitar ataques de **reentrancia**.  
En caso de error, se ejecuta `InvalidWithdraw`, que incluye como parámetros un `shortString` informativo, la dirección que ejecuta la extracción y un monto relacionado al error.

---

### 🔸 Autorización de miembros (`setMember`)
La función externa `setMember` permite **habilitar direcciones** para operar con el contrato.  
Solo puede ser ejecutada por el **propietario del contrato**, es decir, el valor almacenado en `s_owner`.

---

### 🔸 Consultas de actividad
- `returnExtractions` y `returnTransactions` → Pueden ejecutarse por cualquier cuenta para verificar la cantidad de extracciones e ingresos de fondos realizados.  
- `viewBalanceUser` → Retorna el balance de la dirección que ejecuta la función.  
- `viewBalanceContract` → Retorna el balance total del contrato.

---

## 🌐 Dirección del contrato

El contrato verificado en la **testnet de Sepolia** se encuentra en la siguiente dirección:

[`0x3c47A7dd98BF8C7428c21Fd68E9b2AE1BD0AC870`](https://testnet.routescan.io/address/0x3c47A7dd98BF8C7428c21Fd68E9b2AE1BD0AC870/contract/11155111/code)
