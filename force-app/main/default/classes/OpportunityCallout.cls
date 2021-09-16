public class OpportunityCallout {
	@future(callout=true)
	public static void postInfo(
		String endpoint,
		String partnerName,
		String opportunityName,
		Decimal amount,
		String type
	) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		request.setBody(
			'{"Name":"' +
			opportunityName +
			'", "Amount":"' +
			amount +
			'","Type":"' +
			type +
			'","Partner Name":"' +
			partnerName +
			'"}'
		);
		HttpResponse response = http.send(request);
		if (response.getStatusCode() != 201) {
			System.debug(
				'The status code returned was not expected: ' +
				response.getStatusCode() +
				' ' +
				response.getStatus()
			);
		} else {
			System.debug(response.getBody());
		}
	}
}