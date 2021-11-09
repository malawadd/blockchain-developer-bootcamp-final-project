# Avoiding Common Attacks

## Using Specific Compiler Pragma 

Contracts should be deployed with the same compiler version and flags that they have been tested the most with. Locking the pragma helps ensure that contracts do not accidentally get deployed using, for example, the latest compiler which may have higher risks of undiscovered bugs.

```
 pragma solidity 0.8.0;
```

## Integer Overflow and Underflow (SWC-101)

An overflow/underflow happens when an arithmetic operation reaches the maximum or minimum size of a type. For instance if a number is stored in the uint8 type, it means that the number is stored in a 8 bits unsigned number ranging from 0 to 2^8-1. Solidity 0.8 defaults to throwing an error for overflow / underflow.

```
 pragma solidity 0.8.0;
```
```

