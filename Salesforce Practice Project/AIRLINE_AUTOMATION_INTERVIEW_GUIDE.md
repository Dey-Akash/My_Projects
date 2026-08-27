# SkyLine Air Airline Management
## Salesforce Automation and Interview Guide

This guide is based on the metadata currently stored in this Salesforce DX project.

## 1. Project Snapshot

SkyLine Air is an airline-management application built on Salesforce. The main business objects are:

- `Flight__c`: flight details and base fare.
- `Booking__c`: passenger booking, seat count, flight, class, and fare values.
- `Passenger_Details__c`: passenger identity and contact information.
- `Baggage__c`: baggage linked to a booking and extra charges.
- `Payment__c`: payment linked to a booking and baggage, including final amount.
- `GST__c`: GST percentage by flying/seat class.
- `Rating_And_Feedback__c`: customer feedback and rating.

Automation inventory:

| Automation | Count | Purpose |
|---|---:|---|
| Flows | 5 | Feedback capture, fare calculation, and payment synchronization |
| Apex triggers | 3 | Booking validation, passenger validation, and GST calculation |
| Apex handler/business classes | 3 | Keeps trigger logic outside trigger files |
| Apex test classes | 1 | Tests valid passenger insert behavior |

---

## 2. Flow Inventory

### Flow 1: Feedback System Airline Management

**Type:** Screen Flow (interactive flow)

**Object:** No record-triggered start object. It is launched by a user from a Flow page, button, utility, or other entry point.

**Purpose:** Collect customer feedback and save it as a `Rating_And_Feedback__c` record.

**How it works:**

1. `Welcome_Screen` displays the airline feedback introduction.
2. `information_screen` collects:
   - Full name
   - Contact number
   - Email address
3. `rating_screen` collects:
   - Rating from 1 to 10 using a slider
   - Experience level from the `Experience_Level__c` picklist
   - Feedback type from the `Feedback_Type__c` picklist
   - Written feedback comment
4. `create_feedback_and_rating` creates one `Rating_And_Feedback__c` record.
5. The Flow maps the screen values into the record fields.
6. `Thank_You_screen` confirms submission using the entered name.

**Interview explanation:**

> I used a Screen Flow because feedback is a guided, multi-step user interaction. The Flow gathers validated inputs, creates a custom feedback record, and gives the user a confirmation screen. Dynamic choice sets keep the picklist choices synchronized with Salesforce metadata instead of hardcoding them.

**How to build it in Flow Builder:**

1. Create a new Flow and choose **Screen Flow**.
2. Add a welcome Screen.
3. Add required input components for name, phone, and email.
4. Add a second Screen with a Slider, picklist choices, and a long-text input.
5. Add a **Create Records** element for `Rating_And_Feedback__c`.
6. Map each screen resource to the matching field.
7. Add a final confirmation Screen.
8. Connect the elements in sequence, debug the Flow, save, activate, and expose it through the required Salesforce UI entry point.

---

### Flow 2: Total Fare Calculation Airline Management

**Type:** Record-Triggered Flow, before-save (Fast Field Updates)

**Object:** `Booking__c`

**Configured event:** Create

**Purpose:** Calculate the booking fare from the selected flight's base fare and the number of seats.

**How it works:**

1. The Flow starts for a new `Booking__c` record.
2. The start formula checks:
   - `ISNEW()`
   - A change to `Number_of_Seats__c`
   - A change to `Flight__c`
3. `Get_Flight` looks up the related `Flight__c` using `$Record.Flight__c`.
4. The formula calculates:

   `Flight Base Fare * Number of Seats`

5. `Calculate_Total_Fare` assigns the result to `$Record.Total_Fare__c`.
6. Because it is before-save, the field is changed in memory before the Booking is committed, without a separate Update Records element.

**Interview explanation:**

> This is a before-save record-triggered Flow because the value is derived from the Booking and related Flight before save. Before-save automation is efficient for updating fields on the same record and avoids an extra database update.

**How to build it in Flow Builder:**

1. Choose **Record-Triggered Flow**.
2. Select `Booking__c` and configure it for the required create/update events.
3. Choose **Fast Field Updates**.
4. Add entry conditions or a formula for new records and changes to flight or seat count.
5. Add **Get Records** for the related `Flight__c`.
6. Add a formula resource for base fare multiplied by seat count.
7. Add an **Assignment** to `$Record.Total_Fare__c`.
8. Debug with a Booking that has a valid Flight and seat count, then activate.

