@isTest
public class PriceCalculatorTest {
    
    static testmethod void test1(){
        List<PriceCalculator.pricecalval> priList = new List<PriceCalculator.pricecalval>();
        PriceCalculator.pricecalval pri = new PriceCalculator.pricecalval();
        pri.PricePerConSheet = 0.20;
        pri.NumOfConSheet = 100;
        pri.FrontCover= 0.30;
        pri.StandBinding=3.50;
        pri.HandAndProce=7.70;
        pri.AudioCD=2;
        priList.add(pri);
        //List<PriceCalculator.pricecalval> ins = new List<PriceCalculator.pricecalval>{
        //                                        new PriceCalculator.pricecalval(0.20, 100, 0.30, 3.50, 7.70, 2)
        //};
        PriceCalculator a = new PriceCalculator();
        
        PriceCalculator.PriceCalculation(pri); 
        
        PriceCalculator.getPriceList();  
    }
}