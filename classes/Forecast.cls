public class Forecast{
    
    public User[] getTestUsers() {
        return [select Id, Name, Forecast_Level__c from User where (Category__c != null or Forecast_Level__c != null) and Forecast_Level__c != 'AE'];
    }
    
    public class ForecastRowGeneric {
        public String name {get; set;}
        public String type {get; set;}
        public Boolean header {get; set;}
        public Map<String, ForecastCellGeneric> cells {get; set;}
        public ForecastRowGeneric(String name, Boolean header) {
            this.name = name;
            this.header = header;
            this.cells = new Map<String, ForecastCellGeneric>();
        }
        public void ensureUserEntryForecastRecords(Date period, User forUser, String type) {
            if (forUser.Categories__c != null && forUser.Categories__c != '')
            for (String category : forUser.Categories__c.split(';')) {
                if (!this.cells.containsKey(category) || this.cells.get(category).forecast.OwnerId != foruser.Id) {
                    ForecastCellGeneric cell = new ForecastCellGeneric();
                    cell.forecast = new Forecast__c(
                        OwnerId=forUser.Id, 
                        Category__c=category,
                        Period__c=period,
                        Type__c=type
                    );
                    cell.editable = true;
                    this.cells.put(category, cell);
                }
            }
        }
        public void setEditable(Boolean editable) {
            for (String k : cells.keySet()) {
                cells.get(k).editable = editable;
            }
        }
    }
    
    public class ForecastCellGeneric {
        public Boolean visible {get; set;}
        public Boolean editable {get; set;}
        public Forecast__c forecast {get; set;}
        public ForecastCellGeneric() {
            visible = false;
            editable = false;
        }
        public void setOrAdd(Forecast__c f) {
            if (forecast == null)
                forecast = f;
            else
                addToAmount(f.Amount__c);
        }
        public void addToAmount(Decimal amount) {
            if (forecast == null)
                forecast = new Forecast__c(Amount__c=0);
            forecast.Amount__c = 
                (forecast.Amount__c == null ? 0 : forecast.Amount__c) 
                + (amount == null ? 0 : amount);
        }
    }
    
    public Opportunity[] opportunities {get; set;}
    public ForecastRowGeneric[] genericRows {get; set;}
    public String[] headers {get; set;}
    public Map<String, String> headerKeys {get; set;}
    public Date asOfDate {get; set;}
    
    public Forecast() {
        init();
    }

    private void init() {
    	
    	// allow override of date during testing
    	try {
    	   asOfDate = Date.parse(ApexPages.currentPage().getParameters().get('asOf'));
    	} catch (Exception e) {
    		asOfDate = Date.today();
    	}
    	
        Date quarterStart = quarterStart(asOfDate);
        Date quarterEnd = quarterStart.addMonths(3).addDays(-1);
        User u = this.getUser();
        if (!Test.isRunningTest() && (u.Forecast_Level__c == null || u.Category__c == null))
            return;
        Id[] subbordinateUserIds = userIdsUnderRole(u.UserRoleId);
        String[] categories = forecastCategories();
        
        // headers start with just the categories visible
        headers = filterForecastCategoriesForUser(categories, u);
        headerKeys = new Map<String, String>();
        for (String cat : filterForecastCategoriesForUser(categories, u)) {
            headerKeys.put(cat, cat);
        }

        Forecast__c[] forecasts = [
            select Id, Type__c, Forecast_Level__c, Category__c, Amount__c, Period__c, OwnerId, Created_Date_Override__c 
            from Forecast__c 
            where (
                // return my forecast_level only if it's mine (in case sharing rules not used)
                (Forecast_Level__c = :u.Forecast_Level__c and OwnerId = :u.Id) 
                // return my subbordinate's levels that I can see
                or (Forecast_Level__c in :forecastLevelsBelow(u.Forecast_Level__c))
            )
            and Created_Date_Override__c >= :weekStart(asOfDate)
            and Created_Date_Override__c < :weekStart(asOfDate).addDays(7)
            and (OwnerId in :subbordinateUserIds or OwnerId = :u.Id)
        ];

        Forecast__c[] forecastsFromLastWeek = [
            select Id, Type__c, Forecast_Level__c, Category__c, Amount__c, Period__c, OwnerId, Created_Date_Override__c 
            from Forecast__c 
            where (
                // return my forecast_level only if it's mine (in case sharing rules not used)
                (Forecast_Level__c = :u.Forecast_Level__c and OwnerId = :u.Id) 
                // return my subbordinate's levels that I can see
                or (Forecast_Level__c in :forecastLevelsBelow(u.Forecast_Level__c))
            )
            and Created_Date_Override__c >= :weekStart(asOfDate).addDays(-7)
            and Created_Date_Override__c < :weekStart(asOfDate)
            and (OwnerId in :subbordinateUserIds or OwnerId = :u.Id)
        ];

        opportunities = [
            select Id, CloseDate, Amount, Owner.Category__c, IsClosed,
            // Opportunity_ARR2012__c is used instead of Amount at the moment
            // this may change, but this is what we should be forecasting today
            Opportunity_ARR2012__c
            from Opportunity
            where CloseDate >= :quarterStart 
            and CloseDate <= :quarterEnd.addMonths(2)
            and Deal_Type__c != 'CREDIT'
            and Opportunity_ARR2012__c > 0
        ];

        // NOTE changing a user category will change the booked amount category
        //      so we may want to use a workflow to stamp the value on the opportunity
        //      instead of querying it live 
        
        genericRows = new ForecastRowGeneric[]{};

        Integer monthsToShow = 4 + quarterMonthNumber(asOfDate);        
        for (Integer i=0; i<=4; i++) {
            Date period = quarterStart.addMonths(i);
            genericRows.add(new ForecastRowGeneric('Month - ' + monthName(period.month()), true));
            
            // show booked amounts for past and current months
            if (period <= monthStart(asOfDate)) {
                genericRows.add(bookedForecastRow(period, opportunities));
            }

            genericRows.add(forecastRow(period, forecasts, u, 'Plan', u.Forecast_Level__c));

            // allow entry on current and future months
            if (period >= monthStart(asOfDate)) {
                genericRows.add(forecastRow(period, forecasts, u, 'Call', u.Forecast_Level__c));
                genericRows[genericRows.size()-1].ensureUserEntryForecastRecords(period, u, 'Call');
                for (String level : forecastLevelsBelow(u.Forecast_Level__c))
                    genericRows.add(forecastRow(period, forecasts, u, 'Call', level));
                if (u.Forecast_Level__c != 'SVP') {
                    genericRows.add(forecastRow(period, forecasts, u, 'Upside', u.Forecast_Level__c));
                    genericRows[genericRows.size()-1].ensureUserEntryForecastRecords(period, u, 'Upside');
                }
                for (String level : forecastLevelsBelow(u.Forecast_Level__c)) {
                    genericRows.add(forecastRow(period, forecasts, u, 'Upside', level));
                    break;
                }
            }

            if (period == monthStart(asOfDate)) {
                genericRows.add(
                    subtract(
                        forecastRow(period, forecasts, u, 'Call', u.Forecast_Level__c),
                        forecastRow(period, forecastsFromLastWeek, u, 'Call', u.Forecast_Level__c)
                    )
                );
                genericRows[genericRows.size()-1].name = 'Call WoW';
                genericRows[genericRows.size()-1].setEditable(false);

                genericRows.add(
                    subtract(
                        forecastRow(period, forecasts, u, 'Call', u.Forecast_Level__c),
                        forecastRow(period, forecasts, u, 'Plan', u.Forecast_Level__c)
                    )
                );
                genericRows[genericRows.size()-1].name = 'Call B/(W) Plan';
                genericRows[genericRows.size()-1].setEditable(false);

                genericRows.add(forecastRowWithOpportunitiesCount(period, opportunities));
                genericRows[genericRows.size()-1].name = 'Monthly ' + genericRows[genericRows.size()-1].name;
                genericRows[genericRows.size()-1].setEditable(false);

                genericRows.add(forecastRowWithOpportunitiesARR(period, opportunities));
                genericRows[genericRows.size()-1].name = 'Monthly ' + genericRows[genericRows.size()-1].name;
                genericRows[genericRows.size()-1].setEditable(false);
            }

            // inject quarter total into grid after last month of quarter
            if (quarterMonthNumber(period) == 3) {
                genericRows.add(new ForecastRowGeneric('Quarter - Q'+quarterNumber(period), true));
                
                genericRows.add(bookedForecastRow(quarterStart(period), opportunities));
                genericRows[genericRows.size()-1].setEditable(false);

                genericRows.add(forecastRow(quarterStart(period), quarterDates(forecasts), u, 'Plan', u.Forecast_Level__c));
                genericRows[genericRows.size()-1].setEditable(false);

                genericRows.add(forecastRow(quarterStart(period), quarterDates(forecasts), u, 'Call', u.Forecast_Level__c));
                genericRows[genericRows.size()-1].setEditable(false);
                if (u.Forecast_Level__c != 'SVP') {
                    genericRows.add(forecastRow(quarterStart(period), quarterDates(forecasts), u, 'Upside', u.Forecast_Level__c));
                    genericRows[genericRows.size()-1].setEditable(false);
                }
                
                genericRows.add(
                    subtract(
                        forecastRow(quarterStart(period), quarterDates(forecasts), u, 'Call', u.Forecast_Level__c),
                        forecastRow(quarterStart(period), quarterDates(forecastsFromLastWeek), u, 'Call', u.Forecast_Level__c)
                    )
                );
                genericRows[genericRows.size()-1].name = 'Call WoW';
                genericRows[genericRows.size()-1].setEditable(false);
                
                genericRows.add(
                    subtract(
                        forecastRow(quarterStart(period), quarterDates(forecasts), u, 'Call', u.Forecast_Level__c),
                        forecastRow(quarterStart(period), quarterDates(forecasts), u, 'Plan', u.Forecast_Level__c)
                    )
                );
                genericRows[genericRows.size()-1].name = 'Call B/(W) Plan';
                genericRows[genericRows.size()-1].setEditable(false);

                // example for how ray can see vp's number
                genericRows.add(
                    subtract(
                        forecastRow(quarterStart(period), quarterDates(forecasts), u, 'Call', 'VP'),
                        forecastRow(quarterStart(period), quarterDates(forecasts), u, 'Plan', 'VP')
                    )
                );
                genericRows[genericRows.size()-1].name = 'VP Call B/(W) Plan';
                
                genericRows.add(forecastRowWithOpportunitiesCount(quarterStart(period), quarterDates(opportunities)));
                genericRows[genericRows.size()-1].name = 'Quarterly ' + genericRows[genericRows.size()-1].name;
                genericRows[genericRows.size()-1].setEditable(false);

                genericRows.add(forecastRowWithOpportunitiesARR(quarterStart(period), quarterDates(opportunities)));
                genericRows[genericRows.size()-1].name = 'Quarterly ' + genericRows[genericRows.size()-1].name;
                genericRows[genericRows.size()-1].setEditable(false);
            }
        }
    }
    
    // --- action methods
    
    public String expandedHeaders {get; set;}
    public String expandCategoryHeader {get; set;}
    public void expandCategory() {
        for (Integer i=0; i<headers.size(); i++) {
            if (headers[i] == expandCategoryHeader) {
                User[] users = [
                    select Id, Name 
                    from User 
                    where Category__c=:expandCategoryHeader 
                    and Forecast_Level__c = :forecastLevelsBelow(getUser().Forecast_Level__c)[0]
                    order by LastName, FirstName
                ];
                for (User u : users) {
                    String key = expandCategoryHeader + '|' + u.Id;
                    headers.add(i+1, key);
                    headerKeys.put(key, '('+u.Name+')');
                }
                expandedHeaders = expandedHeaders == null ? '' : expandedHeaders;
                expandedHeaders += '|'+expandCategoryHeader+'|';
            }
        }
    }
    
    public void collapseCategory() {
        for (Integer i=headers.size()-1; i>=0; i--) {
            if (headers[i].startsWith(expandCategoryHeader+'|')) {
                headers.remove(i);
            }
        }
        expandedHeaders = expandedHeaders.replace('|'+expandCategoryHeader+'|', '');
    }
    
    public void save() {
        Forecast__c[] toSave = new Forecast__c[]{};
        for (ForecastRowGeneric r : genericRows) {
            for (ForecastCellGeneric c : r.cells.values()) {
                if (c.editable) {
                    if (c.forecast.Created_Date_Override__c == null)
                        c.forecast.Created_Date_Override__c = asOfDate;
                    toSave.add(c.forecast);
                }
            }
        }
        if (!toSave.isEmpty()){
            upsert toSave;
        }
        init();
    }

    // --- internal methods
    
    @TestVisible
    private static void addAmountToRow(ForecastRowGeneric row, String key, Decimal amount) {
        if (key != null && amount != null) {
            if (!row.cells.containsKey(key)) {
                ForecastCellGeneric cell = new ForecastCellGeneric();
                cell.forecast = new Forecast__c(Amount__c=amount);
                row.cells.put(key, cell);
            } else {
                row.cells.get(key).forecast.Amount__c += amount;    
            }
        }
    }

    @TestVisible
    private static ForecastRowGeneric forecastRowWithOpportunitiesCount(Date period, Opportunity[] opportunities) {
        ForecastRowGeneric row = new ForecastRowGeneric('pipe #', false);
        row.type = 'type-pipeline-count';
        for (Opportunity o : opportunities) {
            if (monthStart(o.CloseDate) != monthStart(period)) continue;
            if (o.Owner.Category__c == null) continue;
            if (o.IsClosed == true) continue;

            // store the high level category
            String key = o.Owner.Category__c;
            addAmountToRow(row, key, 1);
            
            // store the category for the user (if you expand the category by user)
            key = o.Owner.Category__c + '|' + o.OwnerId;
            addAmountToRow(row, key, 1);
        }
        return row;
    }

    @TestVisible
    private static ForecastRowGeneric forecastRowWithOpportunitiesARR(Date period, Opportunity[] opportunities) {
        ForecastRowGeneric row = new ForecastRowGeneric('pipe $', false);
        row.type = 'type-pipeline-arr';
        for (Opportunity o : opportunities) {
            if (monthStart(o.CloseDate) != monthStart(period)) continue;
            if (o.Owner.Category__c == null) continue;
            if (o.IsClosed == true) continue;

            // store the high level category
            String key = o.Owner.Category__c;
            addAmountToRow(row, key, o.Opportunity_ARR2012__c);
            
            // store the category for the user (if you expand the category by user)
            key = o.Owner.Category__c + '|' + o.OwnerId;
            addAmountToRow(row, key, o.Opportunity_ARR2012__c);
        }
        return row;
    }

    @TestVisible
    private static ForecastRowGeneric bookedForecastRow(Date period, Opportunity[] opportunities) {
        ForecastRowGeneric row = new ForecastRowGeneric('Booked', false);
        row.type = 'type-booked';
        for (Opportunity o : opportunities) {
            if (monthStart(o.CloseDate) != monthStart(period)) continue;
            if (o.Owner.Category__c == null) continue;

            // store the high level category
            String key = o.Owner.Category__c;
            addAmountToRow(row, key, o.Opportunity_ARR2012__c);
            
            // store the category for the user (if you expand the category by user)
            key = o.Owner.Category__c + '|' + o.OwnerId;
            addAmountToRow(row, key, o.Opportunity_ARR2012__c);
        }
        return row;
    }

    @TestVisible
    private static ForecastRowGeneric forecastRow(Date period, Forecast__c[] forecasts, User runningUser, String type, String level) {
        Forecast__c[] filteredForecasts = new Forecast__c[]{};
        for (Forecast__c f : forecasts)
            if (f.Forecast_Level__c == level)
                filteredForecasts.add(f);
        ForecastRowGeneric row = forecastRow(period, filteredForecasts, runningUser, type);
        row.name = level + ' ' + row.name;
        return row;
    }

    @TestVisible
    private static ForecastRowGeneric forecastRow(Date period, Forecast__c[] forecasts, User runningUser, String type) {
        ForecastRowGeneric row = new ForecastRowGeneric(type, false);
        row.type = 'type-'+type.toLowerCase();
        for (Forecast__c f : forecasts) {
            if (monthStart(f.Period__c) != period || f.Type__c != type) continue;

            // store the high level aggregate amount
            ForecastCellGeneric cell = row.cells.containsKey(f.Category__c) ? row.cells.get(f.Category__c) : new ForecastCellGeneric();
            cell.setOrAdd(f);
            cell.editable = (f.OwnerId == runningUser.Id && f.Type__c != 'Plan');
            row.cells.put(f.Category__c, cell);

            // store the category for the user (if you expand the category by user)
            String key = f.Category__c + '|' + f.OwnerId;
            cell = new ForecastCellGeneric();
            cell.forecast = f;
            row.cells.put(key, cell);
        }
        return row;
    }

    // resets dates on forecast records to the start of the quarter
    // so that summing numbers to a quarter is easy
    // you should not use the results from this to save
    @TestVisible
    private static Forecast__c[] quarterDates(Forecast__c[] forecasts) {
        Forecast__c[] result = new Forecast__c[]{};
        for (Forecast__c f : forecasts) {
            f = f.clone(true, true);
            f.Period__c = quarterStart(f.Period__c);
            result.add(f);
        }
        return result;
    }

    @TestVisible
    private static Opportunity[] quarterDates(Opportunity[] opportunities) {
        Opportunity[] result = new Opportunity[]{};
        for (Opportunity o : opportunities) {
            o = o.clone(true, true);
            o.CloseDate = quarterStart(o.CloseDate);
            result.add(o);
        }
        return result;
    }

    private static String[] filterForecastCategoriesForUser(String[] forecastCategories, User u) {
        String[] result = new String[]{};
        for (String fc : forecastCategories) {
            if (u.Categories_Visible__c.contains(fc)) {
                result.add(fc);
            }
        }
        return result;
    }

    private static String[] forecastCategories() {
        Schema.DescribeFieldResult fieldResult = Forecast__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String[] result = new String[]{};
        for (Schema.PicklistEntry f : ple) {
            result.add(f.getValue());
        }
        return result;
    }

    @TestVisible
    private static ForecastRowGeneric subtract(ForecastRowGeneric a, ForecastRowGeneric b) {
        ForecastRowGeneric result = new ForecastRowGeneric(a.name, false);
        for (String k : a.cells.keySet()) {
            ForecastCellGeneric cell = new ForecastCellGeneric();
            if (a.cells.containsKey(k))
                cell.setOrAdd(a.cells.get(k).forecast);
            if (b.cells.containsKey(k))
                cell.addToAmount(b.cells.get(k).forecast.Amount__c == null ? 0 : b.cells.get(k).forecast.Amount__c * -1);
            result.cells.put(k, cell);
        }
        return result;
    }
    
    // date helpers

    @TestVisible
    private static Date weekStart(Date d) {
        Date monday = Date.newInstance(1900, 1, 1);
        return d.addDays(Math.mod(monday.daysBetween(d), 7)*-1);
    }

    @TestVisible
    private static Integer quarterNumber(Date d) {
        return (Integer)Math.ceil(d.month() / 3.0);
    }

    @TestVisible
    private static Integer quarterMonthNumber(Date d) {
        Integer mod = (Integer)Math.floor(Math.mod(d.month(), 3));
        return mod == 0 ? 3 : mod;
    }

    @TestVisible
    private static Date quarterStart(Date asOf) {
        return monthStart(
            asOf.addMonths(
                (quarterMonthNumber(asOf)-1)
                * -1
            )
        );
    }

    @TestVisible
    private static Date monthStart(Date asOf) {
        return asOf.addDays(-1 * (asOf.day()-1));
    }

    @TestVisible
    private static String monthName(Integer monthNumber) {
        return (new Map<Integer, String>{
            1 => 'Jan',
            2 => 'Feb',
            3 => 'Mar',
            4 => 'Apr',
            5 => 'May',
            6 => 'Jun',
            7 => 'Jul',
            8 => 'Aug',
            9 => 'Sep',
            10 => 'Oct',
            11 => 'Nov',
            12 => 'Dec'
        }).get(monthNumber);
    }

    // helper to get running user so we can override it in the url and switch the viewing user during development
    // and perhaps during go-live for just the ops team to view the tool as each user

    private User userCache;
    public User getUser() {
        String userId = System.currentPageReference().getParameters().get('userId');
        if (userId == null) userId = UserInfo.getUserId();
        if (userCache == null || userCache.Id != userId) {
            userCache = [select Id, Name, Category__c, Forecast_Level__c, Categories__c, Categories_Visible__c, UserRoleId, UserRole.Name, UserRole.Id, UserRole.ParentRoleId from User where Id = :userId];
            // reduce the null checks elsewhere in the program
            if(userCache.Categories__c == null) userCache.Categories__c = '';
            if(userCache.Categories_Visible__c == null) userCache.Categories_Visible__c = '';
        }
        return userCache;
    }

    @TestVisible
    private static String[] forecastLevelsBelow(String topForecastLevel) {
        Schema.DescribeFieldResult fieldResult = User.Forecast_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String[] result = new String[]{};
        for (Schema.PicklistEntry f : ple) {
            if (topForecastLevel == null)
                result.add(f.getValue());
            if (topForecastLevel == f.getValue())
                topForecastLevel = null;
        }
        return result;
    }
    
    @TestVisible
    private static Id[] userIdsUnderRole(Id roleId) {
        Set<Id> roleIds = new Set<Id>{roleId};
        roleIds.addAll(rolesUnderRole(roleId));
        Id[] userIds = new Id[]{};
        for (User u : [select Id from User where IsActive = true and UserRoleId in :roleIds and IsPortalEnabled = false])
            userIds.add(u.Id);
        return userIds;
    }

    @TestVisible
    private static Set<Id> rolesUnderRole(Id roleId) {
        Set<Id> result = new Set<Id>();
        result.add(roleId);
        while (true) {
            Boolean foundNewRole = false;
            for (UserRole child : [select Id from UserRole where ParentRoleId in :result and Id not in :result]) {
                result.add(child.Id);
                foundNewRole = true;
            }
            if (!foundNewRole)
                break;
        }
        result.remove(roleId);
        return result;
    }
}