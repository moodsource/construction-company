trigger WorkBreakdownTrigger on Work_Breakdown_Structure__c(after update, before update) {
	TriggerFactory.execute(Work_Breakdown_Structure__c.sObjectType);
}
