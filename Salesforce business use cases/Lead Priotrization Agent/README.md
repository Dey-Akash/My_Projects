# Lead Prioritization Agent

This project provides Salesforce metadata and Apex code to enrich, score, and prioritize Lead records by combining internal Lead data with external context (news, signals). It is intended to help sales teams focus on the highest-impact leads.

**Contents of this README**
- **Use Case**: business problem and success criteria
- **Solution Approach**: high-level design and components
- **Architecture & Data Flow**: how records move through the system
- **Files & Components**: where to find key code and metadata
- **Setup & Deployment**: step-by-step commands
- **Testing & Validation**: how to run tests and verify behavior
- **Troubleshooting & Notes**: common issues and next steps
- **What I changed**: actions I performed for this repository

## Use Case

Problem: Sales teams receive many leads and lack context to prioritize outreach. They need an automated way to enrich leads with external signals (e.g., company news, funding events) and compute a priority score so reps can focus effort where it matters.

Success criteria:
- Enrich new Leads with external signals shortly after creation
- Calculate a priority score and expose it on the Lead record
- Ensure enrichment runs reliably at scale (bulk-safe)

## Solution Approach

- Trigger enrichment on Lead creation via a Flow (`Lead_News_Enrichment_on_Create`).
- Use an invocable Apex action (`LeadResearchContextAction` / `LeadNewsEnrichmentInvocable`) to prepare the work and enqueue a queueable job (`LeadNewsEnrichmentQueueable`) for asynchronous processing.
- Queueable job calls an external API or integration (using Named Credentials or a platform event) to fetch news/context and writes back enrichment fields to Lead records.
- Tests cover the queueable and invocable logic to keep deployment safe.

## Architecture & Data Flow

1. Lead created in Salesforce.
2. Flow `Lead_News_Enrichment_on_Create` calls the invocable action.
3. Invocable action enqueues `LeadNewsEnrichmentQueueable` with batched Lead IDs.
4. Queueable processes Leads, calls external API (via Named Credential), parses JSON responses, and updates Lead fields (e.g., `News_Summary__c`, `Priority_Score__c`).
5. Optionally fire platform events or update Chatter on high-priority leads.

Notes:
- Use Named Credentials and authenticated endpoints for secure external calls.
- Keep heap and CPU usage low in queueable; process in batches of ~50.

## Files & Components

- **Apex classes**: `force-app/main/default/classes/`
  - `LeadNewsEnrichmentInvocable.cls` — invocable wrapper for Flow
  - `LeadNewsEnrichmentQueueable.cls` — queueable worker that calls external services and updates Leads
  - `LeadNewsEnrichmentQueueableTest.cls` — unit tests for queueable logic
  - `LeadResearchContextAction.cls` — helper/invocable logic
- **Flow**: `force-app/main/default/flows/Lead_News_Enrichment_on_Create.flow-meta.xml` — Flow that runs on Lead creation
- **Layouts**: `force-app/main/default/layouts/Lead-Lead Layout.layout-meta.xml` — includes enrichment fields on Lead page
- **Permission Set**: `force-app/main/default/permissionsets/NewsAPI_Access.permissionset-meta.xml` — grants any remote site or Named Credential access and necessary Apex permissions
- **Bot** (optional): `force-app/main/default/bots/Lead_Research_Assistant/` — metadata for any conversational assistant

## Configuration

- Named Credential: configure a Named Credential for the external news API and give the integration user access.
- Custom fields: ensure the Lead object has fields for `News_Summary__c`, `Priority_Score__c`, and any other enrichment fields referenced by Apex/Flow.
- Permission set: assign `NewsAPI_Access` to users who will see the enrichment fields and run the bot.

## Setup & Deployment

1. Clone the repo and change into the project folder:

   git clone https://github.com/Dey-Akash/Projects.git
   cd "Salesforce business use cases/Lead Priotrization Agent"

2. Authorize your org (web login):

   sfdx auth:web:login -a MyOrg

3. Deploy metadata to your org:

   sfdx force:source:deploy -p force-app/main/default -u MyOrg

4. Run Apex tests:

   sfdx force:apex:test:run -u MyOrg --resultformat human --wait 10

5. Configure Named Credential and assign permission set in the target org.

## Testing & Validation

- Run unit tests included in `force-app/main/default/classes/`.
- In a sandbox or scratch org, create a Lead and verify:
  - The Flow invoked the invocable action
  - Queueable job ran (check Apex Jobs)
  - Lead fields `News_Summary__c` and `Priority_Score__c` are populated

## Troubleshooting & Best Practices

- If queueable fails with callout errors, verify Named Credential and remote endpoint.
- Keep logs in `System.debug` for the queueable during development, then remove or reduce verbosity.
- Use small batch sizes to avoid CPU/time limits when processing many Leads.

## Future Improvements

- Add exponential backoff and retry for transient API failures.
- Add a scheduler or bulk re-enrichment job for older Leads.
- Add more data sources and ML-driven scoring for better prioritization.

## What I did (actions performed here)

- Created `README.md` in `Salesforce business use cases/Lead Priotrization Agent/` describing the use case, design, deployment, and testing steps.
- Committed and pushed the file to `origin/main`.

## Contact

Open an issue in the GitHub repository for questions or to request changes.

