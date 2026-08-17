// Creates 60 Lead records with unique Company values and LeadSource = 'Web'.
// Re-runnable: skips any Company that already exists as a Lead.
//
// The "Lead News Enrichment on Create" flow enqueues one queueable per Lead, and
// Apex allows only 50 queueables per transaction. So each run inserts at most
// BATCH_LIMIT leads -- run the script 3 times to load all 60.
Integer BATCH_LIMIT = 20;

List<List<String>> data = new List<List<String>>{
    // FirstName, LastName, Company, Title, Industry, City, State, Employees, AnnualRevenue(Mn)
    new List<String>{'Arjun','Mehta','Zentara Analytics','VP Engineering','Technology','Hyderabad','Telangana','420','65'},
    new List<String>{'Priya','Nair','Brightloom Retail','Head of Digital','Retail','Bengaluru','Karnataka','1250','180'},
    new List<String>{'Rahul','Desai','Northwind Logistics','COO','Transportation','Pune','Maharashtra','870','140'},
    new List<String>{'Sneha','Kulkarni','Vertex BioLabs','Director of R&D','Biotechnology','Hyderabad','Telangana','310','95'},
    new List<String>{'Karan','Bhatt','Solaris Energy Works','Plant Manager','Energy','Ahmedabad','Gujarat','1600','260'},
    new List<String>{'Ananya','Iyer','Cobalt Financial Group','CFO','Finance','Mumbai','Maharashtra','2400','520'},
    new List<String>{'Vikram','Rao','Halcyon Healthcare','Chief Medical Officer','Healthcare','Chennai','Tamil Nadu','3100','410'},
    new List<String>{'Meera','Joshi','Pinewood Apparel','Sourcing Head','Apparel','Tiruppur','Tamil Nadu','740','88'},
    new List<String>{'Aditya','Sharma','Quantum Edge Systems','CTO','Electronics','Noida','Uttar Pradesh','560','120'},
    new List<String>{'Divya','Menon','Greenfield Agritech','Operations Director','Agriculture','Kochi','Kerala','980','76'},
    new List<String>{'Rohan','Gupta','Ironclad Construction','Project Director','Construction','Gurugram','Haryana','2100','340'},
    new List<String>{'Ishita','Banerjee','Lumen Media House','Head of Content','Entertainment','Kolkata','West Bengal','450','54'},
    new List<String>{'Siddharth','Reddy','Falcon Aerospace Parts','Quality Head','Manufacturing','Hyderabad','Telangana','1350','210'},
    new List<String>{'Nisha','Verma','Bluepeak Insurance','Regional Manager','Insurance','Jaipur','Rajasthan','1900','290'},
    new List<String>{'Aman','Chopra','Trailhead Consulting','Managing Partner','Consulting','New Delhi','Delhi','280','62'},
    new List<String>{'Kavya','Pillai','Sunrise Hospitality Group','GM Operations','Hospitality','Goa','Goa','1450','160'},
    new List<String>{'Manish','Agarwal','Redstone Chemicals','Plant Head','Chemicals','Vadodara','Gujarat','1120','198'},
    new List<String>{'Tanvi','Shah','Nimbus Cloud Services','VP Product','Technology','Bengaluru','Karnataka','620','145'},
    new List<String>{'Harsh','Patel','Everest Steel Works','Procurement Head','Manufacturing','Surat','Gujarat','2600','470'},
    new List<String>{'Ritika','Saxena','Clearwater Environmental','Sustainability Lead','Environmental','Bhopal','Madhya Pradesh','390','48'},
    new List<String>{'Nikhil','Kapoor','Orbit Telecom Networks','Network Director','Communications','Mumbai','Maharashtra','3400','610'},
    new List<String>{'Pooja','Malhotra','Saffron Foods International','Category Head','Food & Beverage','Ludhiana','Punjab','1080','132'},
    new List<String>{'Varun','Sethi','Stonebridge Realty','Sales Director','Other','Gurugram','Haryana','520','210'},
    new List<String>{'Aarti','Deshmukh','Helix Pharma Solutions','Regulatory Head','Biotechnology','Pune','Maharashtra','860','175'},
    new List<String>{'Rajat','Sinha','Apex Learning Academy','Dean of Programs','Education','Lucknow','Uttar Pradesh','340','29'},
    new List<String>{'Shreya','Bose','Tidalwave Shipping','Fleet Manager','Transportation','Visakhapatnam','Andhra Pradesh','1750','380'},
    new List<String>{'Abhishek','Tiwari','Granite Bank Corp','Head of Lending','Banking','Mumbai','Maharashtra','5200','1200'},
    new List<String>{'Neha','Chauhan','Willow Interiors','Design Head','Construction','Chandigarh','Punjab','210','34'},
    new List<String>{'Gaurav','Naik','Photon Semiconductors','Fab Operations Head','Electronics','Hyderabad','Telangana','2200','560'},
    new List<String>{'Simran','Kaur','Meridian Travel Co','VP Sales','Hospitality','Amritsar','Punjab','480','67'},
    new List<String>{'Yash','Trivedi','Copperline Utilities','Distribution Head','Utilities','Indore','Madhya Pradesh','1900','305'},
    new List<String>{'Ayesha','Khan','Novara Fashion Labs','Brand Director','Apparel','Mumbai','Maharashtra','660','93'},
    new List<String>{'Deepak','Rathore','Titan Machinery Works','Engineering Head','Engineering','Coimbatore','Tamil Nadu','1400','245'},
    new List<String>{'Swati','Mishra','Bluegrass Nutrition','Supply Chain Head','Food & Beverage','Nagpur','Maharashtra','720','84'},
    new List<String>{'Kunal','Bajaj','Silverpine Capital','Investment Director','Finance','Bengaluru','Karnataka','190','410'},
    new List<String>{'Ramya','Krishnan','Aurora Diagnostics','Lab Director','Healthcare','Chennai','Tamil Nadu','950','122'},
    new List<String>{'Sameer','Ansari','Vanguard Defence Systems','Programme Manager','Government','New Delhi','Delhi','2800','720'},
    new List<String>{'Lakshmi','Prasad','Emerald Textiles Mills','Production Head','Apparel','Erode','Tamil Nadu','1650','156'},
    new List<String>{'Tarun','Bhardwaj','Skyline Aviation Services','Ground Ops Head','Transportation','Hyderabad','Telangana','1100','230'},
    new List<String>{'Preeti','Jain','Cascade Water Tech','Technical Director','Environmental','Nashik','Maharashtra','430','58'},
    new List<String>{'Vivek','Menon','Landmark Legal Advisors','Senior Partner','Consulting','Kochi','Kerala','150','38'},
    new List<String>{'Ekta','Goel','Polaris Retail Chain','Merchandising Head','Retail','Jaipur','Rajasthan','2900','440'},
    new List<String>{'Anil','Kumar','Ferrostar Metals','Commercial Head','Manufacturing','Raipur','Chhattisgarh','1250','215'},
    new List<String>{'Riya','Sengupta','Beacon EdTech','Growth Lead','Education','Kolkata','West Bengal','280','41'},
    new List<String>{'Mohit','Yadav','Crestview Hotels','Revenue Manager','Hospitality','Udaipur','Rajasthan','890','118'},
    new List<String>{'Sanjana','Rao','Dynamo Auto Components','Vendor Development Head','Manufacturing','Chennai','Tamil Nadu','2050','365'},
    new List<String>{'Akhil','Nambiar','Kestrel Cyber Defence','Head of Security','Technology','Bengaluru','Karnataka','370','88'},
    new List<String>{'Bhavna','Arora','Sunbeam Solar India','BD Director','Energy','Jodhpur','Rajasthan','640','129'},
    new List<String>{'Rakesh','Pandey','Monarch Packaging','Plant Director','Manufacturing','Kanpur','Uttar Pradesh','1180','167'},
    new List<String>{'Trisha','Dutta','Harbor Analytics','Data Science Lead','Technology','Pune','Maharashtra','240','52'},
    new List<String>{'Nitin','Kaul','Ridgeline Infrastructure','Bid Manager','Construction','Srinagar','Jammu and Kashmir','1520','280'},
    new List<String>{'Aparna','Ghosh','Velvet Cosmetics Co','Marketing Head','Apparel','Kolkata','West Bengal','510','71'},
    new List<String>{'Sachin','Wagh','Ironbark Mining Corp','Site Head','Energy','Bellary','Karnataka','2350','490'},
    new List<String>{'Juhi','Mathur','Clarion Broadcast Network','Programming Head','Communications','Mumbai','Maharashtra','790','143'},
    new List<String>{'Devendra','Singh','Nordic Cold Chain','Logistics Director','Transportation','Delhi','Delhi','980','161'},
    new List<String>{'Shalini','Raut','Amberleaf Organics','Founder','Agriculture','Dehradun','Uttarakhand','160','22'},
    new List<String>{'Prashant','Hegde','Vector Robotics Labs','Head of Automation','Engineering','Bengaluru','Karnataka','450','107'},
    new List<String>{'Namrata','Salvi','Lighthouse Microfinance','Credit Head','Banking','Mumbai','Maharashtra','1340','198'},
    new List<String>{'Imran','Sheikh','Zephyr Wind Power','Asset Manager','Energy','Kutch','Gujarat','870','256'},
    new List<String>{'Sunita','Reddy','Cardinal Health Devices','Sales Director','Healthcare','Hyderabad','Telangana','1720','334'}
};

