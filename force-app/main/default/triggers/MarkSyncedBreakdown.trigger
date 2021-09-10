trigger MarkSyncedBreakdown on Work_Breakdown_Structure__c(before update) {
	for (Work_Breakdown_Structure__c wbs : Trigger.New) {
		if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
			wbs.IsSynced__c = true;
		}
	}
}
