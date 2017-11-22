function Toggle() {
	$.Msg("Disabled");
	// $("#UpgradePanelDisplay").SetHasClass("UpgradePanelDisplay", true);
	$("#UpgradePanelDisplay").ToggleClass("Disabled");
}

(function () {
	$.Each($("#Rows").FindChildrenWithClassTraverse("Cell"), (function (panel) {
		panel.SetPanelEvent('onmouseover', function() {
	        $.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", panel, panel.id.replace("Cell", "buff_"), Players.GetLocalPlayerPortraitUnit() );
		});

		panel.SetPanelEvent('onmouseout', function(){
	        $.DispatchEvent('DOTAHideAbilityTooltip');
		});
	}))
})();