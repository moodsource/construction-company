public with sharing class OpportunityInfoRequest {
	public String Name;
	public Decimal Amount;
	public String Type;
	public String PartnerName;

	public OpportunityInfoRequest(String opportunityName, Decimal amount, String type, String partnerName) {
		this.Name = opportunityName;
		this.Amount = amount;
		this.Type = type;
		this.PartnerName = partnerName;
	}
}
