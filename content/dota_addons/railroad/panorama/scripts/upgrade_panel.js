var primaryCost;
var secondaryCost;

var selectedBuff;

function Toggle() {
	$.Msg("Disabled");
	// $("#UpgradePanelDisplay").SetHasClass("UpgradePanelDisplay", true);
	$("#UpgradePanelDisplay").ToggleClass("Disabled");
}

function UpdatePrimaryCost() {
	if (selectedBuff) {
		var ent = CustomNetTables.GetTableValue("players", Players.GetLocalPlayer().toString()).buff_dummy;
		var ability = selectedBuff.id.replace("Cell", "buff_");

	    primaryCost = GetCost(ent, Entities.GetAbilityByName( ent, ability ));
	}
}

function Update() {
	var candies;
	var t = CustomNetTables.GetTableValue("players", Players.GetLocalPlayer().toString());
	if (t) {
		candies = t.candies;
		$("#CandyCount").text = candies;
	}
	candies = candies || 0;

	$.Schedule(0.1, UpdatePrimaryCost);

	var cost = secondaryCost || (primaryCost || 0);

	$("#UpgradeCost").SetHasClass("Red", cost>candies);

	$("#UpgradeCost").text = cost;

	CustomNetTables.GetTableValue("buffs_kvs", Players.GetLocalPlayer().toString())

	$.Schedule(0.1, Update);
}

function GetCost(ent, ability) {
    var abilityLevel = Abilities.GetLevel(ability);
    if (abilityLevel == 4) {

    } else {
    	var costLevel = (abilityLevel || 0)
        return Abilities.GetLevelSpecialValueFor( ability, "cost", costLevel );
    }
    return 0;
}

function Upgrade() {
	if (selectedBuff) {
		if (parseInt($("#CandyCount").text) >= parseInt($("#UpgradeCost").text)) {
			Game.EmitSound("General.Buy");
		}
		GameEvents.SendCustomGameEventToServer("frostivus_upgrade", {id: selectedBuff.id})
	}
}

(function () {
	$.Each($("#Rows").FindChildrenWithClassTraverse("Cell"), (function (panel) {
		(function (panel) {
			panel.SetPanelEvent('onactivate', function(){
				if (selectedBuff) {
					selectedBuff.SetHasClass("Selected", false)
				}
		        selectedBuff = panel;
		        selectedBuff.SetHasClass("Selected", true);

		        UpdatePrimaryCost()
			});

			panel.SetPanelEvent('onmouseover', function() {
				var ent = CustomNetTables.GetTableValue("players", Players.GetLocalPlayer().toString()).buff_dummy;
				var ability = panel.id.replace("Cell", "buff_");
		        $.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", panel, ability, ent);

		        secondaryCost = GetCost(ent, Entities.GetAbilityByName( ent, ability ));
			});

			panel.SetPanelEvent('onmouseout', function(){
		        $.DispatchEvent('DOTAHideAbilityTooltip');

		        secondaryCost = undefined;
			});
		})(panel);
	}))

	Update()
})();