global class PriceCalculator {
  
    global class pricecalval {
    
        public Decimal PricePerConSheet;
        public Decimal NumOfConSheet;
        public Decimal FrontCover;
        public Decimal StandBinding;
        public Decimal HandAndProce;
        public Decimal AudioCD;
        public Decimal Total;
        
        
    }
    public PriceCalculator() {
    
    }
    
    /*public PriceCalculator(List<pricecalval> priceList){      
             
        for(pricecalval val :priceList) {
            val.Total = val.PricePerConSheet * val.NumOfConSheet + val.FrontCover + val.StandBinding + val.HandAndProce + val.AudioCD * 3.3;
            system.debug('::val.PricePerConSheet::::'+val.PricePerConSheet); 
            system.debug(':::val.NumOfConSheet:::'+val.NumOfConSheet); 
            system.debug('::::val.Total::::'+val.Total);      
        }       
         
    }*/
    @RemoteAction
    global static pricecalval PriceCalculation(pricecalval price){      
        system.debug(':::::::::::::::::'+price);
        //List<pricecalval> priceval = (pricecalval)System.JSON.deserialize(price,pricecalval.class);
         
        price.Total = price.PricePerConSheet * price.NumOfConSheet + price.FrontCover + price.StandBinding + price.HandAndProce + price.AudioCD * 3.3;
        system.debug('::val.PricePerConSheet::::'+price.PricePerConSheet); 
        system.debug(':::val.NumOfConSheet:::'+price.NumOfConSheet); 
        system.debug('::::val.Total::::'+price.Total);      
        return price;   
         
    }   
    @RemoteAction
    global static List<DLS_Photocopy_Pricing__c> getPriceList(){      
        
        List<DLS_Photocopy_Pricing__c> priceList = DLSPhotocopyPricingService.getprice();
        system.debug('::::priceList::::'+priceList);      
        return priceList ;   
         
    }    
    
}