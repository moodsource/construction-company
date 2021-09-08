trigger MarkSyncedBreakdown on Work_Breakdown_Structure__c (before update) {
	for(Work_Breakdown_Structure__c wbs : Trigger.New) {
        if(wbs.Status__c == 'Sent' && wbs.Opportunity__c != null){
            wbs.IsSynced__c = true;
        }
    }           
}