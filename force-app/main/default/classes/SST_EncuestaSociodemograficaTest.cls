@IsTest
public class SST_EncuestaSociodemograficaTest {
    static testMethod void SST_EncuestaSociodemograficaTest(){
        
        Date hoy = system.today();
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;     
        
        Account cuenta = new Account();
        cuenta.name = 'SST';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.SST_Estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_grupo_empresarial__c = 'Heinsohn';
        cuenta.SST_Link_encuesta_sociodemografica__c='www.link.com';
        cuenta.SST_Link_gestion_documental__c = 'www.link.com';
        insert cuenta;
        
        ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();
        
        Contact contacto2 = New Contact();
        contacto2.LastName='Perez';
        contacto2.FirstName='Mario';
        contacto2.Email='contacto2@hotmail.com';
        contacto2.SST_isActive__c='true';
        contacto2.SST_Tipo_Identificacion__c = 'C';
        contacto2.SST_Identificacion__c = '1230123';
        contacto2.RecordTypeId = idContratista;
        insert contacto2;
        
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
        insert area;
        
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Cargo__c cargoFuncionario = new SST_Cargo__c();
        cargoFuncionario.recordTypeId = idCargoFuncionario;
        cargoFuncionario.name = 'Cargo prueba';
        insert cargoFuncionario;
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
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
        contacto.RecordTypeId = idFuncionario;
        insert contacto;
        
        SST_EncuestaSociodemograficaCC controlador = new SST_EncuestaSociodemograficaCC();
        controlador.contacto.codigo = '';
        controlador.contacto.identificacion = '';
        controlador.consultarContacto();
        controlador.contacto.codigo = contacto2.id;
        controlador.contacto.identificacion = '1230-123';
        controlador.consultarContacto();
        controlador.contacto.codigo = contacto2.id;
        controlador.contacto.identificacion = '12301230123';
        controlador.consultarContacto();
        controlador.contacto.codigo = contacto2.id;
        controlador.contacto.identificacion = '1230123';
        controlador.consultarContacto();
        contacto.SST_Fecha_Retiro__c = hoy;
        contacto.SST_isActive__c='false';
        update contacto;
        controlador.contacto.codigo = contacto.id;
        controlador.contacto.identificacion = '1230';
        controlador.consultarContacto();
        
        contacto.SST_Fecha_Retiro__c = null;
        contacto.SST_isActive__c='true';
        contacto.birthdate = hoy.addYears(-20);
        contacto.SST_Genero__c = 'MASCULINO';
        contacto.SST_estado_civil__c = 'SOLTERO(A)';
        contacto.SST_Nivel_Escolaridad__c = 'BASICO';
        contacto.SST_etnia__c = 'NINGUNO';
        contacto.SST_estrato__c = '4';
        contacto.SST_Departamento__c = '63';
        contacto.SST_municipio__c='63001';
        contacto.SST_Tipo_Contrato__c = 'TEMPORAL';
        contacto.SST_EPS__c = '830113831';
        contacto.SST_ARL__c = '860002183';
        contacto.SST_Fondo_Pensiones__c = '800224808';
        contacto.SST_Fondo_Cesantias__c = '800224808';
        update contacto;
        
        SST_grupo_familiar__c familiar = new SST_grupo_familiar__c();
        familiar.funcionario__c = contacto.id;
        familiar.parentesco__c = 'MADRE';
        familiar.fecha_nacimiento__c = hoy.addYears(-40);
        familiar.Tipo_Documento__c = 'C';
        familiar.numero_identificacion__c = '147852';
        familiar.depende_economicamente__c = false;
        familiar.Genero__c = 'FEMENINO';
        familiar.nombre_completo__c = 'rosa diaz';
        insert familiar;
        
        SST_Encuesta_sociodemografica__c encuesta1 = new SST_Encuesta_sociodemografica__c();
        encuesta1.Fecha_inicio__c = hoy;
        encuesta1.Fecha_fin__c = hoy.addDays(1);
        encuesta1.descripcion__c = 'encuesta 1';
        insert encuesta1;
        
        controlador.contacto.codigo = contacto.id;
        controlador.contacto.identificacion = '1230';
        controlador.consultarContacto();
        

        
        controlador.infoContacto.consentimiento__c = SST_Constantes.ITEM_VACIO_PICKLIST;
        controlador.iniciarEncuesta();
        controlador.infoContacto.consentimiento__c = 'NO';
        controlador.iniciarEncuesta();
        controlador.irAtras();
        controlador.infoContacto.consentimiento__c = 'SI';
        controlador.iniciarEncuesta();
        
        controlador.contacto.Barrio = 'barrio';
        controlador.contacto.direccion = 'direccion';
        controlador.infoContacto.Tipo_vivienda__c = 'Propia';
        controlador.infoContacto.Deporte__c = 'No';
        controlador.infoContacto.fuma__c = 'No';
        controlador.infoContacto.consume_licor__c = 'No';
        controlador.infoContacto.LGTBI__c = '';
        contacto.SST_municipio__c = '5002';
        controlador.irAdelante();
        contacto.SST_municipio__c = '63001';
        controlador.irAdelante();
        controlador.infoContacto.Antiguedad__c = 'Menos de 1 año';
        controlador.infoContacto.Antiguedad_cargo__c = 'Menos de 1 año';
        controlador.infoContacto.Grupo_sindical__c = 'NO';
        controlador.infoContacto.experiencia__c = 'Menos de 1 año';
        controlador.infoContacto.Ingresos__c = '1 (S.M.L.V)';
        controlador.irAdelante();
        controlador.irAtras();
        controlador.irAdelante();
        
        List<SelectOption> temp = new List<SelectOption>();
        temp.add(new SelectOption('Motriz','Motriz'));
        
        List<SelectOption> temp2 = new List<SelectOption>();
        temp2.add(new SelectOption('Accidente laboral','Accidente laboral'));
        
        controlador.infoContacto.Personas_a_cargo__c = 'Ninguna';
        controlador.infoContacto.Cabeza_de_hogar__c = 'NO';
        controlador.infoContacto.Discapacidad__c = 'SI';
        controlador.infoContacto.Tratamiento_discapacidad__c = 'NO';
        controlador.tiposDiscapacidadSeleccionados = temp;
        controlador.infoContacto.Discapacidad_certificada__c = 'NO';
        controlador.irAdelante();
        controlador.irAtras();
        controlador.origenesDiscapacidadSeleccionados = temp2;
        controlador.irAdelante();
        controlador.irAtras();
        
        controlador.identifFamiliar = familiar.numero_identificacion__c;
        controlador.nombreFamiliar = familiar.nombre_completo__c;
        controlador.obtenerDatosFamiliar();
        controlador.familiar.Discapacidad__c = 'NO';
        controlador.fechaNacFamiliar = '12/12/2000';
        controlador.agregarFamiliar();
        
        controlador.identifFamiliar = '';
        controlador.nombreFamiliar = '';
        controlador.obtenerDatosFamiliar();
        
        controlador.familiar.parentesco__c = 'PADRE';
        controlador.fechaNacFamiliar = '12/12/2000';
        controlador.familiar.Tipo_Documento__c = 'C';
        controlador.familiar.numero_identificacion__c = '147852';
        controlador.familiarDependiente = 'SI';
        controlador.familiar.Genero__c = 'MASCULINO';
        controlador.familiar.nombre_completo__c = 'luis ruiz';
        controlador.familiar.Discapacidad__c = 'SI';
        controlador.familiar.Representante_legal__c = 'SI';
        controlador.familiar.trabajo__c = 'SI';
        controlador.familiar.Escolaridad__c = 'BASICO';
        controlador.familiar.Programa_gubernamental__c = 'programa';
        controlador.inicioBeneficioFamiliar = '11/12/2018';
        controlador.finBeneficioFamiliar = '10/12/2018';
        controlador.agregarFamiliar();
        controlador.familiar.Discapacidad__c = 'SI';
        controlador.finBeneficioFamiliar = '12/12/2018';
        controlador.discapacidadFamiliarSelec = temp;
        controlador.agregarFamiliar();
        
        controlador.identifFamiliar = familiar.numero_identificacion__c;
        controlador.nombreFamiliar = familiar.nombre_completo__c;
        controlador.obtenerDatosFamiliar();
        controlador.identifFamiliar = familiar.numero_identificacion__c;
        controlador.nombreFamiliar = familiar.nombre_completo__c;
        controlador.removerFamiliar();
        controlador.irAdelante();
        controlador.irAtras();
        controlador.irAdelante();
        controlador.actividadesBienestarSeleccionados.clear();
        controlador.irAdelante();
        
        List<SelectOption> temp3 = new List<SelectOption>();
        temp3.add(new SelectOption('Ninguna','Ninguna'));
        
        
        controlador.actividadesBienestarSeleccionados = temp3;
        controlador.irAdelante();
        controlador.cancelar();
        controlador.habilitarDepartamento();
        controlador.recargar();
        controlador.getTipoVivienda();
        controlador.getEstrato();
        controlador.getPeriodicidadFuma();
        controlador.getPeriodicidad();
        controlador.getPsnasACargo();
        controlador.getAntiguedad();
        controlador.getIngresos();
        controlador.getParentesco();
        
        controlador.contacto.codigo = contacto.id;
        controlador.contacto.identificacion = '1230';
        controlador.consultarContacto();
        controlador.guardar();
        
        Test.StartTest();
        SST_Encuesta_sociodemografica__c encuesta2 = new SST_Encuesta_sociodemografica__c();
        encuesta2.Fecha_inicio__c = hoy;
        encuesta2.Fecha_fin__c = hoy.addDays(1);
        encuesta2.descripcion__c = 'encuesta 2';
        insert encuesta2;
        
        controlador.contacto.codigo = contacto.id;
        controlador.contacto.identificacion = '1230';
        controlador.consultarContacto();
        controlador.infoContacto.consentimiento__c = 'NO';
        controlador.iniciarEncuesta();
        controlador.irAdelante();
        controlador.irAtras();
        controlador.infoContacto.consentimiento__c = 'SI';
        controlador.irAdelante();
        controlador.contacto.fechaNacimiento = hoy.addYears(-19);
        controlador.contacto.Genero = 'OTRO';
        System.assert(('OTRO') == controlador.contacto.Genero);
        controlador.contacto.escolaridad = 'MAESTRIA';
        controlador.contacto.etnia = 'OTRO';
        controlador.contacto.estrato = '6';
        controlador.irAdelante();
        controlador.irAdelante();
        controlador.contacto.tieneFamiliares = 'SI';
        controlador.irAdelante();
        controlador.irAdelante();
        controlador.irAtras();
        controlador.irAtras();
        //controlador.guardar();
        Test.StopTest();
    }
    
}