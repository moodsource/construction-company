@RestResource(urlMapping='/services/apexrest/CompanyData/Opportunity/*')
global with sharing class OpportunityRestResource {
	@HttpPost
	global static id upsertOpportunityAndPartner(
		String partnerName,
		String opportunityName,
		Decimal amount,
		String type
	) {
		Opportunity opp = [SELECT Name, Partner__c, Amount, Type FROM Opportunity WHERE Name = :opportunityName];
		Partner__c par = [SELECT Name FROM Partner__c WHERE Name = :partnerName];
		opp.Name = opportunityName;
		opp.Amount = amount;
		opp.Type = type;
		upsert opp;
		par.Name = partnerName;
		upsert par;
		return opp.id;
	}
}
