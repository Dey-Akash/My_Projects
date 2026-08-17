@isTest
private class PrioritizeLeadsActionTest {

    // The Lead_News_Enrichment_on_Create flow fires on insert and calls out; without
    // a mock the queueable would record an error over the summaries under test.
    private class NoopNewsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"ok","totalResults":0,"articles":[]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private static Lead buildLead(String company, String summary, Integer mentions) {
        return new Lead(LastName = 'Tester', Company = company,
                        Status = 'Open - Not Contacted', LeadSource = 'Web',
                        News_Summary__c = summary, News_Mention_Count__c = mentions);
    }

    @isTest
    static void verdictsMatchPicklistAndSignals() {
        Test.setMock(HttpCalloutMock.class, new NoopNewsMock());

        List<Lead> leads = new List<Lead>{
            buildLead('HotCo',  'HotCo raises Series B funding round | HotCo expansion into Europe', 2),
            buildLead('ColdCo', 'ColdCo announces layoffs | ColdCo losses widen this quarter', 2),
            buildLead('QuietCo','No recent news found', 0),
            buildLead('FailCo', 'Enrichment failed: HTTP 429', 0)
        };
        insert leads;

        Test.startTest();
        List<PrioritizeLeadsAction.Result> results = PrioritizeLeadsAction.prioritize(
            new List<PrioritizeLeadsAction.Request>{ new PrioritizeLeadsAction.Request() });
        Test.stopTest();

        Map<String, String> verdictByCompany = new Map<String, String>();
        for (Lead l : [SELECT Company, Priority_Verdict__c FROM Lead WHERE Id IN :leads]) {
            verdictByCompany.put(l.Company, l.Priority_Verdict__c);
        }

        // Would fail with '1 - Hot' / '3 - Cold' against the Hot/Warm/Cold picklist.
        System.assertEquals('Hot',  verdictByCompany.get('HotCo'),  'Positive news should score Hot');
        System.assertEquals('Cold', verdictByCompany.get('ColdCo'), 'Layoff news should score Cold');
        System.assertEquals('Cold', verdictByCompany.get('QuietCo'),'No news should score Cold');
        System.assertEquals(null,   verdictByCompany.get('FailCo'),
                            'A failed enrichment must not be scored at all');

        PrioritizeLeadsAction.Result r = results[0];
        System.assertEquals(1, r.skippedCount, 'FailCo should be reported as skipped');
        System.assertEquals(3, r.totalPrioritized);
        System.assertEquals(1, r.hotCount);
        System.assertEquals(2, r.coldCount);
    }

    @isTest
    static void queryDoesNotFilterOnLongTextArea() {
        Test.setMock(HttpCalloutMock.class, new NoopNewsMock());

        // An unenriched lead (null mention count) must be ignored, and the query
        // itself must not throw -- filtering News_Summary__c is invalid in SOQL.
        insert new List<Lead>{
            buildLead('EnrichedCo', 'EnrichedCo wins partnership deal | EnrichedCo hiring spree', 2),
            new Lead(LastName = 'Raw', Company = 'UnenrichedCo',
                     Status = 'Open - Not Contacted', LeadSource = 'Web')
        };

        Test.startTest();
        List<PrioritizeLeadsAction.Result> results = PrioritizeLeadsAction.prioritize(
            new List<PrioritizeLeadsAction.Request>{ new PrioritizeLeadsAction.Request() });
        Test.stopTest();

        System.assertEquals(1, results[0].totalPrioritized,
                            'Only the enriched lead should be scored');
        Lead untouched = [SELECT Priority_Verdict__c FROM Lead WHERE Company = 'UnenrichedCo'];
        System.assertEquals(null, untouched.Priority_Verdict__c);
    }
}
