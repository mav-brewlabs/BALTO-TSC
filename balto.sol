// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;


interface IERC20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount)
	external
	returns (bool);

	function allowance(address owner, address spender)
	external
	view
	returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

interface IFactory {
	function createPair(address tokenA, address tokenB)
	external
	returns (address pair);

	function getPair(address tokenA, address tokenB)
	external
	view
	returns (address pair);
}

interface IRouter {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	)
	external
	payable
	returns (
		uint256 amountToken,
		uint256 amountETH,
		uint256 liquidity
	);

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}

interface IERC20Metadata is IERC20 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
}

interface DividendPayingTokenInterface {
	function dividendOf(address _owner) external view returns(uint256);
	function distributeDividends() external payable;
	function withdrawDividend() external;
	event DividendsDistributed(
		address indexed from,
		uint256 weiAmount
	);
	event DividendWithdrawn(
		address indexed to,
		uint256 weiAmount
	);
}

interface DividendPayingTokenOptionalInterface {
	function withdrawableDividendOf(address _owner) external view returns(uint256);
	function withdrawnDividendOf(address _owner) external view returns(uint256);
	function accumulativeDividendOf(address _owner) external view returns(uint256);
}

library SafeMath {

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

library SafeMathInt {
	int256 private constant MIN_INT256 = int256(1) << 255;
	int256 private constant MAX_INT256 = ~(int256(1) << 255);

	function mul(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a * b;

		// Detect overflow when multiplying MIN_INT256 with -1
		require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
		require((b == 0) || (c / b == a));
		return c;
	}
	function div(int256 a, int256 b) internal pure returns (int256) {
		// Prevent overflow when dividing MIN_INT256 by -1
		require(b != -1 || a != MIN_INT256);

		// Solidity already throws when dividing by 0.
		return a / b;
	}
	function sub(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a - b;
		require((b >= 0 && c <= a) || (b < 0 && c > a));
		return c;
	}
	function add(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a + b;
		require((b >= 0 && c >= a) || (b < 0 && c < a));
		return c;
	}
	function abs(int256 a) internal pure returns (int256) {
		require(a != MIN_INT256);
		return a < 0 ? -a : a;
	}
	function toUint256Safe(int256 a) internal pure returns (uint256) {
		require(a >= 0);
		return uint256(a);
	}
}

library SafeMathUint {
	function toInt256Safe(uint256 a) internal pure returns (int256) {
		int256 b = int256(a);
		require(b >= 0);
		return b;
	}
}

library IterableMapping {
	struct Map {
		address[] keys;
		mapping(address => uint) values;
		mapping(address => uint) indexOf;
		mapping(address => bool) inserted;
	}

	function get(Map storage map, address key) public view returns (uint) {
		return map.values[key];
	}

	function getIndexOfKey(Map storage map, address key) public view returns (int) {
		if(!map.inserted[key]) {
			return -1;
		}
		return int(map.indexOf[key]);
	}

	function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
		return map.keys[index];
	}

	function size(Map storage map) public view returns (uint) {
		return map.keys.length;
	}

	function set(Map storage map, address key, uint val) public {
		if (map.inserted[key]) {
			map.values[key] = val;
		} else {
			map.inserted[key] = true;
			map.values[key] = val;
			map.indexOf[key] = map.keys.length;
			map.keys.push(key);
		}
	}

	function remove(Map storage map, address key) public {
		if (!map.inserted[key]) {
			return;
		}

		delete map.inserted[key];
		delete map.values[key];

		uint index = map.indexOf[key];
		uint lastIndex = map.keys.length - 1;
		address lastKey = map.keys[lastIndex];

		map.indexOf[lastKey] = index;
		delete map.indexOf[key];

		map.keys[index] = lastKey;
		map.keys.pop();
	}
}

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor () {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view returns (address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

contract ERC20 is Context, IERC20, IERC20Metadata {
	using SafeMath for uint256;

	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;

	uint256 private _totalSupply;
	string private _name;
	string private _symbol;

	constructor(string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
	}

	function name() public view virtual override returns (string memory) {
		return _name;
	}

	function symbol() public view virtual override returns (string memory) {
		return _symbol;
	}

	function decimals() public view virtual override returns (uint8) {
		return 18;
	}

	function totalSupply() public view virtual override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view virtual override returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view virtual override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public virtual override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public virtual override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
	}

	function _transfer(
		address sender,
		address recipient,
		uint256 amount
	) internal virtual {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");
		_beforeTokenTransfer(sender, recipient, amount);
		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
	}

	function _mint(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: mint to the zero address");
		_beforeTokenTransfer(address(0), account, amount);
		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");
		_beforeTokenTransfer(account, address(0), amount);
		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(
		address owner,
		address spender,
		uint256 amount
	) internal virtual {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 amount
	) internal virtual {}
}

contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
	using SafeMath for uint256;
	using SafeMathUint for uint256;
	using SafeMathInt for int256;

	uint256 constant internal magnitude = 2**128;
	uint256 internal magnifiedDividendPerShare;
	uint256 public totalDividendsDistributed;

	mapping(address => int256) internal magnifiedDividendCorrections;
	mapping(address => uint256) internal withdrawnDividends;

	constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

	receive() external payable {
		distributeDividends();
	}

	function distributeDividends() public override onlyOwner payable {
		require(totalSupply() > 0);
		if (msg.value > 0) {
			magnifiedDividendPerShare = magnifiedDividendPerShare.add((msg.value).mul(magnitude) / totalSupply());
			emit DividendsDistributed(msg.sender, msg.value);
			totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
		}
	}
	function withdrawDividend() public virtual override onlyOwner {
		_withdrawDividendOfUser(payable(msg.sender));
	}
	function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
		uint256 _withdrawableDividend = withdrawableDividendOf(user);
		if (_withdrawableDividend > 0) {
			withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
			emit DividendWithdrawn(user, _withdrawableDividend);
            (bool success,) = user.call{value: _withdrawableDividend, gas: 3000}("");
            if(!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }
            return _withdrawableDividend;
		}
		return 0;
	}
	function dividendOf(address _owner) public view override returns(uint256) {
		return withdrawableDividendOf(_owner);
	}
	function withdrawableDividendOf(address _owner) public view override returns(uint256) {
		return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
	}
	function withdrawnDividendOf(address _owner) public view override returns(uint256) {
		return withdrawnDividends[_owner];
	}
	function accumulativeDividendOf(address _owner) public view override returns(uint256) {
		return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
		.add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
	}
	function _transfer(address from, address to, uint256 value) internal virtual override {
		require(false);
		int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
		magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
		magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
	}
	function _mint(address account, uint256 value) internal override {
		super._mint(account, value);
		magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
		.sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
	}
	function _burn(address account, uint256 value) internal override {
		super._burn(account, value);
		magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
		.add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
	}
	function _setBalance(address account, uint256 newBalance) internal {
		uint256 currentBalance = balanceOf(account);
		if(newBalance > currentBalance) {
			uint256 mintAmount = newBalance.sub(currentBalance);
			_mint(account, mintAmount);
		} else if(newBalance < currentBalance) {
			uint256 burnAmount = currentBalance.sub(newBalance);
			_burn(account, burnAmount);
		}
	}
}

