# SkyLine Air — Airline Management System (Salesforce DX)

SkyLine Air is an Airline Management solution built with Salesforce (Salesforce DX + Lightning Web Components). This repository contains LWC components, custom objects, flows and automation used to manage flights, bookings, payments, and related operations.

**Project status:** Development

**Key locations:**
- **Source:** force-app/main/default
- **LWC components:** force-app/main/default/lwc
- **Custom objects & fields:** force-app/main/default/objects

## Contents

- Overview
- Features
- Tech stack
- Prerequisites
- Local setup
- Deploying to an org
- Metadata & data notes
- Contributing
- Troubleshooting

## Overview

SkyLine Air provides a lightweight airline operations suite implemented on Salesforce. It includes:

- Flight management (`Flight__c` object and related fields)
- Booking and payment flows
- LWC pages for an airline home/dashboard
- Automation for fare calculation and payment updates

## Features

- Manage flights, schedules and airlines
- Calculate total fare and update payment records using Flows
- LWC-based UI for booking and admin screens
- Apex triggers and helper classes for business logic

## Tech stack

- Salesforce Platform (Salesforce DX)
- Lightning Web Components (LWC)
- Apex (server-side logic)
- Flows (no-code automation)

## Prerequisites

- Node.js (for local tools, optional)
- Salesforce CLI (`sfdx`) — https://developer.salesforce.com/tools/sfdxcli
- An authenticated Dev Hub or scratch org (for DX workflows)

## Local setup

1. Install Salesforce CLI and authenticate:

```bash
# install/verify sfdx per platform
sfdx --version
# authenticate to an org (web-based)
sfdx auth:web:login -d -a DevHub
```

2. Push source to a scratch org (example):

```bash
# create a scratch org
sfdx force:org:create -s -f config/project-scratch-def.json -a AirlineDev
# push source and open
sfdx force:source:push
sfdx force:org:open
```

3. Retrieve or deploy to a non-scratch org:

```bash
# deploy to a sandbox or production (use caution)
sfdx force:source:deploy -p force-app/main/default -u <TARGET_ORG_ALIAS>
```

## Metadata & important files

- `force-app/main/default/lwc/airlineHomePage` — main LWC UI for the airline home page
- `force-app/main/default/objects/Flight__c` — custom object and fields (e.g., Airline_Name__c)
- `force-app/main/default/flows` — flows for fare calculation and payment updates
- `sfdx-project.json` — project configuration

## Running tests

- Apex tests:

```bash
sfdx force:apex:test:run -u <ORG_ALIAS> --resultformat human --wait 10
```

## Troubleshooting

- If LWC static resources don’t load, check that `staticresources` are deployed and referenced names match.
- For flow issues, validate the flow in the org and check the flow interview logs.
- Check Apex debug logs in the target org for trigger and class failures.

## Contributing

- Fork, create a feature branch, and open a pull request describing changes.
- Add tests for Apex logic where applicable.

## Deployment checklist

- Ensure fields and objects are included in changesets or source deploy paths.
- Run Apex tests after deployment.

## Screenshots

The `Screenshot/` folder contains sample UI and workflow images for the Airline Management app.

### Inline screenshots

![Screenshot 2026-05-24 224543](Screenshot/Screenshot%202026-05-24%20224543.png)

![Screenshot 2026-05-24 225110](Screenshot/Screenshot%202026-05-24%20225110.png)

![Screenshot 2026-05-24 225122](Screenshot/Screenshot%202026-05-24%20225122.png)

![Screenshot 2026-05-24 225134](Screenshot/Screenshot%202026-05-24%20225134.png)

![Screenshot 2026-05-24 225146](Screenshot/Screenshot%202026-05-24%20225146.png)

![Screenshot 2026-05-24 225203](Screenshot/Screenshot%202026-05-24%20225203.png)

![Screenshot 2026-05-24 225219](Screenshot/Screenshot%202026-05-24%20225219.png)

![Screenshot 2026-05-24 225229](Screenshot/Screenshot%202026-05-24%20225229.png)

![Screenshot 2026-05-24 225239](Screenshot/Screenshot%202026-05-24%20225239.png)

![Screenshot 2026-05-24 225253](Screenshot/Screenshot%202026-05-24%20225253.png)

![Screenshot 2026-05-24 225304](Screenshot/Screenshot%202026-05-24%20225304.png)

![Screenshot 2026-05-24 225315](Screenshot/Screenshot%202026-05-24%20225315.png)

![Screenshot 2026-05-24 225326](Screenshot/Screenshot%202026-05-24%20225326.png)

![Screenshot 2026-05-24 225337](Screenshot/Screenshot%202026-05-24%20225337.png)

![Screenshot 2026-05-24 225348](Screenshot/Screenshot%202026-05-24%20225348.png)

![Screenshot 2026-05-24 225359](Screenshot/Screenshot%202026-05-24%20225359.png)

![Screenshot 2026-05-24 225409](Screenshot/Screenshot%202026-05-24%20225409.png)

![Screenshot 2026-05-24 225420](Screenshot/Screenshot%202026-05-24%20225420.png)

![Screenshot 2026-05-24 225456](Screenshot/Screenshot%202026-05-24%20225456.png)

![Screenshot 2026-05-24 225612](Screenshot/Screenshot%202026-05-24%20225612.png)

![Screenshot 2026-05-24 225632](Screenshot/Screenshot%202026-05-24%20225632.png)

![Screenshot 2026-05-24 225711](Screenshot/Screenshot%202026-05-24%20225711.png)

![Screenshot 2026-05-24 225731](Screenshot/Screenshot%202026-05-24%20225731.png)

![Screenshot 2026-05-24 225813](Screenshot/Screenshot%202026-05-24%20225813.png)

![Screenshot 2026-05-24 225841](Screenshot/Screenshot%202026-05-24%20225841.png)

![Screenshot 2026-05-24 225919](Screenshot/Screenshot%202026-05-24%20225919.png)

![Screenshot 2026-05-24 225933](Screenshot/Screenshot%202026-05-24%20225933.png)

![Screenshot 2026-05-24 225950](Screenshot/Screenshot%202026-05-24%20225950.png)

## License & Contact

- License: Add your preferred license here (e.g., MIT)
- Maintainer: Add your name and contact information

---

If you'd like, I can:
- Add badges (build / tests)
- Add sample data insertion scripts
- Add a short contributor guide with SFDX examples

See the project README: [SALESFORCE_PRACTICE PROJECT/README.md](SALESFORCE_PRACTICE PROJECT/README.md)
