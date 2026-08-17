// Replaces the invented company names on the 60 seeded leads with genuine, newsworthy
// companies, and realigns Industry / Website / Email / size to match each real company.
// Matched on the OLD company name, so this runs exactly once (re-running is a no-op).
//
// Columns: oldCompany, newCompany, industry, domain, employees, revenueMillions, city, state

List<List<String>> mapping = new List<List<String>>{
    new List<String>{'Zentara Analytics','Infosys','Technology','infosys.com','343000','18600','Bengaluru','Karnataka'},
    new List<String>{'Brightloom Retail','Avenue Supermarts','Retail','dmartindia.com','13000','6500','Mumbai','Maharashtra'},
    new List<String>{'Northwind Logistics','Delhivery','Transportation','delhivery.com','57000','1050','Gurugram','Haryana'},
    new List<String>{'Vertex BioLabs','Biocon','Biotechnology','biocon.com','16000','1800','Bengaluru','Karnataka'},
    new List<String>{'Solaris Energy Works','Adani Green Energy','Energy','adanigreenenergy.com','4200','1200','Ahmedabad','Gujarat'},
    new List<String>{'Cobalt Financial Group','Bajaj Finance','Finance','bajajfinserv.in','58000','6800','Pune','Maharashtra'},
    new List<String>{'Halcyon Healthcare','Apollo Hospitals','Healthcare','apollohospitals.com','70000','2400','Chennai','Tamil Nadu'},
    new List<String>{'Pinewood Apparel','Page Industries','Apparel','jockeyindia.com','24000','580','Bengaluru','Karnataka'},
    new List<String>{'Quantum Edge Systems','Dixon Technologies','Electronics','dixoninfo.com','26000','2900','Noida','Uttar Pradesh'},
    new List<String>{'Greenfield Agritech','UPL Limited','Agriculture','upl-ltd.com','12000','5400','Mumbai','Maharashtra'},
    new List<String>{'Ironclad Construction','Larsen and Toubro','Construction','larsentoubro.com','400000','27000','Mumbai','Maharashtra'},
    new List<String>{'Lumen Media House','Zee Entertainment Enterprises','Entertainment','zee.com','3500','1000','Mumbai','Maharashtra'},
    new List<String>{'Falcon Aerospace Parts','Hindustan Aeronautics','Manufacturing','hal-india.co.in','21000','3600','Bengaluru','Karnataka'},
    new List<String>{'Bluepeak Insurance','HDFC Life Insurance','Insurance','hdfclife.com','26000','7300','Mumbai','Maharashtra'},
    new List<String>{'Trailhead Consulting','Accenture','Consulting','accenture.com','790000','64900','Bengaluru','Karnataka'},
    new List<String>{'Sunrise Hospitality Group','Indian Hotels Company','Hospitality','tajhotels.com','33000','850','Mumbai','Maharashtra'},
    new List<String>{'Redstone Chemicals','Asian Paints','Chemicals','asianpaints.com','8500','4400','Mumbai','Maharashtra'},
    new List<String>{'Nimbus Cloud Services','Wipro','Technology','wipro.com','234000','10800','Bengaluru','Karnataka'},
    new List<String>{'Everest Steel Works','Tata Steel','Manufacturing','tatasteel.com','78000','26500','Jamshedpur','Jharkhand'},
    new List<String>{'Clearwater Environmental','Va Tech Wabag','Environmental','wabag.com','2100','380','Chennai','Tamil Nadu'},
    new List<String>{'Orbit Telecom Networks','Bharti Airtel','Telecommunications','airtel.in','27000','17800','New Delhi','Delhi'},
    new List<String>{'Saffron Foods International','Britannia Industries','Food & Beverage','britannia.co.in','5000','2100','Bengaluru','Karnataka'},
    new List<String>{'Stonebridge Realty','DLF','Construction','dlf.in','2200','800','Gurugram','Haryana'},
    new List<String>{'Helix Pharma Solutions','Sun Pharmaceutical Industries','Biotechnology','sunpharma.com','43000','5800','Mumbai','Maharashtra'},
    new List<String>{'Apex Learning Academy','NIIT Limited','Education','niit.com','2500','45','Gurugram','Haryana'},
    new List<String>{'Tidalwave Shipping','Adani Ports and Special Economic Zone','Shipping','adaniports.com','5000','3200','Ahmedabad','Gujarat'},
    new List<String>{'Granite Bank Corp','HDFC Bank','Banking','hdfcbank.com','213000','33000','Mumbai','Maharashtra'},
    new List<String>{'Willow Interiors','Godrej Properties','Construction','godrejproperties.com','1600','550','Mumbai','Maharashtra'},
    new List<String>{'Photon Semiconductors','Samsung India Electronics','Electronics','samsung.com','20000','12500','Gurugram','Haryana'},
    new List<String>{'Meridian Travel Co','MakeMyTrip','Hospitality','makemytrip.com','4500','780','Gurugram','Haryana'},
    new List<String>{'Copperline Utilities','NTPC','Utilities','ntpc.co.in','17000','21000','New Delhi','Delhi'},
    new List<String>{'Novara Fashion Labs','Aditya Birla Fashion and Retail','Apparel','abfrl.com','30000','1700','Mumbai','Maharashtra'},
    new List<String>{'Titan Machinery Works','Thermax','Engineering','thermaxglobal.com','4600','1150','Pune','Maharashtra'},
    new List<String>{'Bluegrass Nutrition','Nestle India','Food & Beverage','nestle.in','8000','2600','Gurugram','Haryana'},
    new List<String>{'Silverpine Capital','HDFC Asset Management Company','Finance','hdfcfund.com','1400','430','Mumbai','Maharashtra'},
    new List<String>{'Aurora Diagnostics','Dr Lal PathLabs','Healthcare','lalpathlabs.com','6500','290','New Delhi','Delhi'},
    new List<String>{'Vanguard Defence Systems','Bharat Electronics','Government','bel-india.in','9500','2600','Bengaluru','Karnataka'},
    new List<String>{'Emerald Textiles Mills','Raymond','Apparel','raymond.in','9000','1100','Mumbai','Maharashtra'},
    new List<String>{'Skyline Aviation Services','InterGlobe Aviation','Transportation','goindigo.in','36000','8600','Gurugram','Haryana'},
    new List<String>{'Cascade Water Tech','Ion Exchange India','Environmental','ionexchangeglobal.com','2400','300','Mumbai','Maharashtra'},
    new List<String>{'Landmark Legal Advisors','Deloitte','Consulting','deloitte.com','460000','67000','Hyderabad','Telangana'},
    new List<String>{'Polaris Retail Chain','Trent Limited','Retail','trentlimited.com','8000','1900','Mumbai','Maharashtra'},
    new List<String>{'Ferrostar Metals','JSW Steel','Manufacturing','jsw.in','15000','20000','Mumbai','Maharashtra'},
    new List<String>{'Beacon EdTech','PhysicsWallah','Education','pw.live','12000','250','Noida','Uttar Pradesh'},
    new List<String>{'Crestview Hotels','Lemon Tree Hotels','Hospitality','lemontreehotels.com','6000','140','New Delhi','Delhi'},
    new List<String>{'Dynamo Auto Components','Maruti Suzuki India','Manufacturing','marutisuzuki.com','40000','17500','Gurugram','Haryana'},
    new List<String>{'Kestrel Cyber Defence','Tata Consultancy Services','Technology','tcs.com','600000','29000','Mumbai','Maharashtra'},
    new List<String>{'Sunbeam Solar India','Suzlon Energy','Energy','suzlon.com','6000','800','Pune','Maharashtra'},
    new List<String>{'Monarch Packaging','ITC Limited','Manufacturing','itcportal.com','25000','9500','Kolkata','West Bengal'},
    new List<String>{'Harbor Analytics','HCLTech','Technology','hcltech.com','223000','13800','Noida','Uttar Pradesh'},
    new List<String>{'Ridgeline Infrastructure','UltraTech Cement','Construction','ultratechcement.com','23000','8100','Mumbai','Maharashtra'},
    new List<String>{'Velvet Cosmetics Co','Godrej Consumer Products','Other','godrejcp.com','10000','1800','Mumbai','Maharashtra'},
    new List<String>{'Ironbark Mining Corp','Coal India','Energy','coalindia.in','240000','17000','Kolkata','West Bengal'},
    new List<String>{'Clarion Broadcast Network','Sun TV Network','Media','suntv.in','3000','480','Chennai','Tamil Nadu'},
    new List<String>{'Nordic Cold Chain','Blue Dart Express','Transportation','bluedart.com','13000','660','Chennai','Tamil Nadu'},
    new List<String>{'Amberleaf Organics','Godrej Agrovet','Agriculture','godrejagrovet.com','3200','1100','Mumbai','Maharashtra'},
    new List<String>{'Vector Robotics Labs','ABB India','Engineering','abb.com','3400','1400','Bengaluru','Karnataka'},
    new List<String>{'Lighthouse Microfinance','Bandhan Bank','Banking','bandhanbank.com','75000','2400','Kolkata','West Bengal'},
    new List<String>{'Zephyr Wind Power','Tata Power','Utilities','tatapower.com','5000','7300','Mumbai','Maharashtra'},
    new List<String>{'Cardinal Health Devices','Cipla','Healthcare','cipla.com','26000','3200','Mumbai','Maharashtra'}
};

