trigger WorkBreakdownTrigger on Work_Breakdown_Structure__c(before update, after update) {
	if (Trigger.isBefore) {
		for (Work_Breakdown_Structure__c wbs : Trigger.New) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				wbs.IsSynced__c = true;
			}
		}
	} else if (Trigger.isAfter) {
		for (Work_Breakdown_Structure__c wbs : Trigger.New) {
			if (wbs.Status__c == Constants.WBS_STATUS_SENT && wbs.Opportunity__c != null) {
				Opportunity opp = [
					SELECT Amount, Decision_Maker__r.LastName
					FROM Opportunity
					WHERE Id = :wbs.Opportunity__c
				];
				opp.Amount = wbs.Total_Amount__c;
				opp.Work_Breakdown_Structure__c = wbs.Id;
				EmailUtility.toSendEmailWithTemplate(opp.Decision_Maker__r.LastName, Contact.SObjectType);
				update opp;
			}
		}
	}
}
