@IsTest
public class SST_ComunicacionesTest {
    static testMethod void SST_ComunicacionesTest(){
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;     
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        insert cuenta;
        
        SST_Sede__c sede = new SST_Sede__c();
        sede.Name = 'Sede prueba';
        sede.Departamento__c = '5';
        sede.Municipio__c = '5002';
        sede.Estado__c = SST_Constantes.ACTIVO;
        sede.Direccion__c = 'Direccion';
        sede.Zona__c = 'URBANA';
        insert Sede;
        
        SST_Area_trabajo__c area = new SST_Area_trabajo__c();
        area.Name = 'Area prueba';
        area.Estado__c = SST_Constantes.ACTIVO;
        area.empresa__c = empresa;
        insert area;
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Cargo__c cargoFuncionario = new SST_Cargo__c();
        cargoFuncionario.recordTypeId = idCargoFuncionario;
        cargoFuncionario.name = 'Cargo prueba';
        insert cargoFuncionario;
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Pereira';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Cargo__c = cargoFuncionario.id;
        contacto.SST_Sede__c = sede.id;
        contacto.SST_Area_Trabajo__c = area.id;
        contacto.SST_Departamento__c = '5';
        contacto.SST_Municipio__c = '5002';
        contacto.RecordTypeId = idFuncionario;
        insert contacto;
        
        Contact contacto2 = New Contact();
        contacto2.recordTypeId = idFuncionario;
        contacto2.LastName='Perez';
        contacto2.FirstName='Pedro';
        contacto2.Email='contacto2@hotmail.com';
        contacto2.SST_isActive__c='true';
        contacto2.SST_Tipo_Identificacion__c = 'C';
        contacto2.SST_Identificacion__c = '12301';
        contacto2.MobilePhone = '3111234567';
        contacto2.SST_Contacto_Emergencia__c = 'contacto';
        contacto2.SST_Telefono_Emergencia__c = '123';
        contacto2.SST_Departamento__c = '5';
        contacto2.SST_Municipio__c = '5002';
        contacto2.RecordTypeId = idContratista;
        insert contacto2;
        
        SST_ComunicacionesCC registroActoCondicion = new SST_ComunicacionesCC();
        //se consulta con cedula vacía
        registroActoCondicion.cedula = '';
        registroActoCondicion.consultarContacto();
        System.assert(registroActoCondicion.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Digite el número de identificación para continuar'));
        //se consulta con cedula con caracteres invalidos
        registroActoCondicion.cedula = '*/23';
        registroActoCondicion.consultarContacto();
        System.assert(registroActoCondicion.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('El texto ingresado no es un número de identificación válido'));
        //se consulta un contacto que no existe
        registroActoCondicion.cedula = '1233';
        registroActoCondicion.consultarContacto();
        System.assert(registroActoCondicion.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('El contacto no está registrado en el sistema'));
        /*se consulta un contacto que si existe*/
        registroActoCondicion.cedula = '1230';
        registroActoCondicion.consultarContacto();
        String cadena = 'abc';
        registroActoCondicion.fileBody = Blob.valueOf(cadena);
        registroActoCondicion.fileName = 'nombre.xls';
        registroActoCondicion.fileSize = 32;
        /*se intenta guardar sin detalle*/
        registroActoCondicion.guardar();
        System.assert(registroActoCondicion.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Debe ingresar el detalle para enviar el informe'));
        /*se guarda con el detalle*/
        registroActoCondicion.detalle = 'prueba envio';
        registroActoCondicion.guardar();
        System.assert(registroActoCondicion.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Su informe ha sido enviado exitosamente: Fecha y hora: ') ||registroActoCondicion.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Permisos'));
        registroActoCondicion.cancelar();
        
        
        SST_ComunicacionesCC registroActoCondicion2 = new SST_ComunicacionesCC();
        registroActoCondicion2.cedula = '12301';
        registroActoCondicion2.consultarContacto();
        registroActoCondicion2.detalle = 'prueba envio';
        String cadena2 = 'abc';
        registroActoCondicion2.fileBody = Blob.valueOf(cadena2);
        registroActoCondicion2.fileName = 'nombre.jepg';
        registroActoCondicion2.fileSize = 32;
        registroActoCondicion2.guardar();
        System.assert(registroActoCondicion2.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('El tipo de archivo no es permitido')||registroActoCondicion2.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Permisos'));
        registroActoCondicion2.cancelar();
        
        registroActoCondicion2.getEmpresas();
    }
    
}