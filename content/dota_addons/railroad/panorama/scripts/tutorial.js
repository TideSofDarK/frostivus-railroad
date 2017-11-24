(function () {
	$.Schedule(9.0, function () {
		$("#TutorialPanel").SetHasClass("Hidden", true);
	})
	$.GetContextPanel().DeleteAsync(9.5);
})();