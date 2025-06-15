// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title KipuBank - Bóveda segura para ETH
 * @notice Contrato no custodial para depósitos/retiros de ETH con límites transaccionales
 * @dev Implementa el patrón Checks-Effects-Interactions con errores optimizados para el uso mínimo de gas
 */
contract KipuBank {
    // --- Errores Personalizados ---
    /// @notice Corre cuando el depósito excede el límite total del banco
    error DepositExceedsBankCap();
    
    /// @notice Corre cuando el monto a retirar excede el límite por transacción
    error WithdrawalExceedsThreshold();
    
    /// @notice Corre cuando el usuario intenta retirar más de su saldo disponible
    error InsufficientBalance();
    
    /// @notice Corre cuando falla una transferencia de ETH
    error TransferFailed();

    // --- Eventos ---
    /// @notice Emitido cuando un usuario deposita ETH
    /// @param user Dirección que realiza el depósito
    /// @param amount Monto depositado en wei
    event Deposited(address indexed user, uint256 amount);
    
    /// @notice Emitido cuando un usuario retira ETH
    /// @param user Dirección que realiza el retiro
    /// @param amount Monto retirado en wei
    event Withdrawn(address indexed user, uint256 amount);

    // --- Configuración Inmutable ---
    /// @notice Máximo ETH (en wei) que se puede retirar en una sola transacción
    uint256 public immutable WITHDRAWAL_THRESHOLD;
    
    /// @notice Capacidad máxima total de ETH (en wei) que puede almacenar el contrato
    uint256 public immutable BANK_CAP;

    // --- Variables de Estado ---
    /// @notice Total de ETH actualmente depositado en la cuenta (en wei)
    uint256 public totalDeposits;
    
    /// @notice Número total de transacciones de depósito procesadas
    uint256 public totalDepositCount;
    
    /// @notice Número total de transacciones de retiro procesadas
    uint256 public totalWithdrawalCount;
    
    /// @notice Mapeo de direcciones de usuarios a sus saldos de ETH (en wei)
    mapping(address => uint256) private _balances;

    // --- Modificador ---
    /// @notice Restringe los montos de retiro al umbral predefinido
    /// @param amount Monto que se intenta retirar
    /// @dev Se revierte con WithdrawalExceedsThreshold si el monto excede el límite
    modifier withinWithdrawalLimit(uint256 amount) {
        if (amount > WITHDRAWAL_THRESHOLD) {
            revert WithdrawalExceedsThreshold();
        }
        _;
    }

    // --- Constructor ---
    /// @notice Inicializa la bóveda con parámetros de configuración
    /// @param withdrawalThreshold_ Máximo ETH (en wei) retirable por transacción
    /// @param bankCap_ Capacidad total de ETH (en wei) para la cuenta
    /// @dev Requiere que bankCap_ sea mayor que cero
    constructor(uint256 withdrawalThreshold_, uint256 bankCap_) {
        require(bankCap_ > 0, "El limite del banco debe ser mayor que 0");
        WITHDRAWAL_THRESHOLD = withdrawalThreshold_;
        BANK_CAP = bankCap_;
    }

    // --- Funciones Principales ---
    /// @notice Acepta depósitos de ETH en el saldo del usuario
    /// @dev Se revierte si el depósito excede BANK_CAP
    /// @dev Emite el evento Deposited al tener éxito
    function deposit() external payable {
        if (msg.value + totalDeposits > BANK_CAP) {
            revert DepositExceedsBankCap();
        }

        _balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        totalDepositCount++;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Retira ETH del saldo del usuario
    /// @param amount Monto de ETH a retirar (en wei)
    /// @dev Se revierte si:
    /// - El monto excede el umbral de retiro (usando un modificador)
    /// - El usuario no tiene saldo suficiente
    /// - Falla la transferencia de ETH
    /// @dev Emite el evento Withdrawn al tener éxito
    function withdraw(uint256 amount) external withinWithdrawalLimit(amount) {
        if (amount > _balances[msg.sender]) {
            revert InsufficientBalance();
        }

        _balances[msg.sender] -= amount;
        totalDeposits -= amount;
        totalWithdrawalCount++;

        _safeTransferETH(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    // --- Función Privada ---
    /// @notice Transferencia interna de ETH con verificaciones de seguridad
    /// @param to Dirección del destinatario
    /// @param amount Monto de ETH a transferir (en wei)
    /// @dev Se revierte con TransferFailed si la transferencia falla
    function _safeTransferETH(address to, uint256 amount) private {
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    // --- Funciones de Consulta ---
    /// @notice Obtiene el saldo en la cuenta de un usuario
    /// @param user Dirección a consultar
    /// @return Saldo de ETH del usuario en wei
    function getUserBalance(address user) external view returns (uint256) {
        return _balances[user];
    }

    /// @notice Obtiene el balance actual de ETH del contrato
    /// @return Balance de ETH del contrato en wei
    /// @dev Debería coincidir con totalDeposits a menos que se haya enviado ETH forzosamente
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Obtiene el conteo total de transacciones
    /// @return deposits Número total de depósitos procesados
    /// @return withdrawals Número total de retiros procesados
    function getTransactionCounts() external view returns (uint256 deposits, uint256 withdrawals) {
        return (totalDepositCount, totalWithdrawalCount);
    }
}
