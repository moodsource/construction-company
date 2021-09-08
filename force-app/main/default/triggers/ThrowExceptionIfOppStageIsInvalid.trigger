trigger ThrowExceptionIfOppStageIsInvalid on Opportunity (before update) {
	for(Opportunity oppNew : Trigger.New) {
        if(oppNew.StageName == 'Closed Won'){
            for(Opportunity oppOld : Trigger.Old) {
            	if(oppOld.StageName == 'Negotiation' || oppOld.StageName == 'Quote Sent'){
                    oppNew.addError(
                        'You cannot change Quote Sent and Negotiation status on Closed Won.'
                    );
            	}
    		}
        }
    }
}