contract BaltoToken is Ownable, ERC20 {
    IRouter public uniswapV2Router;
	address public immutable uniswapV2Pair;

    string private constant _name = "Balto Token";
    string private constant _symbol = "BALTO";
    uint8 private constant _decimals = 18;

    BaltoDividendTracker public dividendTracker;

    bool public isTradingEnabled;

    // initialSupply
    uint256 constant initialSupply = 1000000000 * (10**18);

    // max tx is 0.5% of initialSupply
    uint256 public maxTxAmount = initialSupply * 50 / 10000;

    // max wallet is 2.0% of initialSupply
    uint256 public maxWalletAmount = initialSupply * 150 / 10000;

    bool private _swapping;
    uint256 public minimumTokensBeforeSwap = initialSupply * 50 / 100000;
    uint256 public gasForProcessing = 300000;

    uint256 private _launchTimestamp;
    uint256 private _launchBlockNumber;

    address public liquidityWallet;
    address public devWallet;
    address public buyBackWallet;
    address public charityWallet;

    struct CustomTaxPeriod {
        bytes23 periodName;
        uint8 blocksInPeriod;
        uint256 timeInPeriod;
        uint8 liquidityFeeOnBuy;
        uint8 liquidityFeeOnSell;
        uint8 devFeeOnBuy;
        uint8 devFeeOnSell;
        uint8 buyBackFeeOnBuy;
        uint8 buyBackFeeOnSell;
        uint8 charityFeeOnBuy;
        uint8 charityFeeOnSell;
        uint8 holdersFeeOnBuy;
        uint8 holdersFeeOnSell;
    }

    // Base taxes
    CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,1,1,4,4,1,1,2,2,4,4);
    CustomTaxPeriod private _base = CustomTaxPeriod('default',0,0,1,1,4,4,1,1,2,2,4,4);

    // Balto Hour taxes
	uint256 private _baltoTimeHourStartTimestamp;
	CustomTaxPeriod private _baltoTime1 = CustomTaxPeriod('baltoTime1',0,3600,0,2,0,6,0,8,0,4,3,10);
	CustomTaxPeriod private _baltoTime2 = CustomTaxPeriod('baltoTime2',0,3600,1,2,4,6,1,6,2,3,4,8);

    uint256 private constant _blockedTimeLimit = 172800;
    bool private _feeOnWalletTranfers;
    mapping (address => bool) private _isAllowedToTradeWhenDisabled;
    mapping (address => bool) private _feeOnSelectedWalletTransfers;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromMaxWalletLimit;
    mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
    mapping (address => bool) private _isBlocked;
    mapping (address => bool) public automatedMarketMakerPairs;

    uint8 private _liquidityFee;
    uint8 private _devFee;
    uint8 private _buyBackFee;
    uint8 private _charityFee;
    uint8 private _holdersFee;
    uint8 private _totalFee;

    event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
    event DividendTrackerChange(address indexed newAddress, address indexed oldAddress);
    event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
    event WalletChange(string indexed indentifier, address indexed newWallet, address indexed oldWallet);
    event GasForProcessingChange(uint256 indexed newValue, uint256 indexed oldValue);
    event FeeChange(string indexed identifier, uint8 liquidityFee, uint8 devFee, uint8 buyBackFee, uint8 charityFee, uint8 holdersFee);
    event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
    event BlockedAccountChange(address indexed holder, bool indexed status);
    event BaltoTimeHourChange(bool indexed newValue, bool indexed oldValue);
    event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
    event MaxTransactionAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
    event ExcludeFromFeesChange(address indexed account, bool isExcluded);
    event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);
    event ExcludeFromMaxTransactionChange(address indexed account, bool isExcluded);
    event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
    event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
    event DividendsSent(uint256 tokensSwapped);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);
    event ClaimBNBOverflow(uint256 amount);
    event FeeOnWalletTransferChange(bool indexed newValue, bool indexed oldValue);
    event FeeOnSelectedWalletTransfersChange(address indexed account, bool newValue);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );
    event FeesApplied(uint256 liquidityFee, uint8 devFee, uint8 buyBackFee, uint8 charityFee, uint8 holdersFee, uint8 totalFee);

    constructor() ERC20(_name, _symbol) {
        dividendTracker = new BaltoDividendTracker();

        liquidityWallet = owner();
        devWallet = owner();
        buyBackWallet = owner();
        charityWallet = owner();

        IRouter _uniswapV2Router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
		address _uniswapV2Pair = IFactory(_uniswapV2Router.factory()).createPair(
			address(this),
			_uniswapV2Router.WETH()
		);
		uniswapV2Router = _uniswapV2Router;
		uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(dividendTracker)] = true;

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(0x000000000000000000000000000000000000dEaD));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        _isAllowedToTradeWhenDisabled[owner()] = true;
        _isAllowedToTradeWhenDisabled[address(this)] = true;

        _isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;
        _isExcludedFromMaxWalletLimit[address(dividendTracker)] = true;
        _isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[owner()] = true;

        _isExcludedFromMaxTransactionLimit[owner()] = true;
        _isExcludedFromMaxTransactionLimit[address(this)] = true;
        _isExcludedFromMaxTransactionLimit[address(dividendTracker)] = true;

        _mint(owner(), initialSupply);
    }

    receive() external payable {}

    // Setters
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    function activateTrading() external onlyOwner {
        isTradingEnabled = true;
        if (_launchTimestamp == 0) {
			_launchTimestamp = block.timestamp;
			_launchBlockNumber = block.number;
		}
    }
    function deactivateTrading() external onlyOwner {
        isTradingEnabled = false;
    }
    function setBaltoTimeHour() public onlyOwner {
		require(!this.isInBaltoTimeHour(), "Balto: BaltoTime Hour is already set");
		require(isTradingEnabled, "Balto: Trading must be enabled first");
		emit BaltoTimeHourChange(true, false);
		_baltoTimeHourStartTimestamp = block.timestamp;
	}
	function cancelBaltoTimeHour() public onlyOwner {
		require(this.isInBaltoTimeHour(), "Balto: BaltoTime Hour is not set");
		emit BaltoTimeHourChange(false, true);
		_baltoTimeHourStartTimestamp = 0;
	}
    function updateDividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(dividendTracker), "Balto: The dividend tracker already has that address");
        BaltoDividendTracker newDividendTracker = BaltoDividendTracker(payable(newAddress));
        require(newDividendTracker.owner() == address(this), "Balto: The new dividend tracker must be owned by the Balto token contract");
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(address(uniswapV2Pair));
        emit DividendTrackerChange(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Balto: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit AutomatedMarketMakerPairChange(pair, value);
    }
    function allowTradingWhenDisabled(address account, bool allowed) external onlyOwner {
        _isAllowedToTradeWhenDisabled[account] = allowed;
        emit AllowedWhenTradingDisabledChange(account, allowed);
    }
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFee[account] != excluded, "Balto: Account is already the value of 'excluded'");
        _isExcludedFromFee[account] = excluded;
        emit ExcludeFromFeesChange(account, excluded);
    }
    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }
    function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromMaxWalletLimit[account] != excluded, "Balto: Account is already the value of 'excluded'");
        _isExcludedFromMaxWalletLimit[account] = excluded;
        emit ExcludeFromMaxWalletChange(account, excluded);
    }
    function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromMaxTransactionLimit[account] != excluded, "Balto: Account is already the value of 'excluded'");
        _isExcludedFromMaxTransactionLimit[account] = excluded;
        emit ExcludeFromMaxTransactionChange(account, excluded);
    }
    function blockAccount(address account) external onlyOwner {
        require(!_isBlocked[account], "Balto: Account is already blocked");
        require((block.timestamp - _launchTimestamp) < _blockedTimeLimit, "Balto: Time to block accounts has expired");
        _isBlocked[account] = true;
        emit BlockedAccountChange(account, true);
    }
    function unblockAccount(address account) external onlyOwner {
        require(_isBlocked[account], "Balto: Account is not blcoked");
        _isBlocked[account] = false;
        emit BlockedAccountChange(account, false);
    }
    function setFeeOnWalletTransfers(bool value) external onlyOwner {
        emit FeeOnWalletTransferChange(value, _feeOnWalletTranfers);
        _feeOnWalletTranfers = value;
    }
    function setFeeOnSelectedWalletTransfers(address account, bool value) external onlyOwner {
		require(_feeOnSelectedWalletTransfers[account] != value, "Balto: The selected wallet is already set to the value ");
		_feeOnSelectedWalletTransfers[account] = value;
		emit FeeOnSelectedWalletTransfersChange(account, value);
	}
    function setWallets(address newLiquidityWallet, address newDevWallet, address newBuyBackWallet, address newCharityWallet) external onlyOwner {
        if(liquidityWallet != newLiquidityWallet) {
            require(newLiquidityWallet != address(0), "Balto: The liquidityWallet cannot be 0");
            emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
            liquidityWallet = newLiquidityWallet;
        }
        if(devWallet != newDevWallet) {
            require(newDevWallet != address(0), "Balto: The devWallet cannot be 0");
            emit WalletChange('devWallet', newDevWallet, devWallet);
            devWallet = newDevWallet;
        }
        if(buyBackWallet != newBuyBackWallet) {
            require(newBuyBackWallet != address(0), "Balto: The buyBackWallet cannot be 0");
            emit WalletChange('buyBackWallet', newBuyBackWallet, buyBackWallet);
            buyBackWallet = newBuyBackWallet;
        }
        if(charityWallet != newCharityWallet) {
            require(newCharityWallet != address(0), "Balto: The charityWallet cannot be 0");
            emit WalletChange('charityWallet', newCharityWallet, charityWallet);
            charityWallet = newCharityWallet;
        }
    }
    function setAllFeesToZero() external onlyOwner {
        _setCustomBuyTaxPeriod(_base, 0, 0, 0, 0, 0);
        emit FeeChange('baseFees-Buy', 0, 0, 0, 0, 0);
        _setCustomSellTaxPeriod(_base, 0, 0, 0, 0, 0);
        emit FeeChange('baseFees-Sell', 0, 0, 0, 0, 0);
    }
    function resetAllFees() external onlyOwner {
        _setCustomBuyTaxPeriod(_base, _default.liquidityFeeOnBuy, _default.devFeeOnBuy, _default.buyBackFeeOnBuy, _default.charityFeeOnBuy, _default.holdersFeeOnBuy);
        emit FeeChange('baseFees-Buy', _default.liquidityFeeOnBuy, _default.devFeeOnBuy, _default.buyBackFeeOnBuy, _default.charityFeeOnBuy,  _default.holdersFeeOnBuy);
        _setCustomSellTaxPeriod(_base, _default.liquidityFeeOnSell, _default.devFeeOnSell, _default.buyBackFeeOnSell, _default.charityFeeOnSell,  _default.holdersFeeOnSell);
        emit FeeChange('baseFees-Sell', _default.liquidityFeeOnSell, _default.devFeeOnSell, _default.buyBackFeeOnSell, _default.charityFeeOnSell, _default.holdersFeeOnSell);
    }
    // Base fees
    function setBaseFeesOnBuy(uint8 _liquidityFeeOnBuy, uint8 _devFeeOnBuy, uint8 _buyBackFeeOnBuy, uint8 _charityFeeOnBuy, uint8 _holdersFeeOnBuy) external onlyOwner {
        _setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _charityFeeOnBuy, _holdersFeeOnBuy);
        emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _charityFeeOnBuy, _holdersFeeOnBuy);
    }
    function setBaseFeesOnSell(uint8 _liquidityFeeOnSell,uint8 _devFeeOnSell, uint8 _buyBackFeeOnSell, uint8 _charityFeeOnSell, uint8 _holdersFeeOnSell) external onlyOwner {
        _setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _charityFeeOnSell, _holdersFeeOnSell);
        emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _charityFeeOnSell, _holdersFeeOnSell);
    }
    function setUniswapRouter(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "Balto: The router already has that address");
        emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));
        uniswapV2Router = IRouter(newAddress);
    }
    function setGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue != gasForProcessing, "Balto: Cannot update gasForProcessing to same value");
        emit GasForProcessingChange(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }
    function setMaxWalletAmount(uint256 newValue) external onlyOwner {
        require(newValue != maxWalletAmount, "Balto: Cannot update maxWalletAmount to same value");
        emit MaxWalletAmountChange(newValue, maxWalletAmount);
        maxWalletAmount = newValue;
    }
    function setMaxTransactionAmount(uint256 newValue) external onlyOwner {
        require(newValue != maxTxAmount, "Balto: Cannot update maxTxAmount to same value");
        emit MaxTransactionAmountChange(newValue, maxTxAmount);
        maxTxAmount = newValue;
    }
    function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {
        require(newValue != minimumTokensBeforeSwap, "Balto: Cannot update minimumTokensBeforeSwap to same value");
        emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
        minimumTokensBeforeSwap = newValue;
    }
    function setMinimumTokenBalanceForDividends(uint256 newValue) external onlyOwner {
        dividendTracker.setTokenBalanceForDividends(newValue);
    }
    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }
    function claimBNBOverflow() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success,) = address(owner()).call{value : amount}("");
        if (success){
            emit ClaimBNBOverflow(amount);
        }
    }

    // Getters
    function isInBaltoTimeHour() external view returns (bool) {
		uint256 totalBaltoTimeTime = _baltoTime1.timeInPeriod + _baltoTime2.timeInPeriod;
		if(block.timestamp - _baltoTimeHourStartTimestamp < totalBaltoTimeTime) {
			return true;
		} else {
			return false;
		}
	}
    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }
    function withdrawableDividendOf(address account) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }
    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }
    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
    function getBaseBuyFees() external view returns (uint8, uint8, uint8, uint8, uint8){
        return (_base.liquidityFeeOnBuy, _base.devFeeOnBuy, _base.buyBackFeeOnBuy, _base.charityFeeOnBuy, _base.holdersFeeOnBuy);
    }
    function getBaseSellFees() external view returns (uint8, uint8, uint8, uint8, uint8){
        return (_base.liquidityFeeOnSell, _base.devFeeOnSell, _base.buyBackFeeOnSell, _base.charityFeeOnSell, _base.holdersFeeOnSell);
    }

    // Main
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool isBuyFromLp = automatedMarketMakerPairs[from];
        bool isSelltoLp = automatedMarketMakerPairs[to];

        if(!_isAllowedToTradeWhenDisabled[from] && !_isAllowedToTradeWhenDisabled[to]) {
            require(isTradingEnabled, "Balto: Trading is currently disabled.");
            require(!_isBlocked[to], "Balto: Account is blocked");
            require(!_isBlocked[from], "Balto: Account is blocked");
            if (!_isExcludedFromMaxWalletLimit[to]) {
                require((balanceOf(to) + amount) <= maxWalletAmount, "Balto: Expected wallet amount exceeds the maxWalletAmount.");
            }
            if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
                require(amount <= maxTxAmount, "Balto: Transfer amount exceeds the maxTxAmount.");
            }
        }

        _adjustTaxes(isBuyFromLp, isSelltoLp, to, from);
        bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

        if (
            isTradingEnabled &&
            canSwap &&
            !_swapping &&
            _totalFee > 0 &&
            automatedMarketMakerPairs[to]
        ) {
            _swapping = true;
            _swapAndLiquify();
            _swapping = false;
        }

        bool takeFee = !_swapping && isTradingEnabled;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        if (takeFee && _totalFee > 0) {
            uint256 fee = amount * _totalFee / 100;
            amount = amount - fee;
            super._transfer(from, address(this), fee);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!_swapping) {
            uint256 gas = gasForProcessing;
            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            }
            catch {}
        }
    }
    function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp, address to, address from) private {
        uint256 timeSinceBaltoTime = block.timestamp - _baltoTimeHourStartTimestamp;
        _liquidityFee = 0;
        _devFee = 0;
        _buyBackFee = 0;
        _charityFee = 0;
        _holdersFee = 0;

        if (isBuyFromLp) {
			if ((block.number - _launchBlockNumber) <= 7) {
				_devFee = 100;
			}
			else {
				_liquidityFee = _base.liquidityFeeOnBuy;
				_devFee = _base.devFeeOnBuy;
				_buyBackFee = _base.buyBackFeeOnBuy;
				_charityFee = _base.charityFeeOnBuy;
				_holdersFee = _base.holdersFeeOnBuy;

				if (timeSinceBaltoTime <= _baltoTime1.timeInPeriod) {
					_liquidityFee = _baltoTime1.liquidityFeeOnBuy;
					_devFee = _baltoTime1.devFeeOnBuy;
					_buyBackFee = _baltoTime1.buyBackFeeOnBuy;
	                _charityFee = _baltoTime1.charityFeeOnBuy;
					_holdersFee = _baltoTime1.holdersFeeOnBuy;
				}
				if (timeSinceBaltoTime > _baltoTime1.timeInPeriod && timeSinceBaltoTime <= _baltoTime1.timeInPeriod + _baltoTime2.timeInPeriod) {
					_liquidityFee = _baltoTime2.liquidityFeeOnBuy;
					_devFee = _baltoTime2.devFeeOnBuy;
					_buyBackFee = _baltoTime2.buyBackFeeOnBuy;
	                _charityFee = _baltoTime2.charityFeeOnBuy;
					_holdersFee = _baltoTime2.holdersFeeOnBuy;
				}
			}
		}
        else if (isSelltoLp) {
			_liquidityFee = _base.liquidityFeeOnSell;
			_devFee = _base.devFeeOnSell;
			_buyBackFee = _base.buyBackFeeOnSell;
			_charityFee = _base.charityFeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;

            if (timeSinceBaltoTime <= _baltoTime1.timeInPeriod) {
				_liquidityFee = _baltoTime1.liquidityFeeOnSell;
				_devFee = _baltoTime1.devFeeOnSell;
				_buyBackFee = _baltoTime1.buyBackFeeOnSell;
                _charityFee = _baltoTime1.charityFeeOnSell;
				_holdersFee = _baltoTime1.holdersFeeOnSell;
			}
			if (timeSinceBaltoTime > _baltoTime1.timeInPeriod && timeSinceBaltoTime <= _baltoTime1.timeInPeriod + _baltoTime2.timeInPeriod) {
				_liquidityFee = _baltoTime2.liquidityFeeOnSell;
				_devFee = _baltoTime2.devFeeOnSell;
				_buyBackFee = _baltoTime2.buyBackFeeOnSell;
                _charityFee = _baltoTime2.charityFeeOnSell;
				_holdersFee = _baltoTime2.holdersFeeOnSell;
			}
        }
        else if (!isSelltoLp && !isBuyFromLp && (_feeOnSelectedWalletTransfers[from] || _feeOnSelectedWalletTransfers[to])) {
			_liquidityFee = _base.liquidityFeeOnSell;
            _devFee = _base.devFeeOnSell;
            _buyBackFee = _base.buyBackFeeOnSell;
            _charityFee = _base.charityFeeOnSell;
            _holdersFee = _base.holdersFeeOnSell;
		}
		else if (!isSelltoLp && !isBuyFromLp && !_feeOnSelectedWalletTransfers[from] && !_feeOnSelectedWalletTransfers[to] && _feeOnWalletTranfers) {
			_liquidityFee = _base.liquidityFeeOnBuy;
            _devFee = _base.devFeeOnBuy;
            _buyBackFee = _base.buyBackFeeOnBuy;
            _charityFee = _base.charityFeeOnBuy;
            _holdersFee = _base.holdersFeeOnBuy;
		}
        _totalFee = _liquidityFee + _devFee + _buyBackFee + _charityFee + _holdersFee;
        emit FeesApplied(_liquidityFee, _devFee, _buyBackFee, _charityFee, _holdersFee, _totalFee);
    }
    function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
        uint8 _liquidityFeeOnSell,
        uint8 _devFeeOnSell,
        uint8 _buyBackFeeOnSell,
        uint8 _charityFeeOnSell,
        uint8 _holdersFeeOnSell
        ) private {
        if (map.liquidityFeeOnSell != _liquidityFeeOnSell) {
            emit CustomTaxPeriodChange(_liquidityFeeOnSell, map.liquidityFeeOnSell, 'liquidityFeeOnSell', map.periodName);
            map.liquidityFeeOnSell = _liquidityFeeOnSell;
        }
        if (map.devFeeOnSell != _devFeeOnSell) {
            emit CustomTaxPeriodChange(_devFeeOnSell, map.devFeeOnSell, 'devFeeOnSell', map.periodName);
            map.devFeeOnSell = _devFeeOnSell;
        }
        if (map.buyBackFeeOnSell != _buyBackFeeOnSell) {
            emit CustomTaxPeriodChange(_buyBackFeeOnSell, map.buyBackFeeOnSell, 'buyBackFeeOnSell', map.periodName);
            map.buyBackFeeOnSell = _buyBackFeeOnSell;
        }
        if (map.charityFeeOnSell != _charityFeeOnSell) {
            emit CustomTaxPeriodChange(_charityFeeOnSell, map.charityFeeOnSell, 'charityFeeOnSell', map.periodName);
            map.charityFeeOnSell = _charityFeeOnSell;
        }
        if (map.holdersFeeOnSell != _holdersFeeOnSell) {
            emit CustomTaxPeriodChange(_holdersFeeOnSell, map.holdersFeeOnSell, 'holdersFeeOnSell', map.periodName);
            map.holdersFeeOnSell = _holdersFeeOnSell;
        }
    }
    function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
        uint8 _liquidityFeeOnBuy,
        uint8 _devFeeOnBuy,
        uint8 _buyBackFeeOnBuy,
        uint8 _charityFeeOnBuy,
        uint8 _holdersFeeOnBuy
        ) private {
        if (map.liquidityFeeOnBuy != _liquidityFeeOnBuy) {
            emit CustomTaxPeriodChange(_liquidityFeeOnBuy, map.liquidityFeeOnBuy, 'liquidityFeeOnBuy', map.periodName);
            map.liquidityFeeOnBuy = _liquidityFeeOnBuy;
        }
        if (map.devFeeOnBuy != _devFeeOnBuy) {
            emit CustomTaxPeriodChange(_devFeeOnBuy, map.devFeeOnBuy, 'devFeeOnBuy', map.periodName);
            map.devFeeOnBuy = _devFeeOnBuy;
        }
        if (map.buyBackFeeOnBuy != _buyBackFeeOnBuy) {
            emit CustomTaxPeriodChange(_buyBackFeeOnBuy, map.buyBackFeeOnBuy, 'buyBackFeeOnBuy', map.periodName);
            map.buyBackFeeOnBuy = _buyBackFeeOnBuy;
        }
        if (map.charityFeeOnBuy != _charityFeeOnBuy) {
            emit CustomTaxPeriodChange(_charityFeeOnBuy, map.charityFeeOnBuy, 'charityFeeOnBuy', map.periodName);
            map.charityFeeOnBuy = _charityFeeOnBuy;
        }
        if (map.holdersFeeOnBuy != _holdersFeeOnBuy) {
            emit CustomTaxPeriodChange(_holdersFeeOnBuy, map.holdersFeeOnBuy, 'holdersFeeOnBuy', map.periodName);
            map.holdersFeeOnBuy = _holdersFeeOnBuy;
        }
    }
    function _swapAndLiquify() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 initialBNBBalance = address(this).balance;
        uint8 totalFeePrior = _totalFee;

        uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFee / 2;
        uint256 amountToSwap = contractBalance - amountToLiquify;

        _swapTokensForBNB(amountToSwap);

        uint256 BNBBalanceAfterSwap = address(this).balance - initialBNBBalance;
        uint256 totalBNBFee = _totalFee - (_liquidityFee / 2);

        uint256 amountBNBLiquidity = BNBBalanceAfterSwap * _liquidityFee / totalBNBFee / 2;
        uint256 amountBNBDev = BNBBalanceAfterSwap * _devFee / totalBNBFee;
        uint256 amountBNBBuyBack = BNBBalanceAfterSwap * _buyBackFee / totalBNBFee;
        uint256 amountBNBCharity = BNBBalanceAfterSwap * _charityFee / totalBNBFee;
        uint256 amountBNBHolders = BNBBalanceAfterSwap - (amountBNBLiquidity + amountBNBDev + amountBNBBuyBack + amountBNBCharity);

        payable(devWallet).transfer(amountBNBDev);
        payable(buyBackWallet).transfer(amountBNBBuyBack);
        payable(charityWallet).transfer(amountBNBCharity);

        if (amountToLiquify > 0) {
            _addLiquidity(amountToLiquify, amountBNBLiquidity);
            emit SwapAndLiquify(amountToSwap, amountBNBLiquidity, amountToLiquify);
        }

        (bool dividendSuccess,) = address(dividendTracker).call{value: amountBNBHolders}("");
        if(dividendSuccess) {
            emit DividendsSent(amountBNBHolders);
        }
        _totalFee = totalFeePrior;
    }
    function _swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
    }
}

