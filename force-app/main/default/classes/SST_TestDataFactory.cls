@IsTest
public class SST_TestDataFactory {
    public Static String returnEmpresa(){
        String empresa  =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;     
        return empresa;
    }
 
    public Static ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
	public Static ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();    

    public static Account crearCuenta(String empresa){
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_nit__c = Decimal.valueOf(returnEmpresa());
        //cuenta.SST_lector_cedulas__c = true;
        insert cuenta;
        return cuenta;
    }

    public static Contact crearFuncionario(Account cuenta, SST_Cargo__c cargoFuncionario){
        SST_Sede__c sede = crearSede();
        SST_Area_trabajo__c area = crearArea();
        
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
        contacto.Birthdate = Date.newInstance(1989,11,20);
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Cargo__c = cargoFuncionario.id;
        contacto.SST_Sede__c = sede.id;
        contacto.SST_Area_Trabajo__c = area.id;
        contacto.SST_Departamento__c = '5';
        contacto.SST_Municipio__c = '5002';
        contacto.sst_empresa__c = String.valueOf(cuenta.sst_nit__c);
        contacto.SST_Fecha_Ingreso__c = Date.newInstance(2011,11,20);
        insert contacto;
        return contacto;
    }  
    
       
    public static Contact crearContratista(Account cuenta){
                
        Contact contacto = New Contact();
        contacto.recordTypeId = idContratista;
        contacto.LastName='Pereira';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.Phone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Documentacion_contacto__c = 'DOC01';
        contacto.SST_retirado__c = false;
        contacto.sst_empresa__c = String.valueOf(cuenta.sst_nit__c);
        insert contacto;
        return contacto;
    }
    
    public static SST_Gestion_documentos__c crearDocumento(ID idContacto){
     	SST_Gestion_documentos__c documento = new SST_Gestion_documentos__c();
        documento.Actualizar_contacto__c = false;
        documento.tipo_documento__c = 'DOC14';
        documento.Contacto__c = idContacto;
        insert documento;
        return documento;
    }
    
    public static SST_Cargo__c crearCargoFuncionario(){
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        SST_Cargo__c cargoFuncionario = new SST_Cargo__c();
        cargoFuncionario.recordTypeId = idCargoFuncionario;
        cargoFuncionario.name = 'Cargo prueba';
        cargoFuncionario.Estado__c = 'ACTIVO';
        insert cargoFuncionario;
        return cargoFuncionario;
    }
    
    public static SST_Cargo__c crearCargoComite(){
        ID idCargoComite = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Comité').getRecordTypeId(); 
        SST_Cargo__c cargoComite = new SST_Cargo__c();
        cargoComite.recordTypeId = idCargoComite;
        cargoComite.name = 'Cargo comite prueba';
        insert cargoComite;
        return cargoComite;
    }
    
    public static SST_Sede__c crearSede(){
        SST_Sede__c sede = new SST_Sede__c();
        sede.Name = 'Sede prueba';
        sede.Departamento__c = '5';
        sede.Municipio__c = '5002';
        sede.Estado__c = SST_Constantes.ACTIVO;
        sede.Direccion__c = 'Direccion';
        sede.Zona__c = 'URBANA';
        insert sede;
        return sede;
    }
    
     public static SST_Area_trabajo__c crearArea(){
        SST_Area_trabajo__c area = new SST_Area_trabajo__c();
        area.Name = 'Area prueba';
        area.Estado__c = SST_Constantes.ACTIVO;
        insert area;
        return area;
    }

     public static SST_Registro_de_Novedades__c crearRegistroAccidente(ID idFuncionario){
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();    
 
		SST_Registro_de_Novedades__c accidente = New SST_Registro_de_Novedades__c();
        accidente.Investigacion__c ='SI';
        accidente.Tipo__c = 'GRAVE';
        accidente.numero_dias__c = 5;
        accidente.Fecha_Inicial__c = system.today();
        accidente.Consecuencia__c = 'Ninguna';
        accidente.Parte_Cuerpo_Afectada__c = '3.33';
        accidente.Agente_accidente__c = '1';
        accidente.Tipo_Lesion__c = '10';
        accidente.Mecanismo_forma_accidente__c = '1';
        accidente.Otro_Mecanismo_forma_del_accidente__c = null;
        accidente.Descripcion__c = 'Lorem ipsum dolor sit amet';
        accidente.Hora__c = '12:30';
        accidente.Jornada__c = 'Normal';
        accidente.Labor_habitual__c = 'SI';
        accidente.Tiempo_laborado__c = '04:30';
        accidente.Tipo_accidente__c = 'Violencia'; 
        accidente.Causo_muerte__c = 'NO';
        accidente.Zona__c = 'Urbana';
        accidente.Departamento__c = '11';
        accidente.Municipio__c = '11001';
        accidente.Nombre_completo_primera_persona__c = 'Carlos Javier Quintero';
        accidente.Nombre_completo_segunda_persona__c = 'Jhonnier Stiven Naranjo';
        accidente.Cargo_primer_persona__c = 'Practicante';
        accidente.Cargo_segunda_persona__c = 'Practicante';
        accidente.Lugar__c = 'Dentro';
        accidente.Cantidad_Horas__c = 4;
        accidente.Sitio__c = 'Escaleras';
        accidente.Funcionario__c = idFuncionario;
        accidente.RecordTypeId = accidentes;
        insert accidente;
        return accidente;
    }  

}