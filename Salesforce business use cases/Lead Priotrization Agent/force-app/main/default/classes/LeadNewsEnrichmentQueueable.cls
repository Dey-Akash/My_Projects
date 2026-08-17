public class LeadNewsEnrichmentQueueable implements Queueable, Database.AllowsCallouts
{
    // Each lead costs one callout. Apex allows 100 callouts per transaction, and
    // Developer Edition orgs cap chained queueable depth at 5, so 20 leads per job
    // lets a single insert of up to 100 leads finish without hitting either limit.
    @TestVisible
    private static final Integer CHUNK_SIZE = 20;

    private List<Id> leadIds;
    private List<String> companyNames;

    // Single-lead entry point, kept for ad-hoc scripts and existing callers.
    public LeadNewsEnrichmentQueueable(Id leadId, String companyName)
    {
        this(new List<Id>{ leadId }, new List<String>{ companyName });
    }

    public LeadNewsEnrichmentQueueable(List<Id> leadIds, List<String> companyNames)
    {
        this.leadIds = leadIds;
        this.companyNames = companyNames;
    }

    public void execute(QueueableContext context)
    {
        List<Lead> toUpdate = new List<Lead>();
        List<Id> remainingIds = new List<Id>();
        List<String> remainingNames = new List<String>();

        for (Integer i = 0; i < leadIds.size(); i++)
        {
            if (i < CHUNK_SIZE)
            {
                toUpdate.add(enrichOne(leadIds[i], companyNames[i]));
            }
            else
            {
                remainingIds.add(leadIds[i]);
                remainingNames.add(companyNames[i]);
            }
        }

        // Partial save: a lead deleted between enqueue and execute must not throw away
        // the enrichment for every other lead in the chunk.
        if (!toUpdate.isEmpty()) Database.update(toUpdate, false);

        // Queueable jobs cannot be chained from inside a test context.
        if (!remainingIds.isEmpty() && !Test.isRunningTest())
        {
            System.enqueueJob(new LeadNewsEnrichmentQueueable(remainingIds, remainingNames));
        }
    }

    // Performs the callout for one lead and returns the record to update.
    // Never throws: a failure is recorded on the lead so it can be retried later.
    private Lead enrichOne(Id leadId, String companyName)
    {
        Lead ld = new Lead(Id = leadId);
        try
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:NewsAPI/v2/everything?q='
                + EncodingUtil.urlEncode(companyName, 'UTF-8')
                + '&sortBy=publishedAt&pageSize=5&language=en');
            req.setMethod('GET');
            req.setTimeout(60000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200)
            {
                Map<String, Object> body =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> articles = (List<Object>) body.get('articles');
                if (articles == null) articles = new List<Object>();

                List<String> headlines = new List<String>();
                Date latest = null;

                for (Object a : articles)
                {
                    Map<String, Object> article = (Map<String, Object>) a;
                    String title = (String) article.get('title');
                    if (title != null) headlines.add(title);
                    String publishedAt = (String) article.get('publishedAt');
                    if (publishedAt != null && publishedAt.length() >= 10)
                    {
                        Date d = Date.valueOf(publishedAt.substring(0, 10));
                        if (latest == null || d > latest) latest = d;
                    }
                }

                // News_Summary__c holds 500 characters, not 255.
                ld.News_Summary__c = headlines.isEmpty()
                    ? 'No recent news found'
                    : String.join(headlines, ' | ').left(500);
                ld.News_Mention_Count__c = articles.size();
                ld.Last_News_Date__c = latest;
            }
            else
            {
                ld.News_Summary__c = 'Enrichment failed: HTTP ' + res.getStatusCode();
                ld.News_Mention_Count__c = 0;
            }
        }
        catch (Exception e)
        {
            ld.News_Summary__c = ('Enrichment error: ' + e.getMessage()).left(500);
            ld.News_Mention_Count__c = 0;
        }
        return ld;
    }
}
