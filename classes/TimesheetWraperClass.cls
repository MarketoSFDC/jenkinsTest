public class TimesheetWraperClass {
        public class Entities {
        public String id;
        public String ApprovalDate;
        public ApprovedBy ApprovedBy;
        public ApprovedBy AssignedApprover;
        public currencyNval BillingRate;
        public String Comment;
        public currencyNval Cost;
        public currencyNval CostRate;
        public ApprovedBy CreatedBy;
        public string CreatedOn;
        public Duration Duration;
        
        public Boolean C_clzV2_IntacctBillable;
        public Decimal C_clzV2_IncacctDurationInHours;
        public string C_clzV2_IntacctIsSynced;
        public ApprovedBy C_clzV2_IntacctProject;  
        public string C_clzV2_IntacctItem;
        public Decimal C_clzV2_IntacctLineNumber;
        public String EntityType;
        public ApprovedBy LastUpdatedBy;
        public string LastUpdatedOn;
        public ApprovedBy Project;
        public Boolean RegularHours;
        public ApprovedBy ReportedBy;
        public String ReportedDate;
        public ApprovedBy State;
        public ApprovedBy WorkItem;
       }

    public class Paging {
        public Integer ffrom;
        public Integer llimit;
        public Boolean hasMore;
    }

    public class C_DurationNumeric {
        public Boolean isError;
    }

    public List<Entities> entities;
    public Paging paging;

    public class Duration {
        public String unit;
        public Decimal value;
    }

    public class ApprovedBy {
        public String id;
    }
    
    public class currencyNval {
        public String yCurrency;
        public Decimal value;
    }

    
    public static TimesheetWraperClass parse(String json) {
        return (TimesheetWraperClass) System.JSON.deserialize(json, TimesheetWraperClass.class);
    }
    
}