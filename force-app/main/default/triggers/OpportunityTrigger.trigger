trigger OpportunityTrigger on Opportunity(after update, before update) {
	TriggerFactory.execute(Opportunity.sObjectType);
}
