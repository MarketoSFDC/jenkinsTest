public class TaskWraperClass {

    public class Entities {
        public String id;
        public Decimal C_Completehours;
        public ClzCurrency ActualCost;
        public ActualEffort ActualEffort;
        public Decimal C_ActualEffortH;
        public String ActualEndDate;
        public Decimal C_ActualREV;//
        public ClzCurrency ActualRevenue;
        public String ActualStartDate;
      // public Decimal C_BacklogHours;
        public ClzCurrency  C_RevenueBacklog;
        public Boolean Billable;      
        //public Decimal C_BudgetRevenue; // giving error
        public ClzCurrency CostBalance;
        public CreatedBy CostCurrencyType;
        public ClzCurrency CostVariance;
        public CreatedBy CreatedBy;
        public String CreatedOn;
        public String Description;
        public String DueDate;
        public ActualEffort Duration;
        public ClzCurrency PlannedRevenue;
        public String ExternalID;
        public ClzCurrency FixedCost;// could create a problem in future , because the value was null
        public ClzCurrency FixedPrice;// could create a problem in future , because the value was null
        public String SYSID;
        public Decimal C_clzV2_IntacctComplete;
        public Boolean C_clzV2_IntacctShouldsyncWorkItem;
        public Boolean C_clzV2_IntacctIsfirstlevel;
        public Boolean C_clzV2_IsMilstoneIntacct;
        public String C_clzV2_IntacctIsSynced;
        public CreatedBy C_clzV2_IntacctItemTypeWorkItem;
        public CreatedBy C_clzV2_IntacctTaskStatus;
        public CreatedBy Pending;
        public String InternalId;
        public Boolean C_Investment;
        public string  EntityType; // need to see mapping
        public CreatedBy LastUpdatedBy;
        public String LastUpdatedOn;
        public CreatedBy Manager;
        public String Name;
        public String OrderID;
        public CreatedBy Parent;
        public CreatedBy Milestone;
        public CreatedBy ParentProject;
        public ActualEffort PendingTimeTrackingEffort;
        public ActualEffort C_pendingtimesubmitted;
        public String C_PMEmail;
        public CreatedBy Project;
        
        public Decimal C_ItemRate;
        public Boolean Reportable;
        public String C_SubcontractorPONumber;
        public ClzCurrency RevenueBalance;
        public CreatedBy RevenueCurrencyType;//
        public CreatedBy C_SMBTaskStatus;//
        public ActualEffort C_SOWHrs;
        public ActualEffort C_SOWHrsActHrDiff;
        public ActualEffort C_SOWWorkDiff;
        public ClzCurrency C_SOWREV;
        public ClzCurrency C_SOWREVExpRevDiff;
        public String StartDate;
        public String RecurrenceStartDate;
        public CreatedBy State;//
        public CreatedBy TrackStatus;//
        public Boolean FloatingTask;
        public ClzCurrency TotalEstimatedCost;
        public String C_UtilCalc;
        public ActualEffort Work;
        public CreatedBy C_WorkItemStatus;
        public ActualEffort WorkVariance;
        //public Decimal C_Workh;
    }

    public class Paging {
        public Decimal ffrom;
        public Decimal llimit;
        public Boolean hasMore;
    }

    public List<Entities> entities;
    public Paging paging;

    public class CreatedBy {
        public String id;
    }

    public class ActualEffort {
        public String unit;
        public Decimal value;
    }
    
    public class ClzCurrency {
        public String ccurrency;
        public Decimal value;
    }
    
    public static TaskWraperClass parse(String json) {
        return (TaskWraperClass ) System.JSON.deserialize(json, TaskWraperClass.class);
    }
    
}