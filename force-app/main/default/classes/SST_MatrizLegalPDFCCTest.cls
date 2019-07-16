@isTest
public class SST_MatrizLegalPDFCCTest {
    
    static testMethod void SST_MatrizLegalPDFCCTest(){
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     
       
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        insert cuenta;
        
        //Se crea el contacto de prueba
        Contact contacto = New Contact();
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Juan';
        contacto.FirstName='Perez';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_Departamento__c='63';
        System.assert(('63') == contacto.SST_Departamento__c); 
        contacto.SST_isActive__c='true';
        contacto.sst_identificacion__c = 'cc123';
        insert(contacto);
        
        //Se crea la normatividad de prueba para cuando la opción responsable sea igual a Funcionario
        List <SST_Normatividad__c> listaMatriz = new List <SST_Normatividad__c>();
        SST_Normatividad__c normatividad = New SST_Normatividad__c();
        normatividad.name ='Normatividad prueba';
        normatividad.articulo__c ='Articulo 4';
        normatividad.id=normatividad.id;
        normatividad.Tipo__c ='LEY';
        normatividad.Fecha_expedicion__c=system.today();
        normatividad.Fuente__c='www.fuente.com';
        normatividad.Entidad__c ='E-008';
        normatividad.Tema__c='Tema de prueba';
        normatividad.Responsable__c='FUNCIONARIO';
        normatividad.Funcionario__c = contacto.id;
        normatividad.Cumplimiento__c='CUMPLE';
        normatividad.Observaciones__c='Observación de prueba';
        insert (normatividad);

        
        //Se añade la normatividad a la listaMatriz
        listaMatriz.add(normatividad);
        
        //Se llaman los atributos y métodos del controlador SST_MatrizLegalPDFCC
        ApexPages.currentPage().getHeaders().put('Referer', 'test');
        SST_MatrizLegalPDFCC controller = new SST_MatrizLegalPDFCC();
        controller.consultarDatosEncabezado();
        controller.consultarNormatividades();
        controller.calcularPromedio();
    }

}