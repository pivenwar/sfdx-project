@isTest
public class SST_MatrizLegalCCTest {
    
    static testMethod void SST_MatrizLegalCCTest(){
 
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
        
        //Se llaman los atributos y métodos del controlador SST_MatrizLegalCC
        ApexPages.currentPage().getHeaders().put('Referer', 'test');
        SST_MatrizLegalCC controller = new SST_MatrizLegalCC();
        //controller.listaMatriz=listaMatriz;
        controller.getResponsable();
        controller.getFuncionario();
        controller.getCumplimiento();
        
        //Se guarda para que el responsaable sea la  opción funcionario y el campo funcionario sea null
        controller.Guardar();
        System.assert(controller.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Se ha actualizado la Matriz exitosamente.')||controller.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Permisos'));

        controller.verSiguiente();
        controller.verSiguienteGuardar();
        controller.verAnterior();
        controller.verAnteriorGuardar();
        controller.verInicio();
        controller.verInicioGuardar();
        controller.verFinal();
        controller.verFinalGuardar();
        
        //Se le agrega el contacto al funcionario de la normatividad
        normatividad.Funcionario__c=contacto.id;
            
        //Se crea la segunda normatividad de prueba para cuando la opción responsable sea igual a Empresa 
        SST_Normatividad__c normatividadEmpresa = New SST_Normatividad__c();
        normatividadEmpresa.name ='Normatividad prueba 2';
        normatividad.articulo__c ='Articulo 4';
        normatividadEmpresa.id=normatividadEmpresa.id;
        normatividadEmpresa.Tipo__c ='LEY';
        normatividadEmpresa.Fecha_expedicion__c=system.today();
        normatividadEmpresa.Fuente__c='www.fuente.com';
        normatividadEmpresa.Entidad__c ='E-008';
        normatividadEmpresa.Tema__c='Tema de prueba';
        normatividadEmpresa.Responsable__c='EMPRESA';
        normatividadEmpresa.Cumplimiento__c='CUMPLE';
        normatividadEmpresa.Observaciones__c='Observación de prueba';
        insert (normatividadEmpresa);
        
        //Se añade la segunda normatividad a la listaMatriz
        listaMatriz.add(normatividadEmpresa);
        //Se guarda nuevamente con la segunda normatividad y el funcionario asociado
        controller.Guardar();
        
        List<AggregateResult>  totalLegal = [SELECT COUNT(cumplimiento__c) total FROM SST_Normatividad__c ]; 
        integer totalL = (integer) totalLegal.get(0).get('total');  
        controller.generarReporteMatrizLegal();
    }

}