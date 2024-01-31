({
	launchCongaUrl : function(cmp, congaUrl) {
		window.open(congaUrl, '_blank');		
		$A.get("e.force:closeQuickAction").fire();
	}
})