// Index the mapping by old company name
Map<String, List<String>> byOld = new Map<String, List<String>>();
for (List<String> row : mapping) byOld.put(row[0].toLowerCase(), row);

List<Lead> leads = [SELECT Id, FirstName, LastName, Company, Industry
                    FROM Lead WHERE CreatedDate = TODAY];

List<Lead> toUpdate = new List<Lead>();
for (Lead l : leads) {
    List<String> row = byOld.get(l.Company == null ? '' : l.Company.toLowerCase());
    if (row == null) continue;

    toUpdate.add(new Lead(
        Id                = l.Id,
        Company           = row[1],
        Industry          = row[2],
        Website           = 'https://www.' + row[3],
        Email             = l.FirstName.toLowerCase() + '.' + l.LastName.toLowerCase() + '@' + row[3],
        NumberOfEmployees = Integer.valueOf(row[4]),
        AnnualRevenue     = Decimal.valueOf(row[5]) * 1000000,
        City              = row[6],
        State             = row[7],
        Country           = 'India',
        LeadSource        = 'Web',
        Description       = 'Inbound web form submission from ' + row[1]
                            + '. Requested a product demo and pricing for ' + row[2] + ' use cases.'
    ));
}

update toUpdate;
System.debug('REBRANDED=' + toUpdate.size() + ' of ' + leads.size());
