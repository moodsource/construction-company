@isTest
global class OpportunityCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest request) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setBody(
			'{"Name":"OpportunityShared", "Amount":"60","Type":"New Customer","Partner Name":"testPartner"}'
		);
		response.setStatusCode(200);
		return response;
	}
}
