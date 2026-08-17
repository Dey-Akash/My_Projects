@isTest
private class LeadNewsEnrichmentQueueableTest {

    private class NewsAPIMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"ok","totalResults":2,"articles":['
                + '{"title":"Acme raises Series B","publishedAt":"2026-06-15T10:00:00Z"},'
                + '{"title":"Acme launches new product","publishedAt":"2026-06-20T10:00:00Z"}'
                + ']}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testEnrichmentPopulatesFields() {
        Lead ld = new Lead(LastName='Test', Company='Acme Corp', Status='Open - Not Contacted');
        insert ld;

        Test.setMock(HttpCalloutMock.class, new NewsAPIMock());

        Test.startTest();
        System.enqueueJob(new LeadNewsEnrichmentQueueable(ld.Id, 'Acme Corp'));
        Test.stopTest();

        Lead updated = [SELECT News_Summary__c, News_Mention_Count__c, Last_News_Date__c
                        FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(2, updated.News_Mention_Count__c, 'Should count 2 articles');
        System.assert(updated.News_Summary__c.contains('Series B'), 'Should contain headline');
        System.assertEquals(Date.newInstance(2026, 6, 20), updated.Last_News_Date__c);
    }

    @isTest
    static void testInvocableEnqueues() {
        Lead ld = new Lead(LastName='Test2', Company='Beta Inc', Status='Open - Not Contacted');
        insert ld;

        Test.setMock(HttpCalloutMock.class, new NewsAPIMock());

        LeadNewsEnrichmentInvocable.Request r = new LeadNewsEnrichmentInvocable.Request();
        r.leadId = ld.Id;
        r.companyName = 'Beta Inc';

        Test.startTest();
        LeadNewsEnrichmentInvocable.enqueueEnrichment(new List<LeadNewsEnrichmentInvocable.Request>{r});
        Test.stopTest();

        Lead updated = [SELECT News_Mention_Count__c FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(2, updated.News_Mention_Count__c);
    }

    @isTest
    static void testInvocableIsBulkSafe() {
        // 60 leads in one transaction. Enqueueing one job per lead used to fail here
        // with "Too many queueable jobs added to the queue: 51".
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 60; i++) {
            leads.add(new Lead(LastName = 'Bulk' + i, Company = 'Bulk Co ' + i,
                               Status = 'Open - Not Contacted'));
        }
        insert leads;

        Test.setMock(HttpCalloutMock.class, new NewsAPIMock());

        List<LeadNewsEnrichmentInvocable.Request> reqs =
            new List<LeadNewsEnrichmentInvocable.Request>();
        for (Lead l : leads) {
            LeadNewsEnrichmentInvocable.Request r = new LeadNewsEnrichmentInvocable.Request();
            r.leadId = l.Id;
            r.companyName = l.Company;
            reqs.add(r);
        }

        Test.startTest();
        LeadNewsEnrichmentInvocable.enqueueEnrichment(reqs);
        System.assertEquals(1, Limits.getQueueableJobs(),
                            'The whole batch must go into a single queueable job');
        Test.stopTest();

        // Chaining is suppressed under test, so only the first chunk is processed.
        Integer enriched = [SELECT COUNT() FROM Lead
                            WHERE Id IN :leads AND News_Mention_Count__c = 2];
        System.assertEquals(20, enriched, 'First chunk of 20 should be enriched');
    }
}