function Toggle() {
	$.Msg("Disabled");
	// $("#UpgradePanelDisplay").SetHasClass("UpgradePanelDisplay", true);
	$("#UpgradePanelDisplay").ToggleClass("Disabled");
}

function Update() {
	var t = CustomNetTables.GetTableValue("players", Players.GetLocalPlayer().toString());
	if (t) {
		$("#CandyCount").text = t.candies;
	}

	$.Schedule(1.0, Update);
}

(function () {
	$.Each($("#Rows").FindChildrenWithClassTraverse("Cell"), (function (panel) {
		(function (panel) {
			panel.SetPanelEvent('onmouseover', function() {
				var ent = CustomNetTables.GetTableValue("players", Players.GetLocalPlayer().toString()).buff_dummy;
				var ability = panel.id.replace("Cell", "buff_");
		        $.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", panel, ability, ent);
			});

			panel.SetPanelEvent('onmouseout', function(){
		        $.DispatchEvent('DOTAHideAbilityTooltip');
			});
		})(panel);
	}))

	Update()
})();