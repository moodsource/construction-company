public class WorkBreakdownStructureTriggerHandler extends AbstractTriggerHandler {
	public override void beforeUpdate(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		markSyncedWbs(newItemsMap, oldItemsMap);
	}

	public override void afterUpdate(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		syncWbsAndOpportunity(newItemsMap, oldItemsMap);
	}

	private void markSyncedWbs(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		for (Work_Breakdown_Structure__c wbs : (List<Work_Breakdown_Structure__c>) newItemsMap.values()) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				wbs.IsSynced__c = true;
			}
		}
	}

	private void syncWbsAndOpportunity(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
		Set<Id> oppIds = new Set<Id>();
		for (Work_Breakdown_Structure__c wbs : (List<Work_Breakdown_Structure__c>) newItemsMap.values()) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				oppIds.add(wbs.Opportunity__c);
			}
		}
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
			[SELECT Amount, Decision_Maker__r.LastName, id FROM Opportunity WHERE id IN :oppIds]
		);
		for (Work_Breakdown_Structure__c wbs : (List<Work_Breakdown_Structure__c>) newItemsMap.values()) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				Opportunity opp = oppMap.get(wbs.Opportunity__c);
				opp.Amount = wbs.Total_Amount__c;
				opp.Work_Breakdown_Structure__c = wbs.Id;
				update opp;
				mailList.add(EmailUtility.putEmailInfoOnTemplate(opp.Decision_Maker__r.LastName, Contact.SObjectType));
			}
		}
		EmailUtility.sendEmail(mailList);
	}
}
