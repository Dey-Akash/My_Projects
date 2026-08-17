// Diagnostic: how many of today's leads actually got news, and is the NewsAPI quota alive?
List<Lead> leads = [SELECT Company, News_Summary__c, News_Mention_Count__c
                    FROM Lead WHERE CreatedDate = TODAY ORDER BY Company];

Integer noNews = 0, withNews = 0, failed = 0, blank = 0;
for (Lead l : leads) {
    if (l.News_Summary__c == null) blank++;
    else if (l.News_Summary__c.startsWith('No recent news')) noNews++;
    else if (l.News_Summary__c.startsWith('Enrichment')) failed++;
    else withNews++;
}
System.debug('TOTAL=' + leads.size() + ' withNews=' + withNews + ' noNews=' + noNews
             + ' failed=' + failed + ' blank=' + blank);

// Show a few failures verbatim (surfaces HTTP 429 / quota errors)
Integer shown = 0;
for (Lead l : leads) {
    if (l.News_Summary__c != null && l.News_Summary__c.startsWith('Enrichment') && shown < 3) {
        System.debug('FAILSAMPLE ' + l.Company + ' >> ' + l.News_Summary__c);
        shown++;
    }
}

// One live callout with a real company name to confirm the API key + quota still work
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:NewsAPI/v2/everything?q=Infosys&sortBy=publishedAt&pageSize=5&language=en');
req.setMethod('GET');
req.setTimeout(60000);
HttpResponse res = new Http().send(req);
System.debug('QUOTA_TEST status=' + res.getStatusCode());
System.debug('QUOTA_TEST body=' + res.getBody().left(400));
