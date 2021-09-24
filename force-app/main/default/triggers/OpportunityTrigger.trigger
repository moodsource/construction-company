trigger OpportunityTrigger on Opportunity(
	after update,
	before update,
	before delete,
	after insert,
	after delete,
	after undelete,
	before insert
) {
	TriggerFactory.execute(Opportunity.sObjectType);
}
