public class WorkBreakdownStructureTriggerHandler implements ITriggerHandler {
	private static Boolean triggerDisabled = false;

	public void disableTrigger() {
		triggerDisabled = true;
	}
	public void enableTrigger() {
		triggerDisabled = false;
	}

	public Boolean isTriggerEnabled() {
		if (triggerDisabled) {
			return false;
		} else {
			return true;
		}
	}

	public void beforeUpdate(
		Map<Id, SObject> newItemsMap,
		Map<Id, SObject> oldItemsMap,
		List<SObject> newItems,
		List<SObject> oldItems
	) {
		for (Work_Breakdown_Structure__c wbs : (List<Work_Breakdown_Structure__c>) newItems) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				wbs.IsSynced__c = true;
			}
		}
	}

	public void afterUpdate(
		Map<Id, SObject> newItemsMap,
		Map<Id, SObject> oldItemsMap,
		List<SObject> newItems,
		List<SObject> oldItems
	) {
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
		Set<Id> oppIds = new Set<Id>();
		for (Work_Breakdown_Structure__c wbs : (List<Work_Breakdown_Structure__c>) newItems) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				oppIds.add(wbs.Opportunity__c);
			}
		}
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
			[SELECT Amount, Decision_Maker__r.LastName, id FROM Opportunity WHERE id IN :oppIds]
		);
		for (Work_Breakdown_Structure__c wbs : (List<Work_Breakdown_Structure__c>) newItems) {
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

	public void beforeInsert(List<SObject> newItems) {
	}

	public void beforeDelete(Map<Id, SObject> oldItemsMap) {
	}

	public void afterDelete(Map<Id, SObject> oldItemsMap) {
	}

	public void afterUndelete(Map<Id, SObject> oldItemsMap) {
	}

	public void afterInsert(Map<Id, SObject> newItemsMap) {
	}
}
