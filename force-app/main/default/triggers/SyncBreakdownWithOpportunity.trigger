trigger SyncBreakdownWithOpportunity on Work_Breakdown_Structure__c (After update) {
	for(Work_Breakdown_Structure__c wbs : Trigger.New) {
        if(wbs.Status__c == 'Sent' && wbs.Opportunity__c != null){
            Opportunity opp = [SELECT Amount, Decision_Maker__r.LastName FROM Opportunity WHERE Id =:wbs.Opportunity__c];
            if(wbs.Total_Amount__c != 0){
                opp.Amount = wbs.Total_Amount__c;
            }
            opp.Work_Breakdown_Structure__c = wbs.Id;
            EmailUtility.toSendEmailWithTemplate(opp.Decision_Maker__r.LastName, 'Contact');
            update opp;
        }
    }   
}