**Current metadata note:** The XML declares `recordTriggerType` as `Create`, even though the start formula checks changed fields. As currently deployed, update-time recalculation is not actually enabled. If fare must recalculate when `Flight__c` or `Number_of_Seats__c` changes, configure the Flow for **Create and Update** and retain the change formula.

---

### Flow 3: Update Payment from Booking Airline Management

**Type:** Record-Triggered Flow, after-save

**Object:** `Booking__c`

**Trigger condition:** Update when `Paying_Fare_With_Gst__c` changes

**Purpose:** Synchronize the GST-inclusive fare from a Booking to related Payment records while preserving the baggage extra charge.

**How it works:**

1. The Flow runs after a Booking update.
2. It checks `ISCHANGED($Record.Paying_Fare_With_Gst__c)`.
3. `Get_Payments` retrieves all `Payment__c` records whose `Booking__c` equals the current Booking Id.
4. A loop visits each Payment record.
5. The formula calculates:

   `BLANKVALUE(New GST Fare, 0) + BLANKVALUE(Related Baggage Extra Charge, 0)`

6. The assignment updates `Final_Paid_Amount__c` in each loop item.
7. The final Update Records element saves the entire Payment collection.

**Why after-save:** The Flow updates related Payment records, not only the triggering Booking. Related-record updates require after-save behavior.

**Interview explanation:**

> When the GST-inclusive fare changes, the Flow finds every Payment for that Booking, adds the related baggage charge, and updates the final payable amount. The loop supports multiple Payment records, and the collection is saved in one update step.

**How to build it in Flow Builder:**

1. Create a record-triggered Flow on `Booking__c`.
2. Select **A record is updated** and **Actions and Related Records**.
3. Add an entry formula using `ISCHANGED($Record.Paying_Fare_With_Gst__c)`.
4. Use **Get Records** to retrieve related Payments.
5. Loop through the Payment collection.
6. Assign the calculated amount to the loop record.
7. Add the modified loop record to an update collection if using the recommended pattern.
8. Add **Update Records** after the loop and activate.

---

### Flow 4: Update Payment from Baggage

**Type:** Record-Triggered Flow, after-save

**Object:** `Baggage__c`

**Trigger condition:** Update when `Extra_Charge__c` changes

**Purpose:** Recalculate related Payment final amounts when baggage charges change.

**How it works:**

1. The Flow runs after a Baggage update.
2. It checks `ISCHANGED($Record.Extra_Charge__c)`.
3. `Get_Payments` retrieves all Payments related through `Payment__c.Baggage__c`.
4. A loop visits every Payment.
5. The formula calculates:

   `Related Booking GST Fare + Current Baggage Extra Charge`

6. The loop assigns the result to `Final_Paid_Amount__c`.
7. The Flow updates the Payment collection after the loop.

**Interview explanation:**

> This is a related-record synchronization Flow. A baggage charge change must be reflected on Payment, so it runs after save, retrieves all impacted Payments, recalculates the amount, and persists the updates.

---

### Flow 5: Final Amount In Payment Field Airline Management

**Type:** Record-Triggered Flow, before-save (Fast Field Updates)

**Object:** `Payment__c`

**Trigger condition:** Create or update when `Booking__c` is populated

**Purpose:** Set the initial/final Payment amount from the Booking GST fare plus the Baggage extra charge.

**How it works:**

1. The Flow starts when a Payment is created or updated and has a Booking.
2. `Get_Booking` retrieves the related `Booking__c`.
3. `Get_Baggage` retrieves the related `Baggage__c` using `$Record.Baggage__c`.
4. The formula calculates:

   `BLANKVALUE(Booking GST Fare, 0) + BLANKVALUE(Baggage Extra Charge, 0)`

5. `Final_Amount_Assign` assigns the result to `$Record.Final_Paid_Amount__c`.
6. Since it is before-save, the Payment is saved with the calculated amount in the same transaction.

**Interview explanation:**

> This before-save Flow calculates the Payment amount from related Booking and Baggage data. It is useful for setting a field on the same Payment record efficiently before the record is committed.

---

## 3. Flow Design Summary

| Flow | Type | Timing | Main object | Main result |
|---|---|---|---|---|
| Feedback System | Screen Flow | User-driven | None | Creates feedback record |
| Total Fare Calculation | Record-triggered | Before save | Booking | Sets total fare |
| Update Payment from Booking | Record-triggered | After save | Booking | Updates related Payments |
| Update Payment from Baggage | Record-triggered | After save | Baggage | Updates related Payments |
| Final Amount in Payment | Record-triggered | Before save | Payment | Sets final payment amount |

