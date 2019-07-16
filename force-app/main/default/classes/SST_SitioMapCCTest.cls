/*Clase test que se encarga de cubrir las pruebas para el componente de map*/
@isTest
public class SST_SitioMapCCTest {
    
    /*Método que se encarga de probar los flujos del componente map*/
    public static testMethod void SST_SitioMapCCTest(){
         Test.StartTest();
        SST_Sede__c sedeArmenia = new SST_Sede__c();
        sedeArmenia.Name = 'Sede Armenia';
        sedeArmenia.Estado__c = SST_Constantes.ACTIVO;
        sedeArmenia.Ubicacion__Latitude__s = 4.5539753;
        sedeArmenia.Ubicacion__Longitude__s = -75.6642867;
        sedeArmenia.Departamento__c = '5';
        sedeArmenia.Municipio__c = '5002';
        sedeArmenia.Direccion__c = 'Direccion';
        sedeArmenia.Zona__c = 'URBANA';
        sedeArmenia.email_sede__c = 'geli@gmail.com';
        sedeArmenia.telefono__c='758485';
        insert sedeArmenia;
        
        SST_Sede__c sede = new SST_Sede__c();
        sede.Name = 'Sede prueba';
        sedeArmenia.Estado__c = SST_Constantes.ACTIVO;
        sede.Ubicacion_Punto_encuentro__Longitude__s = 4.5539753;
        sede.Ubicacion_Punto_encuentro__Latitude__s = -75.6642867;
        sede.Departamento__c = '5';
        sede.Municipio__c = '5002';
        sede.Direccion__c = 'Direccion';
        sede.email_sede__c = 'geli@gmail.com';
        sede.telefono__c='758485';
        sede.Zona__c = 'URBANA';
        insert sede;
        
        SST_SitioMapCC.getAllSitios();
        Test.stopTest();
    }
}