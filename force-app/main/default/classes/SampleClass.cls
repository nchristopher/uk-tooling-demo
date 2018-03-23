public with sharing class SampleClass {
    public SampleClass() {

    }
    public Integer printSum(Integer number1, Integer number2){
        System.debug('Sum : ' + number1+number2);
        return number1 + number2;
    }
}
