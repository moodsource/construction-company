trigger WorkBreakdownTrigger on Work_Breakdown_Structure__c(
	after update,
	before update,
	before delete,
	after insert,
	after delete,
	after undelete,
	before insert
) {
	TriggerFactory.execute(Work_Breakdown_Structure__c.sObjectType);
}
