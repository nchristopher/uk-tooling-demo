@isTest(seeAllData=false)
public with sharing class SampleClassTest {
    static testMethod void SampleClassTest() {
        SampleClass sc = new SampleClass();
        System.assertEquals(4, sc.printSum(2, 2));
    }
}
