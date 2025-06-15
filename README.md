# Examen Final Modulo 2
# KipuBank - Bóveda de ETH Segura


Contrato inteligente no custodial para depósitos y retiros de ETH con límites transaccionales y seguimiento de actividades.

## 📋 Descripción

KipuBank es un contrato seguro que permite:
- ✅ Depósitos de ETH con un límite máximo de capacidad (`BANK_CAP`)
- ✅ Retiros con umbral transaccional configurable (`WITHDRAWAL_THRESHOLD`)
- 📊 Seguimiento de saldos individuales y totales
- 🔍 Registro completo de transacciones (eventos)

**Características de seguridad**:
- Patrón Checks-Effects-Interactions
- Errores personalizados para revertir gas-eficiente
- Transferencias seguras de ETH

## 🚀 Despliegue

### Requisitos
- Compilador Solidity 0.8.19+
- Entorno de desarrollo (Remix)
- Fondos ETH para el despliegue (en https://faucet.ethkipu.org/ o https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

### Pasos para desplegar en Remix
1. Compilar:
   - Ingresar a [Remix IDE](https://remix.ethereum.org)
   - Crea un nuevo archivo `KipuBank.sol`
   - Pega el código del contrato
   - Compila (Ctrl+S)

2. Configurar parámetros:
   ```javascript
   // Parámetros del constructor (en wei):
   withdrawalThreshold_ = 100000000000000000 // 0.1 ETH
   bankCap_ = 1000000000000000000           // 1 ETH

3. Interactúa con las funciones directamente en los contratos desplegados en Remix