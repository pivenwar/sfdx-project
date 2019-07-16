@IsTest
public class SST_InactivacionRegistrosSchedulableTest {

    static testMethod void testschedule() {        
        Test.StartTest();
        Date hoy = system.today();
	    ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;     
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.SST_periodo_notificacion__c = 1;
        insert cuenta;
        
        Contact contacto = New Contact();
        contacto.LastName='Perez';
        contacto.FirstName='Andrea';
        contacto.Email='mailContactoTestSST@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '12301230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c = '5';
        contacto.SST_Municipio__c = '5002';
        contacto.recordTypeId = idContratista;
        contacto.sst_Documentacion_contacto__c = '';
		insert contacto;

        Contact contacto2 = New Contact();
        contacto2.LastName='Perez';
        contacto2.FirstName='Andres';
        contacto2.Email='mail2ContactoTestSST@hotmail.com';
        contacto2.SST_isActive__c='true';
        contacto2.SST_Tipo_Identificacion__c = 'C';
        contacto2.SST_Identificacion__c = '123012301';
        contacto2.MobilePhone = '3101234567';
        contacto2.SST_Contacto_Emergencia__c = 'contacto';
        contacto2.SST_Telefono_Emergencia__c = '123';
        contacto2.SST_Departamento__c = '5';
        contacto2.SST_Municipio__c = '5002';
        contacto2.recordTypeId = idContratista;
        contacto2.sst_Documentacion_contacto__c = '';
		insert contacto2;
        
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        
        Contact funcionario = New Contact();
        funcionario.LastName='Zapata';
        funcionario.FirstName='Sonia';
        funcionario.Email='mailFuncionarioTestSST@hotmail.com';
        funcionario.SST_isActive__c='true';
        funcionario.SST_Tipo_Identificacion__c = 'C';
        funcionario.SST_Identificacion__c = '1230';
        funcionario.MobilePhone = '3101234567';
        funcionario.SST_Contacto_Emergencia__c = 'funcionario';
        funcionario.SST_Telefono_Emergencia__c = '123';
        funcionario.SST_Departamento__c = '5';
        funcionario.SST_Municipio__c = '5002';
        funcionario.recordTypeId = idFuncionario;
        funcionario.sst_cargo__c = cargoFuncionario.id;
        Insert funcionario;
        
        SST_Gestion_documentos__c doc1 = new SST_Gestion_documentos__c();
        doc1.contacto__c = contacto.id;
        doc1.tipo_documento__c = 'DOC01';
        doc1.isTest__c = true;
        doc1.Actualizar_contacto__c = false;
        doc1.Fecha_vencimiento__c = hoy;
        insert doc1;
        
        SST_Gestion_documentos__c doc2 = new SST_Gestion_documentos__c();
        doc2.contacto__c = contacto2.id;
        doc2.tipo_documento__c = 'DOC02';
		doc2.Fecha_vencimiento__c = hoy;
        doc2.isTest__c = true;
        doc2.Actualizar_contacto__c = false;
        insert doc2;   
        
        SST_Elemento_Proteccion_Personal__c epp = new SST_Elemento_Proteccion_Personal__c();
        epp.Codigo__c = '001';
        epp.Name = 'EPP';
        epp.Zona_proteccion__c = 'PIES';
        epp.Estado__c = SST_Constantes.ACTIVO;
        epp.Vida_util__c = 1;
        insert epp;
        
        SST_Cargo_EPP__c cargoEPP = New SST_Cargo_EPP__c();
        cargoEPP.Cargo__c = cargoFuncionario.id;
        cargoEPP.Elemento_Proteccion_Personal__c = epp.id;
        insert cargoEPP;
        
        SST_Control_EPP__c entregaEPP = new SST_Control_EPP__c();
        entregaEPP.Funcionario__c = funcionario.id;
        entregaEPP.Elemento_proteccion_personal__c = epp.id;
        entregaEPP.Cantidad__c = 1;
        entregaEPP.Fecha_entrega__c = hoy.addDays(-1);
        entregaEPP.Fecha_vencimiento__c = hoy;
        entregaEPP.Motivo_entrega__c = 'REPOSICION';
        entregaEPP.Descripcion__c = 'entrega epp';
        insert entregaEPP;
        
        SST_Control_EPP__c entregaEPConsulta = [select id, fecha_vencimiento__c from SST_Control_EPP__c where Motivo_entrega__c = 'REPOSICION'];
        entregaEPConsulta.Fecha_vencimiento__c = hoy.addDays(-1);
        update entregaEPConsulta;
        ID idPlanesProgramas = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosByName().get('Planes y Programas').getRecordTypeId();
        
        SST_Seguimiento__c seguimiento = new SST_Seguimiento__c();
        seguimiento.RecordTypeId = idPlanesProgramas;
        seguimiento.Name = 'Seguimiento 1';
        seguimiento.Objetivo__c = 'objetivo';
        seguimiento.Fecha_inicial__c = hoy.addDays(-5);
        seguimiento.Fecha_final__c = hoy;
        insert seguimiento;
        
        SST_Seguimiento__c seguimientoConsulta = [Select id, Fecha_final__c from SST_Seguimiento__c where Name = 'Seguimiento 1'];
        seguimientoConsulta.Fecha_final__c = hoy;
        update seguimientoConsulta;
        
        SST_Seguimiento__c seguimiento2 = new SST_Seguimiento__c();
        seguimiento2.RecordTypeId = idPlanesProgramas;
        seguimiento2.Name = 'Seguimiento 2';
        seguimiento2.Objetivo__c = 'objetivo';
        seguimiento2.Fecha_inicial__c = hoy.addDays(-5);
        seguimiento2.Fecha_final__c = hoy.addDays(5);
        insert seguimiento2;
        
        SST_Seguimiento__c seguimientoConsulta2 = [Select id, Fecha_final__c from SST_Seguimiento__c where Name = 'Seguimiento 2'];
        seguimientoConsulta2.Fecha_final__c = hoy;
        update seguimientoConsulta2;
        
        SST_Examen_ocupacional__c examen = new SST_Examen_ocupacional__c();
        examen.Tipo_examen__c = 'Ingreso';
        examen.fecha_examen__c = hoy.addDays(-5);
        examen.Resultado__c = 'APTO';
        examen.Accion__c = seguimientoConsulta2.id;
        examen.proximo_examen__c = hoy;
        examen.Funcionario_examen__c = funcionario.id;
        insert examen;
        
        SST_Examen_ocupacional__c examenConsulta = [select id, proximo_examen__c from SST_Examen_ocupacional__c where Funcionario_examen__c =: funcionario.id];
        examenConsulta.proximo_examen__c = hoy;
        update examenConsulta;
       
        SST_InactivacionRegistrosSchedulable schedulJob = new SST_InactivacionRegistrosSchedulable();
        String error = '<b>Tipo de registro: </b>'+'Gestión de documentos'+'<b> - Contacto: </b>'+'nombre1'+' - <b>Número del registro: </b>'+'nombre2'+' - <b>Tipo de documento: </b>'+'nombre3'+' - <b>Fecha de vencimiento: </b>'+'nombre4';
		List<String>listaErrores = new List<String>();
        listaErrores.add(error);
        Set<String> mailsEnviarSet = new Set<String>();
        String correo = 'usuario;'+funcionario.id;
		mailsEnviarSet.add(correo);
        System.assert(('usuario;'+funcionario.id) == correo);

        
        Map<Id,List<String>> mapa = new Map<Id,List<String>>();
        mapa.put(contacto2.id,listaErrores);
        
        schedulJob.EnviarNotificacion(listaErrores, mailsEnviarSet); 
        schedulJob.EnviarNotificacionInactivacionContactos(listaErrores, mailsEnviarSet);   
        schedulJob.EnviarNotificacionDocumentosPorVencer(mapa);  
        String sch = '0 55 14 * * ?';
        String jobID = system.schedule('Scheduled Job', sch, schedulJob);
        Test.stopTest();
    }
}