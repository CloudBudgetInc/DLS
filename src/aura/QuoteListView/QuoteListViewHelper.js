({
	getFormatedString  : function(num, code, currencySym) {
        let currency = num.toLocaleString(code, {minimumFractionDigits:2});
        return currencySym + currency;        
    }
})