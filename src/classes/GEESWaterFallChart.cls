// Testing autorabit versioing Control

public with sharing class GEESWaterFallChart {
 
    public String strViewBy { get; set; }
    public String strTimeFrame { get; set; }
    public String strSubRegion { get; set; }
    public Map<String, Date> map_startDate = new Map<String, Date>();
    public Map<String, Date> map_endDate = new Map<String, Date>();
    public Map<String, Date> map_next_fin_startDate = new Map<String, Date>();
    public Map<String, Date> map_next_fin_endDate = new Map<String, Date>();
    public List<ChartWrapperClass> list_chartWrapperClass { get; set; }
    public Map<String, String> map_region = new Map<String, String>();
    public Map<String, String> map_region_name = new Map<String, String>();
    public Map<String, String> map_sub_region = new Map<String, String>();
    public Map<String, Double> map_won = new Map<String, Double>();
    public Map<String, Double> map_commit = new Map<String, Double>();
    public Map<String, Double> map_current = new Map<String, Double>();
    public Map<String, Double> map_next = new Map<String, Double>();
    public Map<String, Double> map_chartAmount = new Map<String, Double>();
    public Map<String, Integer> map_chartIntegerAmount = new Map<String, Integer>();
    public Integer totalIntegerChartAmt = 0;
    public static final String IST_QUARTER_TIME_FRAME = '1Q';
    public static final String IIND_QUARTER_TIME_FRAME = '2Q';    
    public static final String IIIRD_QUARTER_TIME_FRAME = '3Q';    
    public static final String IVTH_QUARTER_TIME_FRAME = '4Q';    
    public static final String TOTAL_YEAR_TIME_FRAME = 'Total Year';  
    public List<String> list_region = new List<String>();  
    public Integer currentYear;
    public Date currentDate;
    
    public Double totalChartAmt = 0.0;
    
    public List<SelectOption> getSubRegions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--Select--','--Select--'));
        if (strViewBy == null || strViewBy == '' || strViewBy == '--Select--') 
            return options;
        for (GE_ES_Sub_Region__c oGE_ES_Sub_Region : [Select 
                                                          Id, 
                                                          Name 
                                                      From 
                                                          GE_ES_Sub_Region__c 
                                                      Where 
                                                          GE_HQ_Sales_Region__c =: strViewBy   
                                                      Order By Name]) {
             options.add(new SelectOption(oGE_ES_Sub_Region.Id,oGE_ES_Sub_Region.Name)); 
             map_sub_region.put(oGE_ES_Sub_Region.Id,oGE_ES_Sub_Region.Name);                                              
        }    
        return options;    
    }    
    public void setSubRegions() {
        getSubRegions();
    }
    public List<SelectOption> getViewBy() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--Select--','--Select--'));
        options.add(new SelectOption('Total ES','Total ES'));
        for (GE_ES_Sales_Region__c oGE_ES_Sales_Region : [Select 
                                                                Id, 
                                                                Name 
                                                           From 
                                                               GE_ES_Sales_Region__c 
                                                           Where 
                                                               GE_ES_P_L__c = 'ES'    
                                                           Order By Name]) {
             options.add(new SelectOption(oGE_ES_Sales_Region.Id,oGE_ES_Sales_Region.Name)); 
             list_region.add(oGE_ES_Sales_Region.Name);
             map_region.put(oGE_ES_Sales_Region.Name, oGE_ES_Sales_Region.Id);  
             map_region_name.put(oGE_ES_Sales_Region.Id, oGE_ES_Sales_Region.Name);                                            
        }                                                           
        return options;
    }
  
    public List<SelectOption> getTimeFrame() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--Select--','--Select--'));
        options.add(new SelectOption('1Q','1Q'));
        options.add(new SelectOption('2Q','2Q'));
        options.add(new SelectOption('3Q','3Q'));
        options.add(new SelectOption('4Q','4Q'));
        options.add(new SelectOption('Total Year','Total Year'));

        return options;
    }
    
    public class ChartWrapperClass {
        public String region { get; set; }
        public String pl { get; set; }
        public String customer { get; set; }
        public String stage { get; set; }
        public Double amount { get; set; }
        public String state { get; set; } 
        public String opportunityName { get; set; } 
        public String opportunityDescription { get; set; } 
        public String accountId { get; set; } 
        public String opportunityId { get; set; } 
    }
    public void getCurrentQuarter() {
        for (String key : map_startDate.keySet()) {
            if (Date.today() >= map_startDate.get(key)) {
                System.debug('Current Quarter ' + key); 
            }
        }
    }
    public Date getDate(String year, String month, String day, String hour, String minute, String second) {
        String stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
        return date.valueOf(stringDate);
    } 
    // Need to change the hard coded values
    public void getTimeFrameInfo() {
        currentDate = date.today();
        currentYear = currentDate.year();
        for (Period oPeriod : [Select
                                 Id,
                                 EndDate,
                                 FiscalYearSettingsId,
                                 IsForecastPeriod,
                                 Number,
                                 PeriodLabel,
                                 QuarterLabel,
                                 StartDate,
                                 Type
                               From
                                 Period
                               Where
                                 Type='Quarter'
                               And
                                 StartDate >: getDate(String.valueOf(currentYear),'01','1','00','00','00')
                               And 
                                 EndDate <=: getDate(String.valueOf((currentYear+1)),'01','31','12','00','00')
                               Order By Number asc])
        {
                map_startDate.put(String.valueOf(oPeriod.Number) + 'Q', oPeriod.StartDate);
                map_endDate.put(String.valueOf(oPeriod.Number) + 'Q', oPeriod.EndDate);
        }                                   
    }
    public void getTimeFrameInfoForNextYear() {
        currentDate = date.today();
        currentYear = currentDate.year();
        for (Period oPeriod : [Select
                                 Id,
                                 EndDate,
                                 FiscalYearSettingsId,
                                 IsForecastPeriod,
                                 Number,
                                 PeriodLabel,
                                 QuarterLabel,
                                 StartDate,
                                 Type
                               From
                                 Period
                               Where
                                 Type='Quarter'
                               And
                                 StartDate >: getDate(String.valueOf((currentYear+1)),'01','1','00','00','00')
                               And 
                                 EndDate <=: getDate(String.valueOf((currentYear+2)),'01','31','00','00','00')
                               Order By Number asc])
        {
                map_next_fin_startDate.put(String.valueOf(oPeriod.Number) + 'Q', oPeriod.StartDate);
                map_next_fin_endDate.put(String.valueOf(oPeriod.Number) + 'Q', oPeriod.EndDate);
        }                                   
    }
    public void getChartData(String viewBy, Date startDate, Date endDate) {
        System.debug('This is testing nad v'+ map_region.get(viewBy));
        String sSOQL = ' Select '
                       + ' Id, convertCurrency(Totalprice), Opportunity.Name, Opportunity.Description, '
                       + ' OpportunityId, Opportunity.AccountId, '
                       + ' Opportunity.StageName, Opportunity.Account.Name, Opportunity.Sales_Region__c, '
                       + ' Opportunity.GE_ES_Ship_To_Sub_Region__c, ' 
                       + ' Opportunity.Account.ShippingState, GE_ES_P_L__c, GE_PW_Primary__c, convertCurrency(Opportunity.Pipeline_Amount_ge_og__c) From OpportunityLineItem '
                       + ' Where GE_ES_Primary_Quote__c = true '
                       + ' And Opportunity.Pipeline_Amount_ge_og__c > 10000000.0 '
                       + ' And Opportunity.CloseDate >= : startDate And Opportunity.CloseDate <= : endDate ';
            System.debug(strSubRegion + 'This is testing nad ' + viewBy);

            /*  if ( viewBy != 'Total Es')
            {
                sSOQL = sSOQL + ' And Opportunity.GE_ES_Ship_To_Region__c =: map_region_name.get(viewBy)';
            }
            else
            {
               sSOQL = sSOQL + ' And Opportunity.GE_ES_Ship_To_Region__c In: list_region'; 
            }*/
            if (strSubRegion != '--Select--') {
                sSOQL = sSOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c != null';
                sSOQL = sSOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c =: map_sub_region.get(strSubRegion)';
            }
            sSOQL = sSOQL + ' And Opportunity.StageName In (\'Active - Commit\', \'Active - High Probability\')';
            sSOQL = sSOQL + ' Order By Opportunity.Sales_Region__c '; //, Opportunity.GE_ES_Ship_To_Region__c,Opportunity.GE_ES_Ship_To_Sub_Region__c, Opportunity.StageName';
            
        System.debug(' Region ' + sSOQL);     
        for (SObject oSObject : Database.query( sSOQL )) {
            OpportunityLineItem oOppLineItem = (OpportunityLineItem) oSObject;
            ChartWrapperClass oChartWrapperClass = new ChartWrapperClass();
            oChartWrapperClass.region =  oOppLineItem.Opportunity.GE_ES_Ship_To_Sub_Region__c;// map_region_name.get(oOppLineItem.Opportunity.Sales_Region__c); //oOppLineItem.Opportunity.GE_ES_Ship_To_Region__c;//
            oChartWrapperClass.pl = oOppLineItem.GE_ES_P_L__c;
            oChartWrapperClass.customer = oOppLineItem.Opportunity.Account.Name;
            oChartWrapperClass.opportunityName = oOppLineItem.Opportunity.Name;
            oChartWrapperClass.opportunityDescription = oOppLineItem.Opportunity.Description;
            //oChartWrapperClass.amount = oOppLineItem.TotalPrice;
            oChartWrapperClass.amount = oOppLineItem.Opportunity.Pipeline_Amount_ge_og__c;
            oChartWrapperClass.stage = oOppLineItem.Opportunity.StageName;
            oChartWrapperClass.state = oOppLineItem.Opportunity.Account.ShippingState;
            oChartWrapperClass.accountId = oOppLineItem.Opportunity.AccountId;
            oChartWrapperClass.opportunityId = oOppLineItem.OpportunityId;
            list_chartWrapperClass.add( oChartWrapperClass );
            if (oOppLineItem.Opportunity.StageName == 'Closed Won' || oOppLineItem.Opportunity.StageName == 'Closed - Partially Won') {
                Double wonAmt = map_won.get('Won');
                wonAmt = wonAmt + oOppLineItem.TotalPrice;
                map_won.put('Won',wonAmt);
            }
            if (oOppLineItem.Opportunity.StageName == 'Active - Commit') {
                Double commitAmt = map_commit.get('Commit');
                commitAmt = commitAmt + oOppLineItem.TotalPrice;
                map_won.put('Commit',commitAmt);
            }
            
        }              
                       
    }
    
    public void getTotalChartAmount() {
        totalChartAmt = map_chartAmount.get('Oppplan') + map_chartAmount.get('Flow') + map_chartAmount.get('Won') + map_chartAmount.get('Commit') + map_chartAmount.get('Current') +  map_chartAmount.get('Next');
    }
    
    
    
    
    // Google Common Code 
    public class EncodingException extends Exception {}
    public class UnsupportedEncodingTypeException 
           extends Exception {}  

    // The encoding map which takes an integer key and returns the 
      // respective encoding value as defined by Google. 
       //This map is initialized in init()  
    
     @TestVisible private Map<Integer, String> encodingMap { get; set; }
    
   // The maximum encoding value supported for the given encoding 
     // type. This value is set during init() 
    
   @TestVisible private Integer encodingMax { get; set; }
    
    // The minimum encoding value supported for the given encoding 
     //  type. This value is set during init()   
    
    @TestVisible private Integer encodingMin { get; set; }
    
    // The encoding type according to Google's API. Only SIMPLE 
     //  is implemented.  
    
    public enum EncodingType { TEXT, SIMPLE, EXTENDED }
    
    // The minimum value to use in the generation of an encoding 
    //   value.  
    
    public Integer min { get; private set; }
    
    // The maximum value to use in the generation of an encoding 
     //  value.   
    
    public Integer max { get; private set; }
    
    // The encoding type according to the API defined by Google  
    
    public EncodingType eType { get; private set; }       
    
    // Corresponds to the data set provided by the page   
    
    public String dataSet { get; set; }
    
    // Corresponds to the type of graph selected on the page   
    
    public String graph { get; set; }
    
    // The URL that renders the Google Chart  
    
    public String chartURL { get; set; }  

    // Indicates whether the chart should be displayed   
    
    public Boolean displayChart { get; set; }
    
    public GEESWaterFallChart() {
        min = 0;
        max = 61;
        //eType = EncodingType.SIMPLE;
        displayChart = false;
        getTimeFrameInfo();
        getTimeFrameInfoForNextYear();
        list_chartWrapperClass = new List<ChartWrapperClass>();
        currentDate = date.today();
        currentYear = currentDate.year();
    } 
    
    public PageReference create() {
        try {
            System.debug(strTimeFrame + 'Inside Create ' + strViewBy + ' <<>>>' + strSubRegion); 
            /*if (strTimeFrame == '--Select--' || strViewBy == '--Select--')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please select the options.');
            } else {*/
            String[] dataSetList = null;//dataSet.split(',', 0);
            String mappedValue = 'chd=s:';
            Date startDate = null;
            Date endDate = null;
            if ( strTimeFrame == 'Total Year') {
                startDate =  map_startDate.get('1Q');
                endDate = map_endDate.get('4Q');  
            } else {
                startDate =  map_startDate.get(strTimeFrame);
                endDate = map_endDate.get(strTimeFrame);  
            }
            System.debug(startDate + ' == ' + endDate);
            //getChartDetails(startDate, endDate);
            list_chartWrapperClass = new List<ChartWrapperClass>();
            map_won.put('Won', 0.0);
            map_commit.put('Commit', 0.0);
            map_current.put('Current', 0.0);
            map_next.put('Next', 0.0);
            getChartData(strViewBy , startDate, endDate);
            getChartData(startDate, endDate);
            getCurrentQuarterData();
            getNextQuarterData();
            getFlowOpportunity(startDate, endDate);
            if (strSubRegion != '--Select--') {
                getOPPPlanSubRegionDetails();
            } else {
                getOPPPlanDetails();
            }    
            getTotalChartAmount();
            System.debug(map_chartAmount.get('Oppplan') + ' >><< ' + map_chartAmount.get('Flow') + ' >><< ' + map_chartAmount.get('Won') + ' >><< ' + map_chartAmount.get('Commit') + ' >><< ' + map_chartAmount.get('Current') + '<<>> ' + map_chartAmount.get('Next') + '>>>' + totalChartAmt );
            convertDoubleToInteger();    
            System.debug(map_chartIntegerAmount.get('Oppplan') + ' >><< ' + map_chartIntegerAmount.get('Flow') + ' >><< ' + map_chartIntegerAmount.get('Won') + ' >><< ' + map_chartIntegerAmount.get('Commit') + ' >><< ' + map_chartIntegerAmount.get('Current') + '<<>> ' + map_chartIntegerAmount.get('Next') + '>>>' + totalIntegerChartAmt);        
            
            Double strWonAmt = (map_chartAmount.get('Won')/totalChartAmt)  * 100;
            Double strCommitAmt = (map_chartAmount.get('Commit')/totalChartAmt)  * 100;
            Double strCurrentAmt = (map_chartAmount.get('Current')/totalChartAmt)  * 100;
            Double strNextAmt = (map_chartAmount.get('Next')/totalChartAmt)  * 100;
            
            chartURL = EncodingUtil.urldecode('http://chart.googleapis.com/chart?cht=bvs&chs=500x300&chd=t:' + 
            strWonAmt + ',' + strWonAmt + ',' + strWonAmt + ',' + strWonAmt + ',' + strWonAmt + '|' + 
            strCommitAmt + ',' + strCommitAmt + ',' + strCommitAmt + ',' + strCommitAmt + ',' + strCommitAmt + '|' + 
            strCurrentAmt + ',' + strCurrentAmt + ',' + strCurrentAmt + ',' + strCurrentAmt + ',' + strCurrentAmt + '|' + 
            strNextAmt + ',' + strNextAmt + ',' + strNextAmt + ',' + strNextAmt + ',' + strNextAmt + '|' +
            strWonAmt + ',' + strCommitAmt + ',' + strCurrentAmt + ',' + strNextAmt + ',' + strNextAmt + 
            '&chds=0,120&chco=29A6CF|FFFFFF|FFFFFF|FFFFFF|29A6CF,FFFFFF|47D1FF|FFFFFF|FFFFFF|47D1FF,FFFFFF|FFFFFF|91E3FF|FFFFFF|91E3FF,FFFFFF|FFFFFF|FFFFFF|D3F4FF|D3F4FF&chbh=70&chxt=y&&chds=0,40','UTF-8');
            //chartURL = 'https://chart.googleapis.com/chart?cht=bvs&chs=500x300&chd=t:5,5,5,5,5,5|10,10,10,10,10,10|10,10,10,10,10,10|10,10,10,10,10,10|10,10,10,10,10,10|10,10,10,10,10,10&chds=0,120&chco=1F7A99|FFFFFF|FFFFFF|FFFFFF|FFFFFF|1F7A99,FFFFFF|29A6CF|FFFFFF|FFFFFF|FFFFFF|29A6CF,FFFFFF|FFFFFF|47D1FF|FFFFFF|FFFFFF|47D1FF,FFFFFF|FFFFFF|FFFFFF|91E3FF|FFFFFF|91E3FF,FFFFFF|FFFFFF|FFFFFF|FFFFFF|D3F4FF|D3F4FF&chbh=70&chds=0,40&chxt=y';
            //chartURL = 'https://chart.googleapis.com/chart?cht=bvs&chs=500x300&chd=t:5,5,5,5,5,5|10,10,10,10,10,10|10,10,10,10,10,10|10,10,10,10,10,10|10,10,10,10,10,10|10,10,10,10,10,10&chds=0,120&chco=FF0000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000,FFFFFF|DEF3BD|FFFFFF|FFFFFF|FFFFFF|DEF3BD,FFFFFF|FFFFFF|C6EFF7|FFFFFF|FFFFFF|C6EFF7,FFFFFF|FFFFFF|FFFFFF|00B88A|FFFFFF|00B88A,FFFFFF|FFFFFF|FFFFFF|FFFFFF|000000|000000&chbh=70&chds=0,40&chxt=y';
            //chartURL = 'https://chart.googleapis.com/chart?cht=bvs&chs=400x200&chd=t:5,5,5,5|10,10,10,10|15,15,15,15|20,20,20,20&chds=0,120&chco=FF0000|FFFFFF|FFFFFF|FF0000,FFFFFF|DEF3BD|FFFFFF|DEF3BD,FFFFFF|FFFFFF|C6EFF7|C6EFF7,FFFFFF|FFFFFF|FFFFFF|00B88A&chbh=80&chds=0,40&chm=&chxs=0,000000,0,0,_&chxt=y&chxt=x,y&chxl';
            displayChart = true;
        } catch (Exception e) {
            ApexPages.addMessages( e );
        }
        return null;
    }
    
    public void getChartData(Date startDate, Date endDate) {
        AggregateResult[] groupedResults = null;
        String sOQL = 'Select Opportunity.StageName, convertCurrency(TotalPrice) '
                   + ' FROM OpportunityLineItem Where '
                   + ' TotalPrice >= 10000000.0 And '    
                   + ' GE_ES_Primary_Quote__c = true And '
                   + ' (Opportunity.CloseDate >=: startDate And Opportunity.CloseDate <=: endDate) And '
                   + ' Opportunity.RecordType.Name != \'Grouped Flow\' And'                   
                   + ' Opportunity.StageName In (\'Closed Won\',\'Closed - Partially Won\',\'Active - Commit\')' ; 
                    
      /*   if ( strViewBy != 'Total Es') {
             sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Region__c =: map_region_name.get(viewBy)';
         } else {
             sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Region__c In: list_region'; 
         }*/
         if (strSubRegion != '--Select--') {
             sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c != null';
             sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c =: map_sub_region.get(strSubRegion)';
         }            
        sOQL = sOQL + ' Order BY Opportunity.StageName ';                    
        Double wonAmount = 0.0;
        Double commitAmount = 0.0;
        for (SObject obj : Database.Query(sOQL))  {
           OpportunityLineItem oLineItem = (OpportunityLineItem) obj;
           String stageName = oLineItem.Opportunity.StageName;
           if (stageName == 'Closed Won' || stageName == 'Closed - Partially Won') {
               wonAmount = wonAmount + Double.valueOf(oLineItem.TotalPrice);
           }
           else if (stageName == 'Active - Commit') {
               commitAmount = commitAmount + Double.valueOf(oLineItem.TotalPrice);
           }
       }
       if (wonAmount > 0.0) {
            wonAmount = wonAmount / 1000000;
            wonAmount = wonAmount.round();
        }
        if (commitAmount > 0.0) {
            commitAmount= commitAmount/ 1000000;
            commitAmount= commitAmount.round();
        }   
        map_chartAmount.put('Won', wonAmount);
        map_chartAmount.put('Commit', commitAmount);                             
    } 
    public void getCurrentQuarterData() {
      Date dateCQStart = null;
      Date dateCQEnd = null;
      if ( strTimeFrame == 'Total Year') {
          dateCQStart =  map_startDate.get('1Q');
          dateCQEnd = map_endDate.get('4Q');  
      } else {
          dateCQStart =  map_startDate.get(strTimeFrame);
          dateCQEnd = map_endDate.get(strTimeFrame);  
      }
      String sOQL = 'Select Opportunity.StageName, convertCurrency(TotalPrice) '
                   + ' FROM OpportunityLineItem Where '
                   + ' TotalPrice >= 10000000.0 And '    
                   + ' GE_ES_Primary_Quote__c = true And '
                   + ' Opportunity.CloseDate >= : dateCQStart And Opportunity.CloseDate <= : dateCQEnd And'
                   + ' Opportunity.StageName = \'Active - High Probability\' And' 
                   + ' Opportunity.RecordType.Name != \'Grouped Flow\''; 
     /* if ( strViewBy != 'Total Es') {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Region__c =: map_region_name.get(viewBy)';
      } else {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Region__c In: list_region'; 
      }*/
      if (strSubRegion != '--Select--') {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c != null';
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c =: map_sub_region.get(strSubRegion)';
      }           
      sOQL = sOQL + ' Order BY Opportunity.StageName ';                                              
         //map_chartAmount
       Double currAmount = 0.0;
       for (SObject obj : Database.Query(sOQL))  {
         OpportunityLineItem oLineItem = (OpportunityLineItem) obj;
         currAmount  = currAmount + Double.valueOf(oLineItem.TotalPrice);
       }
       if (currAmount > 0.0) {
            currAmount = currAmount / 1000000;
            currAmount= currAmount.round();
        }   
       map_chartAmount.put('Current', currAmount);
                                                   
                 
    } 
    
    
    public void getNextQuarterData() {
       Date dateCQStart = null;
       Date dateCQEnd = null;
       if ( strTimeFrame == IST_QUARTER_TIME_FRAME ) {
            dateCQStart =  map_startDate.get('2Q');
            dateCQEnd = map_endDate.get('2Q');  
       } else if ( strTimeFrame == IIND_QUARTER_TIME_FRAME ) {
            dateCQStart =  map_startDate.get('3Q');
            dateCQEnd = map_endDate.get('3Q');  
       } else if ( strTimeFrame == IIIRD_QUARTER_TIME_FRAME ) {
            dateCQStart =  map_startDate.get('4Q');
            dateCQEnd = map_endDate.get('4Q');
       } else if ( strTimeFrame == IVTH_QUARTER_TIME_FRAME ) {
           dateCQStart =  map_next_fin_startDate.get('1Q');
           dateCQEnd = map_next_fin_endDate.get('1Q');
       } else if ( strTimeFrame == TOTAL_YEAR_TIME_FRAME ) {
           dateCQStart =  map_next_fin_startDate.get('1Q');
           dateCQEnd = map_next_fin_endDate.get('1Q');
       } 
       String sOQL = 'Select Opportunity.StageName, convertCurrency(TotalPrice) '
                   + ' FROM OpportunityLineItem Where '
                   + ' TotalPrice >= 10000000.0 And '    
                   + ' GE_ES_Primary_Quote__c = true And '
                   + ' Opportunity.CloseDate >= : dateCQStart And Opportunity.CloseDate <= : dateCQEnd And '
                   + ' Opportunity.StageName = \'Active - High Probability\' And' 
                   + ' Opportunity.RecordType.Name != \'Grouped Flow\''; 
     /*  if ( strViewBy != 'Total Es') {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Region__c =: map_region_name.get(viewBy)';
       } else {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Region__c In: list_region'; 
       }*/
       if (strSubRegion != '--Select--' ) {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c != null';
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c =: map_sub_region.get(strSubRegion)';
       }             
       sOQL = sOQL + ' Order BY Opportunity.StageName ';                                         
       //map_chartAmount
       Double nextAmount = 0.0;
       for (SObject obj : Database.Query(sOQL))  {
         OpportunityLineItem oLineItem = (OpportunityLineItem) obj;
         nextAmount  = nextAmount + Double.valueOf(oLineItem.TotalPrice);
       }
       if (nextAmount > 0.0) {
            nextAmount = nextAmount / 1000000;
            nextAmount = nextAmount.round();
        }    
       map_chartAmount.put('Next', nextAmount);                                         
       
    } 
    
    public void getFlowOpportunity(Date startDate, Date endDate)
    {
       String sOQL = 'Select Opportunity.StageName, convertCurrency(TotalPrice) '
                   + ' FROM OpportunityLineItem Where '
                   + ' TotalPrice >= 10000000.0 And '    
                   + ' GE_ES_Primary_Quote__c = true And '
                   + ' (Opportunity.CloseDate >=: startDate And Opportunity.CloseDate <=: endDate) And '
                   + ' Opportunity.RecordType.Name = \'Grouped Flow\'';
                  
     /* if ( strViewBy != 'Total Es') {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Region__c =: map_region_name.get(viewBy)';
      } else {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Region__c In: list_region'; 
      */
      if (strSubRegion != '--Select--') {
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c != null';
          sOQL = sOQL + ' And Opportunity.GE_ES_Ship_To_Sub_Region__c =: map_sub_region.get(strSubRegion)';
      }             
      sOQL = sOQL + ' Order BY Opportunity.StageName '; 
                                                
      Double flowAmount = 0.0;
      for (SObject obj : Database.Query(sOQL)) {
         OpportunityLineItem oLineItem = (OpportunityLineItem) obj;
         flowAmount  = flowAmount + Double.valueOf(oLineItem.TotalPrice);
      }
      if (flowAmount > 0.0) {
            flowAmount = flowAmount / 1000000;
            flowAmount = flowAmount.round();
      }    
      map_chartAmount.put('Flow', flowAmount);                                          
                                                
    }
    public void getOPPPlanDetails()
    {
        String sOQL = ' Select Id, GE_HQ_OP_2011_4Q__c, GE_HQ_OP_2011_3Q__c ,'
                     + ' GE_HQ_OP_2011_2Q__c, GE_HQ_OP_2011_1Q__c From '
                     + ' GE_ES_Sales_Region__c Where ';
        if (strViewBy == 'Total Es') {
            sOQL = sOQL + ' GE_ES_P_L__c = \'ES\'';
        } else {
            sOQL = sOQL + ' Id=:strViewBy ';
        }
        Double oppPlanAmt = 0.0;
        for (SObject obj : Database.Query(sOQL))  {
            GE_ES_Sales_Region__c oSalesRegion = (GE_ES_Sales_Region__c) obj;
            if (strTimeFrame == TOTAL_YEAR_TIME_FRAME) {
                oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_4Q__c != null ? oSalesRegion.GE_HQ_OP_2011_4Q__c : 0.0) + 
                                          (oSalesRegion.GE_HQ_OP_2011_3Q__c != null ? oSalesRegion.GE_HQ_OP_2011_3Q__c : 0.0) + 
                                          (oSalesRegion.GE_HQ_OP_2011_2Q__c != null ? oSalesRegion.GE_HQ_OP_2011_2Q__c : 0.0) + 
                                          (oSalesRegion.GE_HQ_OP_2011_1Q__c  != null ? oSalesRegion.GE_HQ_OP_2011_1Q__c : 0.0);
            } else {
                if ( strTimeFrame == IST_QUARTER_TIME_FRAME ) {
                    oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_1Q__c != null ? oSalesRegion.GE_HQ_OP_2011_1Q__c : 0.0) ;
                } else if ( strTimeFrame == IIND_QUARTER_TIME_FRAME ) {
                    oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_2Q__c != null ? oSalesRegion.GE_HQ_OP_2011_2Q__c : 0.0);
                } else if ( strTimeFrame == IIIRD_QUARTER_TIME_FRAME ) {
                    oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_3Q__c != null ? oSalesRegion.GE_HQ_OP_2011_3Q__c : 0.0);
                } else if ( strTimeFrame == IVTH_QUARTER_TIME_FRAME ) {
                    oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_4Q__c != null ? oSalesRegion.GE_HQ_OP_2011_4Q__c : 0.0);
                }
            } 
        }
        
       if (oppPlanAmt > 0.0) {
            oppPlanAmt = oppPlanAmt / 1000000;
            oppPlanAmt = oppPlanAmt.round();
        }  
        /*if (flowAmount > 0.0) {
            flowAmount = flowAmount / 1000000;
            flowAmount = flowAmount.round();
        }   
       map_chartAmount.put('Flow', flowAmount);*/ 
        System.debug('oppplan amount ' + oppPlanAmt);  
       map_chartAmount.put('Oppplan', oppPlanAmt); 
    }
    public void getOPPPlanSubRegionDetails()
    {
        String sOQL = ' Select Id, GE_HQ_OP_2011_4Q__c, GE_HQ_OP_2011_3Q__c ,'
                     + ' GE_HQ_OP_2011_2Q__c, GE_HQ_OP_2011_1Q__c From '
                     + ' GE_ES_Sub_Region__c Where ';
        if (strViewBy == 'Total Es') {
            sOQL = sOQL + ' GE_HQ_P_L__c = \'ES\'';
        } else {
            sOQL = sOQL + ' GE_HQ_Sales_Region__c =:strViewBy ';
            sOQL = sOQL + ' And Id =:strSubRegion ';
        }
        Double oppPlanAmt = 0.0;
        for (SObject obj : Database.Query(sOQL))  {
            GE_ES_Sub_Region__c oSalesRegion = (GE_ES_Sub_Region__c) obj;
            if (strTimeFrame == TOTAL_YEAR_TIME_FRAME) {
                oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_4Q__c != null ? oSalesRegion.GE_HQ_OP_2011_4Q__c : 0.0) + 
                                          (oSalesRegion.GE_HQ_OP_2011_3Q__c != null ? oSalesRegion.GE_HQ_OP_2011_3Q__c : 0.0) + 
                                          (oSalesRegion.GE_HQ_OP_2011_2Q__c != null ? oSalesRegion.GE_HQ_OP_2011_2Q__c : 0.0) + 
                                          (oSalesRegion.GE_HQ_OP_2011_1Q__c  != null ? oSalesRegion.GE_HQ_OP_2011_1Q__c : 0.0);
            } else {
                if ( strTimeFrame == IST_QUARTER_TIME_FRAME ) {
                    oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_1Q__c != null ? oSalesRegion.GE_HQ_OP_2011_1Q__c : 0.0) ;
                    System.debug('Sub Region opp plan amt >>> ' + oppPlanAmt );
                } else if ( strTimeFrame == IIND_QUARTER_TIME_FRAME ) {
                    oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_2Q__c != null ? oSalesRegion.GE_HQ_OP_2011_2Q__c : 0.0);
                } else if ( strTimeFrame == IIIRD_QUARTER_TIME_FRAME ) {
                    oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_3Q__c != null ? oSalesRegion.GE_HQ_OP_2011_3Q__c : 0.0);
                } else if ( strTimeFrame == IVTH_QUARTER_TIME_FRAME ) {
                    oppPlanAmt = oppPlanAmt + (oSalesRegion.GE_HQ_OP_2011_4Q__c != null ? oSalesRegion.GE_HQ_OP_2011_4Q__c : 0.0);
                }
            } 
        }
        
       if (oppPlanAmt > 0.0) {
            oppPlanAmt = oppPlanAmt / 1000000;
            oppPlanAmt = oppPlanAmt.round();
        }  
        /*if (flowAmount > 0.0) {
            flowAmount = flowAmount / 1000000;
            flowAmount = flowAmount.round();
        }   
       map_chartAmount.put('Flow', flowAmount);*/ 
        System.debug('oppplan amount ' + oppPlanAmt);  
       map_chartAmount.put('Oppplan', oppPlanAmt); 
        
                     
    }
    
    public void convertDoubleToInteger() {
        for (String key : map_chartAmount.keySet()) {
            map_chartIntegerAmount.put(key, Integer.valueOf(map_chartAmount.get(key)));
            totalIntegerChartAmt = totalIntegerChartAmt + Integer.valueOf(map_chartAmount.get(key));
        }
    }
   
    public String getXmlData() {
        string strRet = '';
        
        Integer nWon = map_chartIntegerAmount.get('Won');
        Integer nCommit = map_chartIntegerAmount.get('Commit');
        Integer nCurrent = map_chartIntegerAmount.get('Current');
        Integer nNext = map_chartIntegerAmount.get('Next');
        Integer nFlow = map_chartIntegerAmount.get('Flow');
        
        Integer nOppplan = map_chartIntegerAmount.get('Oppplan');
        //Integer nOppplan = nOppplan1 / 2;
        System.debug('Op Plan >>>>>' + nOppplan);
        String strHighCurrentLabel = (strTimeFrame == 'Total Year' ? 'High CY' : 'High CQ');
        
        Integer nTotal = (nWon+nCommit+nCurrent+nNext+nFlow);
        string sWon = nWon>0 ? 'Won' : ' ';
        string sCommit = nCommit>0 ? 'Commit' : ' ';
        //string sCurrent = nCurrent>0 ? 'High CQ' : ' ';
        string sCurrent = nCurrent>0 ? strHighCurrentLabel : ' ';
        
        string sNext = nNext>0 ? 'High NQ' : ' ';
        string sFlow = nFlow>0 ? 'Flow' : ' ';

        System.debug('nTotal ### ' + nTotal + ' nOppplan ### ' + nOppplan);
        
        strRet = '<vc:Chart  xmlns:vc="clr-namespace:Visifire.Charts;assembly=SLVisifire.Charts" Width="490" ' + 
            + 'Height="290" Theme="Theme1" BorderBrush="Gray" AnimatedUpdate="true" ' + 
            + 'CornerRadius="7" ShadowEnabled="true" Padding="4,4,4,10">' +

  + '<vc:Chart.Titles>' +
    + '<vc:Title Text="Progress to OP $MM" FontWeight="Bold"/>' +
  + '</vc:Chart.Titles>' +
  
  + '<vc:Chart.AxesX>' +
    + '<vc:Axis Enabled="False" />' +
  + '</vc:Chart.AxesX>';

    if(nTotal>nOppplan){
        strRet+= '<vc:Chart.AxesY>' +
        + '<vc:Axis Title="Total(In millions of dollars)" Prefix="$" TitleFontWeight="Bold"/>' +
      + '</vc:Chart.AxesY>';
    }else{
        strRet+= '<vc:Chart.AxesY>' +
        + '<vc:Axis AxisMaximum="' + (nOppplan+(nOppplan*.25)) + '" Title="Total(In millions of dollars)" Prefix="$" TitleFontWeight="Bold"/>' +
      + '</vc:Chart.AxesY>';
    }
    
  strRet+= '<vc:Chart.PlotArea>' +
    + '<vc:PlotArea ShadowEnabled="false"/>' +
  + '</vc:Chart.PlotArea>' +

    + '<vc:Chart.TrendLines>' + 
    + '<vc:TrendLine LineColor="#007A99" Value="' + nOppplan + '" ToolTipText="Op Plan,' + nOppplan + '"/>' +
    + '</vc:Chart.TrendLines>' +
  
+ '<vc:Chart.Legends>' +
    + '<vc:Legend Enabled="False" BorderColor="#dbf2f2" BorderThickness="0.5" CornerRadius="2">' +
      + '<vc:Legend.Background>' +
        + '<LinearGradientBrush EndPoint="1,1" StartPoint="0,1">' +

          + '<GradientStop Color="#f9f8f8" Offset="0.1"/>' +
          + '<GradientStop Color="#f1fafa" Offset="0.4"/>' +
          + '<GradientStop Color="#fcfefe" Offset="1"/>' +
        + '</LinearGradientBrush>' +
      + '</vc:Legend.Background>' +
    + '</vc:Legend>' +
+ '</vc:Chart.Legends>' +
  
  + '<vc:Chart.Series>' +

    + '<vc:DataSeries LegendText="Flow" RenderAs="StackedColumn" >' +
      + '<vc:DataSeries.DataPoints>' +
        + '<vc:DataPoint LabelText="' + sFlow + '" LabelEnabled="True" YValue="' + nFlow + '" ToolTipText="#LegendText,#YValue" Color="#000000"/>' +
        + '<vc:DataPoint YValue="' + nFlow + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nFlow + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nFlow + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nFlow + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint LabelText="' + sFlow + '" LabelEnabled="True" YValue="' + nFlow + '" ToolTipText="#LegendText,#YValue" Color="#000000"/>' +
      + '</vc:DataSeries.DataPoints>' +
    + '</vc:DataSeries>' +


    + '<vc:DataSeries LegendText="Won" RenderAs="StackedColumn" >' +
      + '<vc:DataSeries.DataPoints>' +
        + '<vc:DataPoint YValue="' + nWon + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint LabelText="' + sWon + '" LabelEnabled="True" YValue="' + nWon + '" ToolTipText="#LegendText,#YValue" Color="#000000"/>' +
        + '<vc:DataPoint YValue="' + nWon + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nWon + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nWon + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint LabelText="' + sWon + '" LabelEnabled="True" YValue="' + nWon + '" ToolTipText="#LegendText,#YValue" Color="#000000"/>' +
      + '</vc:DataSeries.DataPoints>' +
    + '</vc:DataSeries>' +

    + '<vc:DataSeries LegendText="Commit" Bevel="True" RenderAs="StackedColumn" >' +
      + '<vc:DataSeries.DataPoints>' +
        + '<vc:DataPoint YValue="' + nCommit + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nCommit + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint LabelText="' + sCommit + '" LabelEnabled="True" YValue="' + nCommit + '" ToolTipText="#LegendText,#YValue" Color="#00CCFF"/>' +
        + '<vc:DataPoint YValue="' + nCommit + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nCommit + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint LabelText="' + sCommit + '" LabelEnabled="True" YValue="' + nCommit + '" ToolTipText="#LegendText,#YValue" Color="#00CCFF"/>' +
      + '</vc:DataSeries.DataPoints>' +

    + '</vc:DataSeries>' +

    + '<vc:DataSeries LegendText="Active High Current Quarter" RenderAs="StackedColumn" >' +
     + ' <vc:DataSeries.DataPoints>' +
        + '<vc:DataPoint YValue="' + nCurrent + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nCurrent + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nCurrent + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint LabelText="' + sCurrent + '" LabelEnabled="True" YValue="' + nCurrent + '" ToolTipText="#LegendText,#YValue" Color="#80E6FF"/>' +
        + '<vc:DataPoint YValue="' + nCurrent + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint LabelText="' + sCurrent + '" LabelEnabled="True" YValue="' + nCurrent + '" ToolTipText="#LegendText,#YValue" Color="#80E6FF"/>' +

      + '</vc:DataSeries.DataPoints>' +
    + '</vc:DataSeries>' +

    + '<vc:DataSeries LegendText="Active High Next Quarter" RenderAs="StackedColumn" >' +
      + '<vc:DataSeries.DataPoints>' +
        + '<vc:DataPoint YValue="' + nNext + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nNext + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nNext + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint YValue="' + nNext + '" Opacity="0" ToolTipText="{x:Null}"/>' +
        + '<vc:DataPoint LabelText="' + sNext + '" LabelEnabled="True" YValue="' + nNext + '" ToolTipText="#LegendText,#YValue" Color="#E6FAFF"/>' +
        + '<vc:DataPoint LabelText="' + sNext + '" LabelEnabled="True" YValue="' + nNext + '" ToolTipText="#LegendText,#YValue" Color="#E6FAFF"/>' +
      + '</vc:DataSeries.DataPoints>' +
    + '</vc:DataSeries>' +

  + '</vc:Chart.Series>' +
+ '</vc:Chart>';
        
        return strRet;
    }    
    
}