@isTest
public class SST_FormacionCargoCCPDFTest {
    
    public static testMethod void SST_FormacionCargoCCPDFTest(){
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        insert cuenta;
        
        SST_Formacion__c formacionResponsabilidad = new SST_Formacion__c();
        formacionResponsabilidad.Nombre__c='Responsabilidad prueba';
        formacionResponsabilidad.Tipo_Responsabilidad__c = 'SST';
        formacionResponsabilidad.RecordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();
        insert(formacionResponsabilidad);
        
        SST_Formacion__c formacionResponsabilidad2 = new SST_Formacion__c();
        formacionResponsabilidad2.Nombre__c='Responsabilidad prueba2';
        formacionResponsabilidad2.Tipo_Responsabilidad__c = 'SST';
        System.assert(('SST') == formacionResponsabilidad2.Tipo_Responsabilidad__c);
        formacionResponsabilidad2.RecordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();
        insert(formacionResponsabilidad2);
        
        SST_Cargo__c cargoFuncionario = new SST_Cargo__c();
        cargoFuncionario.recordTypeId = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Comité').getRecordTypeId();
        cargoFuncionario.name = 'Cargo prueba';
        System.assert(('Cargo prueba') == cargoFuncionario.name);
        cargoFuncionario.Estado__c = SST_Constantes.ACTIVO;
        insert cargoFuncionario;
        
        SST_Formacion_cargo__c formacionCargo3 = new SST_Formacion_cargo__c();
        formacionCargo3.Cargo__c =cargoFuncionario.id;
        formacionCargo3.Formacion__c = formacionResponsabilidad.id;
        insert(formacionCargo3);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cargoFuncionario);
        SST_FormacionCargoCCPDF controlador = new SST_FormacionCargoCCPDF(sc);
        controlador.generarDatosEncabezado();
        controlador.consultarInformacion();
    }

}