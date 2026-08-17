@isTest
private class LeadResearchContextActionTest {

    // The Lead_News_Enrichment_on_Create flow calls out on insert.
    private class NoopNewsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"ok","totalResults":0,"articles":[]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private static LeadResearchContextAction.Request req(Id leadId) {
        LeadResearchContextAction.Request r = new LeadResearchContextAction.Request();
        r.leadId = leadId;
        return r;
    }

    @isTest
    static void returnsContextForEachLead() {
        Test.setMock(HttpCalloutMock.class, new NoopNewsMock());

        Lead ld = new Lead(LastName = 'Tester', Company = 'Infosys', Industry = 'Technology',
                           Rating = 'Hot', LeadSource = 'Web',
                           News_Summary__c = 'Infosys wins large deal',
                           News_Mention_Count__c = 5,
                           Last_News_Date__c = Date.newInstance(2026, 8, 15));
        insert ld;

        Test.startTest();
        List<LeadResearchContextAction.Result> results =
            LeadResearchContextAction.getContext(new List<LeadResearchContextAction.Request>{ req(ld.Id) });
        Test.stopTest();

        System.assertEquals(1, results.size());
        String ctx = results[0].context;
        System.assert(ctx.contains('Company: Infosys'), ctx);
        System.assert(ctx.contains('Industry: Technology'), ctx);
        System.assert(ctx.contains('Existing rating: Hot'), ctx);
        System.assert(ctx.contains('Lead source: Web'), ctx);
        System.assert(ctx.contains('Infosys wins large deal'), ctx);
    }

    @isTest
    static void handlesNullFieldsAndMissingLead() {
        Test.setMock(HttpCalloutMock.class, new NoopNewsMock());

        Lead bare = new Lead(LastName = 'Bare', Company = 'Sparse Co');
        insert bare;

        // A syntactically valid Lead Id that resolves to no record.
        Id missingId = '00Q000000000000';

        Test.startTest();
        List<LeadResearchContextAction.Result> results =
            LeadResearchContextAction.getContext(new List<LeadResearchContextAction.Request>{
                req(bare.Id), req(missingId)
            });
        Test.stopTest();

        System.assertEquals(2, results.size(), 'One result per request, in order');
        System.assert(results[0].context.contains('Industry: unknown'), results[0].context);
        System.assert(results[0].context.contains('Existing rating: not set'), results[0].context);
        System.assert(results[0].context.contains('Headlines: none'), results[0].context);
        // Previously this threw QueryException and killed the whole invocation.
        System.assert(results[1].context.startsWith('No Lead found for Id'), results[1].context);
    }

    @isTest
    static void usesOneQueryRegardlessOfRequestCount() {
        Test.setMock(HttpCalloutMock.class, new NoopNewsMock());

        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 150; i++) {
            leads.add(new Lead(LastName = 'Bulk' + i, Company = 'Bulk Co ' + i));
        }
        insert leads;

        List<LeadResearchContextAction.Request> requests =
            new List<LeadResearchContextAction.Request>();
        for (Lead l : leads) requests.add(req(l.Id));

        Test.startTest();
        Integer before = Limits.getQueries();
        List<LeadResearchContextAction.Result> results =
            LeadResearchContextAction.getContext(requests);
        Integer used = Limits.getQueries() - before;
        Test.stopTest();

        System.assertEquals(150, results.size());
        // A query per request would have thrown "Too many SOQL queries: 101" at 150.
        System.assertEquals(1, used, 'The batch must resolve in a single SOQL query');
    }
}
