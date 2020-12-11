pragma solidity =0.5.16;

import './interfaces/IRenaswapV1Factory.sol';
import './interfaces/IRenaswapV1Pair.sol';
import './RenaswapV1Pair.sol';

contract RenaswapV1Factory is IRenaswapV1Factory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(msg.sender == feeToSetter, 'RenaswapV1: FORBIDDEN');
        require(tokenA != tokenB, 'RenaswapV1: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'RenaswapV1: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'RenaswapV1: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(RenaswapV1Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IRenaswapV1Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'RenaswapV1: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'RenaswapV1: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}