List<String> statuses = new List<String>{'Open - Not Contacted', 'Working - Contacted'};
List<String> ratings   = new List<String>{'Hot', 'Warm', 'Cold'};

// Skip companies that already exist so the script can be re-run safely
Set<String> existing = new Set<String>();
for (Lead l : [SELECT Company FROM Lead WHERE Company != null]) {
    existing.add(l.Company.toLowerCase());
}

List<Lead> toInsert = new List<Lead>();
Integer i = 0;
for (List<String> row : data) {
    if (toInsert.size() >= BATCH_LIMIT) break;
    String company = row[2];
    if (existing.contains(company.toLowerCase())) { i++; continue; }

    String domain = company.toLowerCase()
        .replaceAll('[^a-z0-9 ]', '')
        .trim()
        .replaceAll('\\s+', '');
    if (domain.length() > 20) domain = domain.substring(0, 20);

    toInsert.add(new Lead(
        FirstName        = row[0],
        LastName         = row[1],
        Company          = company,
        Title            = row[3],
        Industry         = row[4],
        City             = row[5],
        State            = row[6],
        Country          = 'India',
        PostalCode       = String.valueOf(110001 + (i * 137)),
        NumberOfEmployees= Integer.valueOf(row[7]),
        AnnualRevenue    = Decimal.valueOf(row[8]) * 1000000,
        LeadSource       = 'Web',
        Status           = statuses[Math.mod(i, statuses.size())],
        Rating           = ratings[Math.mod(i, ratings.size())],
        Email            = row[0].toLowerCase() + '.' + row[1].toLowerCase() + '@' + domain + '.com',
        Phone            = '+91 ' + (90000 + Math.mod(i * 733, 9999)) + ' ' + (10000 + Math.mod(i * 271, 89999)),
        Website          = 'https://www.' + domain + '.com',
        Description      = 'Inbound web form submission. Requested a product demo and pricing details for ' + row[4] + ' use cases.'
    ));
    i++;
}

if (!toInsert.isEmpty()) {
    insert toInsert;
}
System.debug('Inserted leads: ' + toInsert.size() + ' | Skipped as duplicate company: ' + (data.size() - toInsert.size()));
