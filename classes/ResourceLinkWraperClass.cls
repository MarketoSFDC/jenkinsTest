public class ResourceLinkWraperClass {

    public class AccumulatedWork {
        public String unit;
        public Double value;
    }

    public class Entities {
        public String id;
        public Double ResourceCalendarExceptionCount;
        public Double PercentCompleted;
        public Double CompletnessDefinition;
        public AccumulatedWork AccumulatedWork;
        public AccumulatedWork ActualOvertimeEffort;
        public AccumulatedWork ActualRegularEffort;
        public RevenueOvertimeRate RevenueOvertimeRate;
        public RevenueOvertimeRate RevenueRegularRate;
        public CreatedBy CreatedBy;
        public String CreatedOn;
        public AccumulatedWork Duration;
        public string InactiveDate;
        public String EntityType;
        public CreatedBy LastUpdatedBy;
        public String LastUpdatedOn;
        public Double Availability;
        public AccumulatedWork PendingTime;
        public AccumulatedWork RemainingEffort;
        public CreatedBy Resource;
        public CreatedBy Role;
        public CreatedBy ResourceRole;
        public CreatedBy State;
        public String LastUpdatedBySystemOn;
        public Double Units;
        public AccumulatedWork Work; 
        public CreatedBy WorkItem;
        public AccumulatedWork WorkVariance;
        public string C_clzV2_IntacctIssynced;
        public CreatedBy C_clzV2_IntacctResourceItemType;
        public Boolean C_clzV2_IntacctShouldSync;
    }

    public class Paging {
        public Integer ffrom;
        public Integer llimit;
        public Boolean hasMore;
    }

    public List<Entities> entities;
    public Paging paging;

    public class CreatedBy {
        public String id;
    }

    public class RevenueOvertimeRate {
        public String ccurrency;
        public Double value;
    }

    
    public static ResourceLinkWraperClass parse(String json) {
        return (ResourceLinkWraperClass) System.JSON.deserialize(json, ResourceLinkWraperClass.class);
    }
    
}