contract BaltoDividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;

    uint256 public lastProcessedIndex;
    mapping (address => bool) public excludedFromDividends;
    mapping (address => uint256) public lastClaimTimes;
    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("Balto_Dividend_Tracker", "Balto_Dividend_Tracker") {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 0 * (10**18);
    }
    function _transfer(address, address, uint256) internal override {
        require(false, "Balto_Dividend_Tracker: No transfers allowed");
    }
    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
        emit ExcludeFromDividends(account);
    }
    function setTokenBalanceForDividends(uint256 newValue) external onlyOwner {
        require(minimumTokenBalanceForDividends != newValue, "Balto_Dividend_Tracker: minimumTokenBalanceForDividends already the value of 'newValue'.");
        minimumTokenBalanceForDividends = newValue;
    }
    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }
    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if(lastClaimTime > block.timestamp)  {
            return false;
        }
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }
    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
        if(excludedFromDividends[account]) {
            return;
        }
        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }
        processAccount(account, true);
    }
    function process(uint256 gas) public onlyOwner returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        if(numberOfTokenHolders == 0) {
        return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;
            if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }
            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            if(canAutoClaim(lastClaimTimes[account])) {
                if(processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;
            uint256 newGasLeft = gasleft();
            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }
        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }
    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);
        if(amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }
}