### Before-save vs after-save interview answer

- **Before-save / Fast Field Updates:** Use when changing fields on the record that triggered the Flow. It is faster and avoids a second database update.
- **After-save / Actions and Related Records:** Use when creating or updating related records, sending actions, or performing work that needs the saved record Id.
- **Screen Flow:** Use when a human must enter information or follow a guided process.

---

## 4. Apex Trigger Inventory

There are **3 Apex triggers** in `force-app/main/default/triggers`.

### Trigger 1: BookingTriggerHandeler

**Object:** `Booking__c`

**Event:** `before insert`

**Handler:** `BookingTriggerHandelerClass.validetEmail(Trigger.New)`

**Purpose:** Prevents a Booking from being inserted when `Passenger_Email__c` is blank.

**Execution path:**

`Booking insert -> before-insert trigger -> handler method -> addError() if email is null -> save succeeds or transaction fails`

**Interview explanation:**

> The trigger is intentionally thin. It only checks the context and delegates validation to a handler class. The handler loops through `Trigger.New` and calls `addError()` on records without an email, which blocks the insert and displays a business validation message.

**How to build it:**

1. Create a trigger on `Booking__c` for `before insert`.
2. Pass `Trigger.New` to a handler method.
3. In the handler, loop through the list.
4. Check `Passenger_Email__c`.
5. Call `record.addError()` when the value is missing.
6. Add a test for valid and invalid records.

---

### Trigger 2: PassengerDetailsTriggerHandeler

**Object:** `Passenger_Details__c`

**Event:** `before insert`

**Handlers:**

- `PassengerTriggerHandelerClass.ValidateEmail(Trigger.New)`
- `PassengerTriggerHandelerClass.ValidateMobile(Trigger.New)`

**Purpose:** Requires both passenger email and mobile number before a new passenger record can be inserted.

**Execution path:**

`Passenger insert -> before-insert trigger -> email validation + mobile validation -> addError() for missing values -> save succeeds or fails`

The email method checks `Passenger_Email_ID__c`. The mobile method checks `Mobile_Number__c`.

**Interview explanation:**

> The trigger enforces two data-quality rules at the transaction boundary. Both methods accept a list, so the design is bulk-aware for multiple records in one DML operation. `addError()` prevents invalid records from being committed.

**How to build it:**

1. Create a `before insert` trigger on `Passenger_Details__c`.
2. Pass `Trigger.New` to separate validation methods.
3. Validate email and mobile independently.
4. Add record-level errors for missing values.
5. Test valid, email-missing, mobile-missing, and both-missing cases.

**Current test coverage:** `PassengerTriggerTest` currently verifies a valid insert and field values. It does not yet verify the error paths, so negative tests should be added.

---

### Trigger 3: gst_calculation

**Object:** `Booking__c`

**Events:** `before insert`, `before update`

**Handler:** `Cl_GSTCALCULATION_AIRLINE_MANAGEMENT.applygst(Trigger.New)`

**Purpose:** Calculates GST-inclusive fare using the GST percentage configured for the Booking's seat class.

**Execution path:**

`Booking insert/update -> GST trigger -> query GST__c rates -> build class-to-rate map -> calculate each Booking fare -> assign Paying_Fare_With_Gst__c -> save`

**Calculation:**

`Paying_Fare_With_Gst__c = Total_Fare__c + (GST percentage / 100 * Total_Fare__c)`

**Design details:**

- The handler queries `GST__c` once per transaction.
- A `Map<String, Decimal>` maps `Flying_Class__c` to `GST_VALUE__c`.
- The handler loops over `Trigger.New`, so it can process multiple Bookings.
- The calculation is done before save, so no extra update DML is required.

**Interview explanation:**

> I used a before-insert and before-update trigger because the GST-inclusive fare is a field on the Booking itself. The handler bulk-loads GST configuration into a map, then applies the correct percentage to every Booking in the trigger context.

**How to build it:**

1. Create a `before insert, before update` trigger on `Booking__c`.
2. Pass `Trigger.New` to a handler.
3. Query GST configuration once.
4. Build a map keyed by seat/flying class.
5. Calculate and assign the Booking field.
6. Add tests for each class, multiple records, and missing configuration.

**Current metadata risks to discuss professionally:**

