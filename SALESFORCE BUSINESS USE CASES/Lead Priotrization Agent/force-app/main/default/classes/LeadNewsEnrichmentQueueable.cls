public class LeadNewsEnrichmentQueueable implements Queueable, Database.AllowsCallouts
{
    private Id leadId;
    private String companyName;

    public LeadNewsEnrichmentQueueable(Id leadId, String companyName) 
    {
        this.leadId = leadId;
        this.companyName = companyName;
    }

    public void execute(QueueableContext context) 
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

                ld.News_Summary__c = headlines.isEmpty()
                    ? 'No recent news found'
                    : String.join(headlines, ' | ').left(255);
                ld.News_Mention_Count__c = articles.size();
                ld.Last_News_Date__c = latest;
            } else 
            {
                ld.News_Summary__c = 'Enrichment failed: HTTP ' + res.getStatusCode();
                ld.News_Mention_Count__c = 0;
            }
        } catch (Exception e) 
        {
            ld.News_Summary__c = ('Enrichment error: ' + e.getMessage()).left(255);
            ld.News_Mention_Count__c = 0;
        }
        update ld;
    }
}

