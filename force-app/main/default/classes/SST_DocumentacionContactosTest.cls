@IsTest
public class SST_DocumentacionContactosTest {
    Static String empresa = SST_TestDataFactory.returnEmpresa();
    
    Static ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();    
    
    static testMethod void SST_DocumentacionContactosTest(){        
        Test.StartTest();
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        Contact contacto = SST_TestDataFactory.crearContratista(cuenta);
        SST_Gestion_documentos__c documento = SST_TestDataFactory.crearDocumento(contacto.id);
        SST_DocumentacionContactosCC controlador = new SST_DocumentacionContactosCC();
        
        controlador.contacto.identificacion = contacto.SST_Identificacion__c;
        controlador.contacto.codigo = contacto.id;
        controlador.contacto.autorizacion = false;
        controlador.consultarContacto();
        controlador.contacto.autorizacion = true;
        controlador.consultarContacto();
        controlador.recargar();
        String cadena = 'abc';
        controlador.fileBody = Blob.valueOf(cadena);
        controlador.fileName = 'nombre.xls';
        controlador.fileSize = 32;
        
        controlador.idSeleccionado = documento.id;
        controlador.tipoSeleccionado = 'DOC01';
        controlador.guardar();
        System.assert(('DOC01') == controlador.tipoSeleccionado);
        
        controlador.idSeleccionado = documento.id;
        controlador.tipoSeleccionado = 'DOC01';
        controlador.guardar();
        controlador.pathDocumento = 'nombre.xls';
        controlador.eliminar();
        Test.StopTest();
    }
    
    static testMethod void SST_DocumentacionContactosTest2(){        
        Test.StartTest();
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        Contact contacto = SST_TestDataFactory.crearContratista(cuenta);
        
        SST_Gestion_documentos__c documento = SST_TestDataFactory.crearDocumento(contacto.id);
        
        SST_DocumentacionContactosCC controlador = new SST_DocumentacionContactosCC();
        
        controlador.contacto.identificacion = contacto.SST_Identificacion__c;
        controlador.contacto.codigo = contacto.id;
        controlador.contacto.autorizacion = true;
        controlador.consultarContacto();
        
        String cadena2 = 'abc';
        controlador.fileBody = Blob.valueOf(cadena2);
        controlador.fileName = 'nombres';
        controlador.idSeleccionado = documento.id;
        controlador.tipoSeleccionado = 'DOC01';
        System.assert(('DOC01') == controlador.tipoSeleccionado);
        controlador.guardar();
        
        String cadena3 = 'abc';
        controlador.fileBody = Blob.valueOf(cadena3);
        controlador.fileName = 'nombres.xls';
        controlador.idSeleccionado = documento.id;
        controlador.tipoSeleccionado = 'DOC01';        
        controlador.fileBody = Blob.valueOf(cadena3);
        controlador.fileSize = 3072001;
        controlador.guardar();
        
        String cadena4 = 'abc';
        controlador.fileBody = Blob.valueOf(cadena4);
        controlador.fileName = SST_Constantes.NOMBRE_PDF_POLITICA+'.pdf';
        controlador.fileSize = 32;
        controlador.idSeleccionado = documento.id;
        controlador.tipoSeleccionado = 'DOC01';
        controlador.guardar();
        controlador.notificar();
        controlador.cancelar();
        
        List<ContentVersion> cdl = [select id from ContentVersion limit 1];
        if(cdl!=null && !cdl.isEmpty()){
            ContentDistribution cd = new ContentDistribution(ContentVersionId=cdl.get(0).id, Name=SST_Constantes.NOMBRE_PDF_POLITICA+' '+Date.today());
            insert cd;
        }
        
        Test.StopTest();
    }
}