- If no `GST__c` row matches `Seat_Class__c`, `GSTMAP.get()` returns null and the calculation can fail.
- If `Total_Fare__c` is null, the arithmetic may produce an invalid result.
- Duplicate GST rows for one class silently overwrite each other in the map.
- The trigger and handler names contain spelling inconsistencies, but that does not change runtime behavior.

Recommended hardening is to validate required inputs, provide a clear `addError()` message for missing GST configuration, and enforce uniqueness of the GST class configuration.

---

## 5. Trigger Design Pattern

The project follows a basic **one-trigger-per-object plus handler class** pattern:

1. The trigger identifies the object and event.
2. The trigger passes `Trigger.New` to a reusable class method.
3. The handler contains business logic.
4. The handler operates on lists for bulk processing.
5. Before triggers assign fields or call `addError()` without additional DML.

### Why handler classes are useful

- Keeps trigger files readable.
- Makes business logic easier to test.
- Encourages reuse.
- Makes future context support easier.
- Helps prevent putting large logic blocks directly in the trigger.

### Bulkification points

The current handlers accept `List<SObject>` and loop through the list. GST configuration is queried once outside the Booking loop, which is the correct governor-limit direction. The main improvement is to add stronger null handling and more complete tests.

---

## 6. End-to-End Business Flow

A typical airline booking calculation can be explained like this:

1. A passenger and Booking are created.
2. Passenger and Booking triggers validate required contact data.
3. The fare Flow retrieves the selected Flight and calculates total fare.
4. The GST trigger uses `GST__c` configuration to calculate the GST-inclusive fare.
5. A Payment can calculate its initial final amount from Booking and Baggage.
6. If Booking GST fare changes, the Booking payment Flow updates related Payments.
7. If Baggage extra charge changes, the Baggage payment Flow updates related Payments.
8. A customer can submit feedback through the Screen Flow.

A concise interview summary:

> The application uses before-save automation for same-record calculations and validation, after-save Flows for related Payment synchronization, a Screen Flow for guided customer feedback, and thin Apex triggers with handler classes for validation and GST calculation. The design is mostly bulk-aware because handlers accept trigger lists and the GST configuration is queried once per transaction.

---

## 7. How to Explain Testing

Current Apex test metadata includes `PassengerTriggerTest`, which inserts a valid `Passenger_Details__c` record and asserts the email and mobile values.

For production-quality coverage, add tests for:

- Booking insert with and without `Passenger_Email__c`.
- Passenger insert with missing email.
- Passenger insert with missing mobile.
- Passenger insert with both fields missing.
- GST calculation for each flying class.
- Multiple Booking records in one insert/update.
- Missing GST configuration.
- Null or zero fare and seat-count behavior.
- Flow tests for new Booking, changed Booking fare, changed Baggage charge, and Payment recalculation.

A strong interview answer is:

> I test both positive and negative paths. Positive tests confirm correct field calculations and successful inserts. Negative tests confirm that `addError()` blocks invalid data. For bulk behavior, I use multiple records in one DML operation and assert every record.

---

## 8. Important Interview Questions and Answers

### Why use Flow instead of Apex?

Use Flow for declarative, maintainable automation that administrators can understand and maintain. Use Apex when the logic needs complex calculations, reusable code, advanced error handling, or behavior not practical in Flow. This project uses both appropriately: Flows handle guided screens and record synchronization, while Apex handles validation and GST logic.

### Why use a before trigger for validation?

A before trigger can call `addError()` before the record is committed. It can also assign fields directly without an extra DML statement.

### Why use after-save Flow for Payment updates?

The Flow updates related records. After-save automation is intended for related-record actions and has the saved triggering record available.

### Is the GST handler bulkified?

Partially yes. It accepts the full trigger list, performs one GST query, builds a map, and loops through the records. It should still be hardened for missing values and duplicate configuration.

### What governor limits should you watch?

Avoid SOQL or DML inside loops, avoid recursive updates, process collections, and keep Flow loops and record updates efficient. The GST class already keeps its SOQL query outside the Booking loop.

### What would you improve first?

I would enable update recalculation in the total-fare Flow if required, add negative and bulk Apex tests, handle missing GST configuration explicitly, standardize naming, and verify that only one active automation owns each calculated field.

---

## 9. Source Locations

- Flows: `force-app/main/default/flows/`
- Triggers: `force-app/main/default/triggers/`
- Apex handlers/tests: `force-app/main/default/classes/`
- Custom objects and fields: `force-app/main/default/objects/`
- Project setup: `sfdx-project.json`
