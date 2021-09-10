trigger ThrowExceptionIfOppStageIsInvalid on Opportunity(before update) {
	Map<Id, Opportunity> oldMap = Trigger.oldMap;
	for (Opportunity oppNew : Trigger.New) {
		if (oppNew.StageName == Constants.OPP_STAGE_CLOSED_WON) {
			Opportunity oppOld = oldMap.get(oppNew.Id);
			if (
				oppOld.StageName == Constants.OPP_STAGE_NEGOTIATION ||
				oppOld.StageName == Constants.OPP_STAGE_QUOTE_SENT
			) {
				oppNew.addError('You cannot change Quote Sent and Negotiation status on Closed Won.');
			}
		}
	}
}
