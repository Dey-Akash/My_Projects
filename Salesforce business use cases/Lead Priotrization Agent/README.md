# Lead Prioritization Agent

This repository contains the Salesforce metadata and Apex code for the "Lead Prioritization Agent" — a project that enriches and prioritizes lead records by using external data (e.g., news) and Salesforce automation.

## Overview

The agent includes Apex classes and flows to enrich Leads with contextual news data and to queue enrichment operations. It is implemented as Salesforce metadata (Apex classes, flows, layouts, permission sets, and a bot). The core automation runs as queueable jobs and invocable actions so it can be invoked from Flows or other Apex.

## Features

- Enrich Lead records with news-related metadata
- Queueable job to process Lead enrichment in bulk
- Flow trigger to run enrichment on create
- Permission set for API access

## Repository Structure

- `force-app/main/default/classes/` — Apex classes and tests
- `force-app/main/default/flows/` — Flow metadata
- `force-app/main/default/layouts/` — Page layouts
- `force-app/main/default/permissionsets/` — Permission sets
- `force-app/main/default/bots/` — Bot metadata (if applicable)

## Prerequisites

- Salesforce CLI (SFDX) installed and authenticated to your target org
- A Salesforce org (scratch org, sandbox, or dev org)

## Setup & Deployment

1. Clone the repository:

   git clone https://github.com/Dey-Akash/Projects.git
   cd "Salesforce business use cases/Lead Priotrization Agent"

2. Authorize your org (example using a sandbox or dev org):

   sfdx auth:web:login -a MyOrg

3. Deploy the metadata to your org:

   sfdx force:source:deploy -p force-app/main/default -u MyOrg

4. Run Apex tests (if needed):

   sfdx force:apex:test:run -u MyOrg --resultformat human --wait 10

## Usage

- The flow `Lead_News_Enrichment_on_Create` triggers enrichment when a Lead is created.
- The queueable `LeadNewsEnrichmentQueueable` processes records asynchronously and can be invoked from code or flows.

## Contributing

If you want to contribute, please fork the repo, make changes in a feature branch, and open a pull request describing your changes and rationale.

## License

This project does not include a license file. Add a LICENSE if you intend to open-source the repository.

## Contact

For questions or support, open an issue in the GitHub repository.
