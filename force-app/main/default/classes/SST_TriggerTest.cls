@isTest
public class SST_TriggerTest {
    public static testMethod void SST_MultiselectController(){
        Test.StartTest();
        SST_MultiselectController multiselect = new SST_MultiselectController();
        
        Schema.DescribeFieldResult campo = SST_peligro__c.Nivel_deficiencia__c.getDescribe();
        
        List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
        List<SelectOption> lista = new List<SelectOption>();
        for( Schema.PicklistEntry pickItem : picklist){
            lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
        }   
        multiselect.leftOptions = lista;
        multiselect.rightOptions = lista;
        multiselect.leftOptionsHidden = '1';
        multiselect.rightOptionsHidden = '2';
        System.assert(('2') == multiselect.rightOptionsHidden); 
        Test.stopTest();
    }
    
    /*Método test para el trigger de epp*/
    public static testMethod void SST_EppTriggerTest(){
        Test.StartTest();
        SST_Elemento_proteccion_personal__c epp = new SST_Elemento_proteccion_personal__c();
        epp.codigo__c='EPP1';
        epp.descripcion__c ='Elemento proteccion';
        epp.vida_util__c =45;
        insert(epp);
        
        try{
            SST_Elemento_proteccion_personal__c epp2 = new SST_Elemento_proteccion_personal__c();
            epp2.codigo__c='EPP1';
            epp2.descripcion__c ='Elemento proteccion';
            epp2.vida_util__c =45;
            insert(epp2);
            
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un elemento con el Código') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        
        SST_Elemento_proteccion_personal__c epp2 = new SST_Elemento_proteccion_personal__c();
        epp2.codigo__c='EPP2';
        epp2.descripcion__c ='Elemento proteccion';
        epp2.vida_util__c =45;
        insert(epp2);
        
        epp.codigo__c='EPP3';
        update(epp);
        
        try{
            
            epp2.codigo__c='EPP3';
            update(epp2);
            
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un elemento con el Código') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        
        
        Test.stopTest();
    }
    
    //Método test para el trigger de Comités
    public static testMethod void SST_ComitesTriggerTest(){
        Test.StartTest();
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;     
        Date hoy = system.today();
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        SST_Sede__c sede = SST_TestDataFactory.crearSede();
        SST_Area_trabajo__c area = SST_TestDataFactory.crearArea();
        
        SST_Area_trabajo__c subarea = new SST_Area_trabajo__c();
        subarea.Name = 'Subarea prueba';
        subarea.Estado__c = SST_Constantes.ACTIVO;
        subarea.Area_padre__c = area.id;
        insert subarea;
        ID idCargoComite = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Comité').getRecordTypeId();     
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        SST_Cargo__c cargoComite = SST_TestDataFactory.crearCargoComite();
        
        SST_Cargo__c cargoComite2 = new SST_Cargo__c();
        cargoComite2.recordTypeId = idCargoComite;
        cargoComite2.name = 'Cargo comite prueba 2';
        insert cargoComite2;
        
        SST_Cargo__c cargoFuncionario2 = new SST_Cargo__c();
        cargoFuncionario2.recordTypeId = idCargoFuncionario;
        cargoFuncionario2.name = 'Cargo prueba 2';
        cargoFuncionario2.Cargo_padre__c = cargoFuncionario.id; 
        insert cargoFuncionario2;
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Perez';
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
        contacto2.SST_Cargo__c = cargoFuncionario.id;
        contacto2.SST_Sede__c = sede.id;
        contacto2.SST_Area_Trabajo__c = area.id;
        contacto2.SST_Departamento__c = '5';
        contacto2.SST_Municipio__c = '5002';
        insert contacto2;
        
        SST_Comites__c comite = new SST_Comites__c();
        comite.nombre__c = 'CONVIVENCIA';
        comite.fecha_inicio__c = hoy.addDays(-5);
        comite.fecha_fin__c = hoy.addDays(30);
        comite.Cantidad_representantes__c = 1;
        comite.Sede__c = sede.id;
        comite.empresa__c = empresa;
        insert comite;
        
        Datetime ahora = system.now();
        
        Event evento = new Event();
        evento.Subject = 'Meeting';
        evento.StartDateTime = ahora;
        evento.EndDateTime = ahora.addDays(10);
        evento.OwnerId = userInfo.getUserId();
        evento.WhoId = contacto.id;
        evento.WhatId = comite.id;
        insert evento;
        
        SST_Comites__c comite2 = new SST_Comites__c();
        comite2.nombre__c = 'COPASST';
        comite2.fecha_inicio__c = hoy;
        comite2.fecha_fin__c = hoy.addDays(30);
        comite2.Cantidad_representantes__c = 2;
        comite2.Sede__c = sede.id;
        comite2.empresa__c = empresa;
        insert comite2;
        
        SST_Funcionarios_Comites__c miembro = new SST_Funcionarios_Comites__c();
        miembro.Comite__c = comite.id;
        miembro.Fecha_nombramiento__c = hoy.addDays(-2);
        miembro.Representante_de__c = 'EMPLEADOR';
        miembro.Titularidad__c = 'PRINCIPAL';
        miembro.Cargo_comite__c = cargoComite.Id;
        miembro.Funcionario__c = contacto.id;
        insert miembro;
        
        try{
            SST_Comites__c comite3 = new SST_Comites__c();
            comite3.nombre__c = 'CONVIVENCIA';
            comite3.fecha_inicio__c = hoy;
            comite3.fecha_fin__c = hoy.addDays(30);
            comite3.Cantidad_representantes__c = 1;
            comite3.Sede__c = sede.id;
            comite3.empresa__c = empresa;
            insert comite3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un comité creado con el mismo nombre, para la misma sede y en la misma empresa.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            comite2.nombre__c = 'CONVIVENCIA';
            update comite2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un comité creado con el mismo nombre, para la misma sede y en la misma empresa') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        miembro.Fecha_terminacion__c = hoy.addDays(-1);
        update miembro;
        
        comite.fecha_fin__c = hoy.addDays(65);
        update comite;
        
        comite.fecha_inicio__c = hoy.addDays(31);
        comite.fecha_fin__c = hoy.addDays(61);
        update comite;
        
        SST_Comites__c comite4 = new SST_Comites__c();
        comite4.nombre__c = 'BRIGADA CONTRA INCENDIOS';
        comite4.fecha_inicio__c = hoy;
        comite4.fecha_fin__c = hoy.addDays(30);
        comite4.Cantidad_representantes__c = 1;
        comite4.Sede__c = sede.id;
        comite4.empresa__c = empresa;
        insert comite4;
        
        SST_Funcionarios_Comites__c miembro2 = new SST_Funcionarios_Comites__c();
        miembro2.Comite__c = comite4.id;
        miembro2.Fecha_nombramiento__c = hoy;
        miembro2.Representante_de__c = 'EMPLEADOR';
        miembro2.Titularidad__c = 'PRINCIPAL';
        miembro2.Cargo_comite__c = cargoComite.Id;
        miembro2.Funcionario__c = contacto.id;
        insert miembro2;
        
        try{
            comite4.Cantidad_representantes__c = 0;
            update comite4;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('La cantidad de representantes indicada es menor a la cantidad de funcionarios asignados.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Método test para el trigger de Áreas de Trabajo
    public static testMethod void SST_AreaTrabajoTrigger(){
        Test.StartTest();
        SST_Area_trabajo__c area = SST_TestDataFactory.crearArea();
        
        SST_Area_trabajo__c subarea = new SST_Area_trabajo__c();
        subarea.Name = 'Subarea prueba';
        subarea.Estado__c = SST_Constantes.ACTIVO;
        subarea.Area_padre__c = area.id;
        insert subarea;
        
        try{
            area.Estado__c = SST_Constantes.INACTIVO;
            area.Name = 'Subarea prueba';
            update area;
        } catch(Exception e){
            System.assertEquals(e.getMessage().contains('tiene subáreas asociadas en estado activo, debe inactivar las subáreas antes de inactivar el área padre')||e.getMessage().contains('Permisos'), true);
        }
        
        
        try{
            delete area;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El área tiene las siguientes subárea asociadas:') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }     
        Test.stopTest();
    }
    
    //Método test para el trigger de Normatividad
    public static testMethod void SST_NormatividadTrigger(){
        Test.StartTest();
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        SST_Normatividad__c normatividad = New SST_Normatividad__c();
        normatividad.name = 'Normatividad';
        normatividad.articulo__c = 'Articulo 4';
        normatividad.empresa__c = empresa;
        normatividad.Entidad__c = 'E-039';
        normatividad.Tipo__c = 'ACUERDO';
        insert normatividad;
        
        SST_Normatividad__c normatividad2 = New SST_Normatividad__c();
        normatividad2.name = 'Normatividad 2';
        normatividad2.articulo__c = 'Articulo 5';
        normatividad2.empresa__c = empresa;
        normatividad2.Entidad__c = 'E-053';
        normatividad2.Tipo__c = 'LEY';
        insert normatividad2;
        
        try{
            SST_Normatividad__c normatividad3 = New SST_Normatividad__c();
            normatividad3.name = 'Normatividad'; 
            normatividad3.articulo__c = 'Articulo 4';
            normatividad3.empresa__c = empresa;
            normatividad3.Entidad__c = 'E-008';
            normatividad3.Tipo__c = 'DECRETO';
            insert normatividad3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una Normatividad con el nombre') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            normatividad2.name = 'Normatividad'; 
            normatividad2.articulo__c = 'Articulo 4';
            update normatividad2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una Normatividad con el nombre') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    
    //Método test para el trigger de Seguimiento
    public static testMethod void SST_SeguimientoTrigger(){
        Test.StartTest();
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        SST_Seguimiento__c seguimiento = New SST_Seguimiento__c();
        seguimiento.Name = 'Seguimiento';
        seguimiento.empresa__c = empresa;
        seguimiento.Objetivo__c = 'Objetivo';
        insert seguimiento;
        
        SST_Seguimiento__c seguimiento2 = New SST_Seguimiento__c();
        seguimiento2.Name = 'Seguimiento2';
        seguimiento2.empresa__c = empresa;
        seguimiento2.Objetivo__c = 'Objetivo2'; 
        insert seguimiento2;
        
        try{
            SST_Seguimiento__c seguimiento3 = New SST_Seguimiento__c();
            seguimiento3.name = 'Seguimiento'; 
            seguimiento3.Objetivo__c = 'Objetivo3';
            insert seguimiento3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un Seguimiento con el nombre') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            seguimiento2.name = 'Seguimiento'; 
            update seguimiento2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un Seguimiento con el nombre') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
    }
    
    //Método test para el trigger de Cargos
    public static testMethod void SST_CargoTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        ID idCargoComite = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Comité').getRecordTypeId();     
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        
        SST_Cargo__c cargoComite = SST_TestDataFactory.crearCargoComite();
        
        SST_Cargo__c cargoComite2 = new SST_Cargo__c();
        cargoComite2.recordTypeId = idCargoComite;
        cargoComite2.name = 'Cargo comite prueba 2';
        insert cargoComite2;
        
        SST_Cargo__c cargoFuncionario2 = new SST_Cargo__c();
        cargoFuncionario2.recordTypeId = idCargoFuncionario;
        cargoFuncionario2.name = 'Cargo prueba 2';
        cargoFuncionario2.Cargo_padre__c = cargoFuncionario.id;
        cargoFuncionario2.Estado__c = 'ACTIVO';
        insert cargoFuncionario2;
        
        try{
            cargoFuncionario2.Name = 'Cargo prueba';
            update cargoFuncionario2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un cargo con el Tipo de Registro') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            cargoFuncionario.estado__c = 'INACTIVO';
            update cargoFuncionario;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('tiene subcargos asociados en estado Activo') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        SST_Sede__c sede = SST_TestDataFactory.crearSede();
        
        SST_Area_trabajo__c area = SST_TestDataFactory.crearArea();
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
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
        contacto2.SST_Cargo__c = cargoFuncionario2.id;
        contacto2.SST_Sede__c = sede.id;
        contacto2.SST_Area_Trabajo__c = area.id;
        contacto2.SST_Departamento__c = '5';
        contacto2.SST_Municipio__c = '5002';
        insert contacto2;
        
        try{
            cargoFuncionario2.estado__c = 'INACTIVO';
            update cargoFuncionario2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('está asociado a funcionarios Activos') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            SST_Cargo__c cargoFuncionario3 = new SST_Cargo__c();
            cargoFuncionario3.recordTypeId = idCargoFuncionario;
            cargoFuncionario3.name = 'Cargo prueba';
            insert cargoFuncionario3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un cargo con el Tipo de Registro') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            delete cargoFuncionario;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El cargo tiene los siguientes subcargos asociados') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();    
    }
    
    //Método test para el trigger de Procesos
    public static testMethod void SST_ProcesoTrigger(){
        Test.StartTest();
        SST_Proceso__c proceso = new SST_Proceso__c();
        proceso.name = 'Proceso prueba';
        proceso.Estado__c = SST_Constantes.ACTIVO;
        insert proceso;
        
        SST_Proceso__c subproceso = new SST_Proceso__c();
        subproceso.name = 'Subroceso prueba';
        subproceso.Estado__c = SST_Constantes.ACTIVO;
        subproceso.Proceso_padre__c = proceso.id;
        insert subproceso;
        
        SST_Proceso__c subproceso2 = new SST_Proceso__c();
        subproceso2.name = 'Subroceso prueba 2';
        subproceso2.Estado__c = SST_Constantes.ACTIVO;
        subproceso2.Proceso_padre__c = proceso.id;
        insert subproceso2;
        
        try{
            proceso.Estado__c = SST_Constantes.INACTIVO;
            proceso.name = 'Subroceso prueba';
            update proceso;
        } catch(Exception e){
            
            System.assertEquals(e.getMessage().contains('tiene subprocesos asociados en estado activo, debe inactivor los subprocesos antes de inactivar el proceso padre')||e.getMessage().contains('Permisos'), true);
        }
        
        try{
            delete proceso;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El proceso tiene los siguientes subprocesos asociados:') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Método test para el trigger de Funcionarios Comités
    public static testMethod void SST_FuncionariosComitesTrigger(){
        Test.StartTest();
        Date hoy = system.today();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        SST_Sede__c sede = new SST_Sede__c();
        sede.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        sede.Name = 'Sede prueba';
        sede.Departamento__c = '5';
        sede.Municipio__c = '5002';
        sede.Estado__c = SST_Constantes.ACTIVO;
        sede.Direccion__c = 'Direccion';
        sede.Zona__c = 'URBANA';
        insert Sede;
        
        SST_Area_trabajo__c area = new SST_Area_trabajo__c();
        area.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        area.Name = 'Area prueba';
        area.Estado__c = SST_Constantes.ACTIVO;
        insert area;
        
        SST_Area_trabajo__c subarea = new SST_Area_trabajo__c();
        subarea.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        subarea.Name = 'Subarea prueba';
        subarea.Estado__c = SST_Constantes.ACTIVO;
        subarea.Area_padre__c = area.id;
        insert subarea;
        
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();
        ID idCargoComite = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Comité').getRecordTypeId();
        
        SST_Cargo__c cargoFuncionario = new SST_Cargo__c();
        cargoFuncionario.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        cargoFuncionario.recordTypeId = idCargoFuncionario;
        cargoFuncionario.name = 'Cargo prueba';
        insert cargoFuncionario;
        
        SST_Cargo__c cargoComite = new SST_Cargo__c();
        cargoComite.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        cargoComite.recordTypeId = idCargoComite;
        cargoComite.name = 'Cargo comite prueba';
        insert cargoComite;
        
        SST_Cargo__c cargoComite2 = new SST_Cargo__c();
        cargoComite2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        cargoComite2.recordTypeId = idCargoComite;
        cargoComite2.name = 'Cargo comite prueba 2';
        insert cargoComite2;
        
        SST_Cargo__c cargoFuncionario2 = new SST_Cargo__c();
        cargoFuncionario2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        cargoFuncionario2.recordTypeId = idCargoFuncionario;
        cargoFuncionario2.name = 'Cargo prueba 2';
        cargoFuncionario2.Cargo_padre__c = cargoFuncionario.id;
        insert cargoFuncionario2;
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.SST_Empresa__c = String.valueOf(cuenta.SST_nit__c);
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Perez';
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
        contacto.SST_Fecha_Ingreso__c = hoy.addMonths(-1);
        insert contacto;
        
        Contact contacto2 = New Contact();
        contacto2.SST_Empresa__c = String.valueOf(cuenta.SST_nit__c);
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
        contacto2.SST_Cargo__c = cargoFuncionario.id;
        contacto2.SST_Sede__c = sede.id;
        contacto2.SST_Area_Trabajo__c = area.id;
        contacto2.SST_Departamento__c = '5';
        contacto2.SST_Municipio__c = '5002'; 
        contacto2.SST_Fecha_Ingreso__c = hoy.addMonths(-1);
        insert contacto2;
        
        SST_Comites__c comite = new SST_Comites__c();
        comite.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        comite.nombre__c = 'CONVIVENCIA';
        comite.fecha_inicio__c = hoy.addMonths(-2);
        comite.fecha_fin__c = hoy.addDays(30);
        comite.Cantidad_representantes__c = 1;
        comite.Sede__c = sede.id;
        insert comite;
        
        SST_Comites__c comite2 = new SST_Comites__c();
        comite2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        comite2.nombre__c = 'COPASST';
        comite2.fecha_inicio__c = hoy.addMonths(-2);
        comite2.fecha_fin__c = hoy.addDays(30);
        comite2.Cantidad_representantes__c = 1;
        comite2.Sede__c = sede.id;
        insert comite2;
        
        SST_Funcionarios_Comites__c miembro = new SST_Funcionarios_Comites__c();
        miembro.Comite__c = comite.id;
        miembro.Fecha_nombramiento__c = hoy.addDays(-20);
        miembro.Representante_de__c = 'EMPLEADOR';
        miembro.Titularidad__c = 'PRINCIPAL';
        miembro.Cargo_comite__c = cargoComite.Id;
        miembro.Funcionario__c = contacto.id;
        insert miembro;
        
        SST_Funcionarios_Comites__c miembro2 = new SST_Funcionarios_Comites__c();
        miembro2.Comite__c = comite2.id;
        miembro2.Fecha_nombramiento__c = hoy.addDays(-20);
        miembro2.Representante_de__c = 'EMPLEADOR';
        miembro2.Titularidad__c = 'PRINCIPAL';
        miembro2.Cargo_comite__c = cargoComite2.Id;
        miembro2.Funcionario__c = contacto2.id;
        insert miembro2;
        
        try{
            SST_Funcionarios_Comites__c miembro3 = new SST_Funcionarios_Comites__c();
            miembro3.Comite__c = comite.id;
            miembro3.Fecha_nombramiento__c = hoy.addDays(-30);
            miembro3.Representante_de__c = 'EMPLEADOR';
            miembro3.Titularidad__c = 'PRINCIPAL';
            miembro3.Cargo_comite__c = cargoComite.Id;
            miembro3.Funcionario__c = contacto.id;
            insert miembro3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('La fecha de nombramiento debe estar dentro del periodo de vigencia del comité:') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        try{
            SST_Funcionarios_Comites__c miembro3 = new SST_Funcionarios_Comites__c();
            miembro3.Comite__c = comite.id;
            miembro3.Fecha_nombramiento__c = hoy.addYears(1);
            miembro3.Representante_de__c = 'EMPLEADOR';
            miembro3.Titularidad__c = 'PRINCIPAL';
            miembro3.Cargo_comite__c = cargoComite.Id;
            miembro3.Funcionario__c = contacto.id;
            miembro3.Fecha_terminacion__c = hoy.addDays(-1);
            insert miembro3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Para nuevas asociaciones, la fecha de terminación debe quedar en blanco') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        try{
            SST_Funcionarios_Comites__c miembro3 = new SST_Funcionarios_Comites__c();
            miembro3.Comite__c = comite.id;
            miembro3.Fecha_nombramiento__c = hoy;
            miembro3.Representante_de__c = 'EMPLEADOR';
            miembro3.Titularidad__c = 'PRINCIPAL';
            miembro3.Cargo_comite__c = cargoComite.Id;
            miembro3.Funcionario__c = contacto.id;
            insert miembro3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El cargo ya se encuentra actualmente asignado dentro del comité con la misma titularidad') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        try{
            SST_Funcionarios_Comites__c miembro3 = new SST_Funcionarios_Comites__c();
            miembro3.Comite__c = comite.id;
            miembro3.Fecha_nombramiento__c = hoy;
            miembro3.Representante_de__c = 'EMPLEADOR';
            miembro3.Titularidad__c = 'SUPLENTE';
            miembro3.Cargo_comite__c = cargoComite.Id;
            miembro3.Funcionario__c = contacto2.id;
            insert miembro3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El funcionario ya tiene un cargo activo asignado dentro del comité') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        try{
            SST_Funcionarios_Comites__c miembro3 = new SST_Funcionarios_Comites__c();
            miembro3.Comite__c = comite.id;
            miembro3.Fecha_nombramiento__c = hoy.addYears(1);
            miembro3.Representante_de__c = 'EMPLEADOR';
            miembro3.Titularidad__c = 'PRINCIPAL';
            miembro3.Cargo_comite__c = cargoComite2.Id;
            miembro3.Funcionario__c = contacto2.id;
            insert miembro3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('La cantidad de funcionarios activos de titularidad') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            miembro2.Fecha_terminacion__c = hoy.addDays(-1);
            update miembro2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('La fecha de terminación debe ser mayor o igual a la fecha de nombramiento y menor o igual a la fecha fin del comité') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            miembro2.Fecha_Nombramiento__c = hoy.addYears(1);
            update miembro2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('La fecha de nombramiento debe ser mayor o igual a la fecha de inicio del comité') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            miembro.Funcionario__c = contacto2.id;
            update miembro;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El funcionario ya tiene un cargo activo asignado dentro del comité') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        comite.Cantidad_representantes__c = 2;
        update comite; 
        
        SST_Funcionarios_Comites__c miembro3 = new SST_Funcionarios_Comites__c();
        miembro3.Comite__c = comite2.id;
        miembro3.Fecha_nombramiento__c = hoy;
        miembro3.Representante_de__c = 'EMPLEADOR';
        miembro3.Titularidad__c = 'SUPLENTE';
        miembro3.Cargo_comite__c = cargoComite2.Id;
        miembro3.Funcionario__c = contacto.id;
        insert miembro3;
        
        try{
            miembro3.Cargo_comite__c = cargoComite.Id;
            miembro3.Titularidad__c = 'PRINCIPAL';
            update miembro3;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El cargo ya se encuentra actualmente asignado dentro del comité con la misma titularidad y en representación de la misma parte') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        contacto.SST_Fecha_Retiro__c = hoy;
        update contacto;
        Test.stopTest();
    }
    
    
    
    //Método test para el trigger de Evento
    public static testMethod void SST_EventTrigger(){
        Test.StartTest();
        Datetime ahora = system.now();
        Date hoy = system.today();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        SST_Normatividad__c norma = new SST_Normatividad__c();
        norma.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        norma.name = 'Norma test';
        norma.fecha_expedicion__c = system.today();
        norma.Tipo__c = 'ACUERDO';
        norma.Tema__c = 'tema';
        norma.Entidad__c = 'E-001';
        insert norma;
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.SST_Empresa__c = String.valueOf(cuenta.SST_nit__c);
        contacto.LastName='Perez';
        contacto.FirstName='Maria E';
        contacto.Email='contacto123@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '12301230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c = '5';
        contacto.SST_Municipio__c = '5002';
        contacto.recordTypeId = idFuncionario;
        contacto.SST_Fecha_Ingreso__c = hoy.addDays(-30);
        insert contacto;
        
        Contact funcionario2 = New Contact();
        funcionario2.SST_Empresa__c = String.valueOf(cuenta.SST_nit__c);
        funcionario2.LastName='Perez';
        funcionario2.FirstName='Pedro P';
        funcionario2.Email='contacto123123@hotmail.com';
        funcionario2.SST_isActive__c='true';
        funcionario2.SST_Tipo_Identificacion__c = 'C';
        funcionario2.SST_Identificacion__c = '123011230';
        funcionario2.MobilePhone = '3111234567';
        funcionario2.SST_Contacto_Emergencia__c = 'contacto';
        funcionario2.SST_Telefono_Emergencia__c = '123';
        funcionario2.SST_Departamento__c = '5';
        funcionario2.SST_Municipio__c = '5002';
        funcionario2.recordTypeId = idFuncionario;
        funcionario2.SST_Fecha_Ingreso__c = hoy.addDays(-30);
        insert funcionario2;
        
        ID idPlanes = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosByName().get('Planes y Programas').getRecordTypeId();
        
        SST_Seguimiento__c seguimientoPlan = new SST_Seguimiento__c();
        seguimientoPlan.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        seguimientoPlan.RecordTypeId = idPlanes;
        seguimientoPlan.Name = 'Seguimiento plan test';
        seguimientoPlan.Tipo__c = 'PL_002';
        seguimientoPlan.Fecha_inicial__c = system.today();
        seguimientoPlan.Fecha_final__c = system.today();
        seguimientoPlan.Objetivo__c = 'test plan';
        Insert seguimientoPlan;
        
        Event evento = new Event();
        evento.Subject = 'Meeting';
        evento.StartDateTime = ahora;
        evento.EndDateTime = ahora.addDays(10);
        evento.OwnerId = userInfo.getUserId();
        evento.WhoId = contacto.id;
        evento.WhatId = norma.id;
        insert evento;
        
        Event eventoSeguim = new Event();
        eventoSeguim.Subject = 'Meeting';
        eventoSeguim.StartDateTime = ahora;
        eventoSeguim.EndDateTime = ahora.addDays(10);
        eventoSeguim.OwnerId = userInfo.getUserId();
        eventoSeguim.WhoId = contacto.id;
        eventoSeguim.WhatId = seguimientoPlan.id;
        insert eventoSeguim;
        
        funcionario2.SST_Fecha_Retiro__c = system.today();
        funcionario2.SST_isActive__c='false';
        update funcionario2;
        
        try{
            Event evento2 = new Event();
            evento2.Subject = 'Meeting';
            evento2.StartDateTime = ahora;
            evento2.EndDateTime = ahora.addDays(1);
            evento2.OwnerId = userInfo.getUserId();
            evento2.WhoId = funcionario2.id;
            evento2.WhatId = norma.id;
            insert evento2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Sólo puede asociar funcionarios activos al evento.') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        SST_Normatividad__c normatividad = New SST_Normatividad__c();
        normatividad.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        normatividad.name ='Normatividad prueba';
        normatividad.id=normatividad.id;
        normatividad.Tipo__c ='LEY';
        normatividad.Fecha_expedicion__c=system.today();
        normatividad.Fuente__c='www.fuente.com';
        normatividad.Entidad__c ='E-008';
        normatividad.Tema__c='Tema de prueba';
        normatividad.Responsable__c='FUNCIONARIO';
        normatividad.Funcionario__c=contacto.id;
        normatividad.Cumplimiento__c='CUMPLE';
        normatividad.Observaciones__c='Observación de prueba';
        insert (normatividad);
        
        contacto.SST_Fecha_Retiro__c = system.today();
        contacto.SST_isActive__c='false';
        update contacto;
        Test.stopTest();
    }
    
    //Método test para el trigger de Tarea
    public static testMethod void SST_taskTrigger(){
        Test.StartTest();
        Date hoy = system.today();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        SST_Normatividad__c norma = new SST_Normatividad__c();
        norma.name = 'Norma';
        norma.fecha_expedicion__c = hoy;
        norma.Tipo__c = 'ACUERDO';
        norma.Tema__c = 'tema';
        norma.Entidad__c = 'E-001';
        insert norma;
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.LastName='Perez';
        contacto.FirstName='Maria E';
        contacto.Email='contacto123@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '12301230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c = '5';
        contacto.SST_Municipio__c = '5002';
        contacto.recordTypeId = idContratista;
        contacto.SST_Fecha_Ingreso__c = hoy.addDays(-30);
        insert contacto;
        
        Contact funcionario = New Contact();
        funcionario.LastName='Perez';
        funcionario.FirstName='Pedro P';
        funcionario.Email='contacto123123@hotmail.com';
        funcionario.SST_isActive__c='true';
        funcionario.SST_Tipo_Identificacion__c = 'C';
        funcionario.SST_Identificacion__c = '123011230';
        funcionario.MobilePhone = '3111234567';
        funcionario.SST_Contacto_Emergencia__c = 'contacto';
        funcionario.SST_Telefono_Emergencia__c = '123';
        funcionario.SST_Departamento__c = '5';
        funcionario.SST_Municipio__c = '5002';
        funcionario.recordTypeId = idFuncionario;
        insert funcionario;
        
        Task tarea = new Task();
        tarea.OwnerId = userInfo.getUserId();
        tarea.Subject = 'Otros';
        tarea.WhoId = funcionario.id;
        tarea.Priority = 'Normal';
        tarea.Status = 'No iniciada';
        tarea.ActivityDate = hoy.addDays(10);
        tarea.WhatId = norma.id;
        insert tarea;
        
        funcionario.SST_Fecha_Retiro__c = system.today();
        funcionario.SST_isActive__c='false';
        update funcionario;
        
        try{
            Task tarea2 = new Task();
            tarea2.OwnerId = userInfo.getUserId();
            tarea2.Subject = 'Otros';
            tarea2.WhoId = funcionario.id;
            tarea2.Priority = 'Normal';
            tarea2.Status = 'No iniciada';
            tarea2.ActivityDate = hoy.addDays(1);
            tarea2.WhatId = norma.id;
            insert tarea2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Sólo puede asociar funcionarios activos a la tarea.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            Task tarea2 = new Task();
            tarea2.OwnerId = userInfo.getUserId();
            tarea2.Subject = 'Otros';
            tarea2.WhoId = contacto.id;
            tarea2.Priority = 'Normal';
            tarea2.Status = 'No iniciada';
            tarea2.ActivityDate = hoy.addDays(1);
            tarea2.WhatId = norma.id;
            insert tarea2;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Sólo puede asociar funcionarios activos a la tarea.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        funcionario.SST_Fecha_Retiro__c = system.today();
        funcionario.SST_isActive__c='false';
        update funcionario;
        Test.stopTest();
    }
    
    //Método test para el trigger de Grupo Familiar
    public static testMethod void SST_GrupoFamiliarTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        insert cuenta;
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='5';
        
        insert contacto;
        
        SST_Grupo_familiar__c madre1 = new SST_Grupo_familiar__c();
        madre1.Funcionario__c=contacto.id;
        madre1.Nombre_completo__c='María';
        madre1.numero_identificacion__c='123';
        madre1.Parentesco__c='MADRE';
        insert madre1;
        
        SST_Grupo_familiar__c madre2 = new SST_Grupo_familiar__c();
        madre2.Funcionario__c=contacto.id;
        madre2.Nombre_completo__c='Mariana';
        madre2.numero_identificacion__c='1234';
        madre2.Parentesco__c='MADRE';
        insert madre2;
        
        try{
            SST_Grupo_familiar__c madre3 = new SST_Grupo_familiar__c();
            madre3.Funcionario__c=contacto.id;
            madre3.Nombre_completo__c='María del Carmen';
            madre3.numero_identificacion__c='1234';
            madre3.Parentesco__c='MADRE';
            insert madre3; 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene registrados miembros en su grupo familiar como') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }   
        
        try{
            SST_Grupo_familiar__c familiar1 = new SST_Grupo_familiar__c();
            familiar1.Funcionario__c=contacto.id;
            familiar1.Nombre_completo__c='María';
            familiar1.numero_identificacion__c='12345';
            familiar1.Parentesco__c='HIJO/A';
            insert familiar1;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene registrado un miembro en su grupo familiar con el mismo nombre') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            SST_Grupo_familiar__c familiar1 = new SST_Grupo_familiar__c();
            familiar1.Funcionario__c=contacto.id;
            familiar1.Nombre_completo__c='Mario';
            familiar1.numero_identificacion__c='123';
            familiar1.Parentesco__c='HIJO/A';
            insert familiar1;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene registrado un miembro en su grupo familiar con el mismo número de identificación') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        SST_Grupo_familiar__c familiar2 = new SST_Grupo_familiar__c();
        familiar2.Funcionario__c=contacto.id;
        familiar2.Nombre_completo__c='Mario';
        familiar2.numero_identificacion__c='123456';
        familiar2.Parentesco__c='HIJO/A';
        insert familiar2;
        
        try{
            familiar2.Parentesco__c = 'MADRE';
            update familiar2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene registrados miembros en su grupo familiar como') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            familiar2.Nombre_completo__c='María';
            update familiar2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene registrado un miembro en su grupo familiar con el mismo nombre') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            familiar2.numero_identificacion__c='123';
            update familiar2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene registrado un miembro en su grupo familiar con el mismo número de identificación') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
    }
    
    //Método test para el trigger de Hora Extra
    public static testMethod void SST_HoraExtraTrigger(){
        Test.StartTest();
        Schema.DescribeFieldResult fieldResultEmpresa = contact.SST_empresa__c.getDescribe();
        List<Schema.PicklistEntry> itemsTempEmpresa = fieldResultEmpresa.getPicklistValues();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        List <String> listaMeses = new List <String>();
        Schema.DescribeFieldResult fieldResult = SST_Hora_Extra__c.mes__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry tipoTemp : itemsTemp){
            listaMeses.add(tipoTemp.getValue());
        }
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='5';
        
        insert contacto;
        
        sst_hora_extra__c horaExtra = new sst_hora_extra__c();
        horaExtra.Funcionario__c = contacto.id;
        horaExtra.Mes__c = listaMeses.get(listaMeses.size()-1);
        horaExtra.Anio__c = 2018;
        horaExtra.Descripcion__c = 'prueba';
        horaExtra.Cantidad_horas__c = 5;
        insert horaExtra;
        
        try{
            SST_Hora_Extra__c hora2 = New SST_Hora_Extra__c();
            hora2.Funcionario__c=contacto.id;
            hora2.Mes__c=listaMeses.get(listaMeses.size()-1);
            hora2.Anio__c=2018;
            hora2.Descripcion__c='Esta es una prueba';
            hora2.Cantidad_horas__c=20;
            insert hora2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene horas extras registradas para el mes') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        } 
        
        SST_Hora_Extra__c hora3 = New SST_Hora_Extra__c();
        hora3.Funcionario__c=contacto.id;
        hora3.Mes__c=listaMeses.get(1);
        hora3.Anio__c=2018;
        hora3.Descripcion__c='Esta es una prueba';
        hora3.Cantidad_horas__c=20;
        insert hora3;
        
        try{
            hora3.Mes__c=listaMeses.get(listaMeses.size()-1);
            update hora3;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene horas extras registradas para el mes') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Método test para el trigger de Profesiograma
    public static testMethod void SST_ProfesiogramaTrigger(){
        Test.StartTest();
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        SST_Proceso__c proceso = New SST_Proceso__c();
        proceso.Name='Proceso prueba';
        proceso.Estado__c='ACTIVO';
        proceso.empresa__c = empresa;
        insert proceso;
        
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();
        
        SST_Cargo__c cargoFuncionario = new SST_Cargo__c();
        cargoFuncionario.recordTypeId = idCargoFuncionario;
        cargoFuncionario.name = 'Cargo prueba';
        cargoFuncionario.empresa__c = empresa;
        insert cargoFuncionario;
        
        SST_Profesiograma__c profesiograma = New SST_Profesiograma__c();
        profesiograma.Proceso__c=proceso.id;
        profesiograma.Cargo__c=cargoFuncionario.id;
        profesiograma.Tipo_examen__c='INGRESO';
        profesiograma.Examen__c='EX01';
        profesiograma.empresa__c = empresa;
        insert profesiograma;
        
        try{
            SST_Profesiograma__c profesiograma2 = New SST_Profesiograma__c();
            profesiograma2.Proceso__c=proceso.id;
            profesiograma2.Cargo__c=cargoFuncionario.id;
            profesiograma2.Tipo_examen__c='INGRESO';
            profesiograma2.Examen__c='EX01';
            profesiograma2.empresa__c = empresa;
            insert profesiograma2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un profesiograma para el cargo:') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        SST_Profesiograma__c profesiograma3 = New SST_Profesiograma__c();
        profesiograma3.Proceso__c=proceso.id;
        profesiograma3.Cargo__c=cargoFuncionario.id;
        profesiograma3.Tipo_examen__c='EGRESO';
        profesiograma3.Examen__c='EX01';
        profesiograma3.empresa__c = empresa;
        insert profesiograma3;
        
        try{
            profesiograma3.Tipo_examen__c='INGRESO';
            update profesiograma3;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un profesiograma para el cargo:') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Método test para el trigger de Gestion de Documentos
    public static testMethod void SST_GestionDocumentosTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.recordTypeId = idContratista;
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='5';        
        insert contacto;
        
        SST_Gestion_documentos__c documento = New SST_Gestion_documentos__c();
        documento.Contacto__c = contacto.id;
        documento.Tipo_documento__c = 'DOC01';
        documento.Fecha_vencimiento__c = system.today();
        insert documento;
        
        try{
            SST_Gestion_documentos__c documento2 = New SST_Gestion_documentos__c();
            documento2.Contacto__c = contacto.id;
            documento2.Tipo_documento__c = 'DOC01';
            documento2.Fecha_vencimiento__c = date.newinstance(2019, 01, 01);
            insert documento2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene registrado un documento de tipo') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        SST_Gestion_documentos__c documento3 = New SST_Gestion_documentos__c();
        documento3.Contacto__c = contacto.id;
        documento3.Tipo_documento__c = 'DOC02';
        insert documento3;
        
        try{
            documento3.Tipo_documento__c = 'DOC01';
            update documento3;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El contacto ya tiene registrado un documento de tipo') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        SST_Gestion_documentos__c documento4 = New SST_Gestion_documentos__c();
        documento4.Contacto__c = contacto.id;
        documento4.Tipo_documento__c = 'DOC03';
        insert documento4;
        
        documento4.Fecha_vencimiento__c = system.today();
        update documento4;
        
        delete documento3;
        
        Test.stopTest();
    }
    
    //Método test para el trigger de Registro de Documentos
    public static testMethod void SST_RegistroNovedadesTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='5';
        insert contacto;
        
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();
        
        SST_Diagnostico_CIE10__c cie= new SST_Diagnostico_CIE10__c();
        cie.Name = 'A040';
        cie.codigo_externo__c = 'A040';
        cie.Nombre_diagnostico__c = 'nada';
        insert cie;
        
        SST_Registro_de_Novedades__c novedad = New SST_Registro_de_Novedades__c();
        novedad.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        novedad.Funcionario__c=contacto.id;
        novedad.recordTypeId = incapacidades;
        novedad.Tipo__c = 'AMBULATORIA';
        novedad.Cantidad_Horas__c = 5;
        novedad.Fecha_Inicial__c = date.newinstance(2018, 09, 01);
        novedad.Fecha_Final__c =date.newinstance(2018, 10, 01);
        novedad.Descripcion__c = 'prueba';
        insert novedad;
        
        Datetime ahora = system.now();
        
        Event eventoNovedad = new Event();
        eventoNovedad.Subject = 'Meeting';
        eventoNovedad.StartDateTime = ahora;
        eventoNovedad.EndDateTime = ahora.addDays(10);
        eventoNovedad.OwnerId = userInfo.getUserId();
        eventoNovedad.WhoId = contacto.id;
        eventoNovedad.WhatId = novedad.id;
        insert eventoNovedad;
        
        SST_Registro_de_Novedades__c nov = [select id, tipo__c, diagnostico_cie10__c, diagnostico_cie10__r.name from SST_Registro_de_Novedades__c where Tipo__c = 'AMBULATORIA'];
        
        try{
            SST_Registro_de_Novedades__c novedad2 = New SST_Registro_de_Novedades__c();
            novedad2.Funcionario__c=contacto.id;
            novedad2.recordTypeId = incapacidades;
            novedad2.Tipo__c = 'AMBULATORIA';
            novedad2.Cantidad_Horas__c = 300;
            novedad2.Fecha_Inicial__c = date.newinstance(2018, 09, 01);
            novedad2.Fecha_Final__c =date.newinstance(2018, 09, 20);
            novedad2.Descripcion__c = 'prueba';
            insert novedad2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(' ya tiene un ausentismo, incapacidad o licencia registrada en el rango de fechas ') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        SST_Registro_de_Novedades__c novedad4 = New SST_Registro_de_Novedades__c();
        novedad4.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        novedad4.Funcionario__c=contacto.id;
        novedad4.recordTypeId = ausentismos;
        novedad4.Tipo__c = 'PERMISO';
        novedad4.Cantidad_Horas__c = 5;
        novedad4.Fecha_Inicial__c = date.newinstance(2018, 11, 01);
        novedad4.Fecha_Final__c =date.newinstance(2018, 12, 01);
        novedad4.Descripcion__c = 'prueba';
        insert novedad4;
        
        try{
            SST_Registro_de_Novedades__c novedad5 = New SST_Registro_de_Novedades__c();
            novedad5.Empresa__c = String.valueOf(cuenta.SST_nit__c);
            novedad5.Funcionario__c=contacto.id;
            novedad5.recordTypeId = ausentismos;
            novedad5.Tipo__c = 'PERMISO';
            novedad5.Cantidad_Horas__c = 300;
            novedad5.Fecha_Inicial__c = date.newinstance(2020, 11, 01);
            novedad5.Fecha_Final__c =null;
            novedad5.Descripcion__c = 'prueba';
            insert novedad5;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('excede el tiempo total de ausentismo permitido por día') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        
        SST_Registro_de_Novedades__c novedad3 = New SST_Registro_de_Novedades__c();
        novedad3.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        novedad3.Funcionario__c=contacto.id;
        novedad3.recordTypeId = ausentismos;
        novedad3.Tipo__c = 'PERMISO';
        novedad3.Cantidad_Horas__c = 5;
        novedad3.Fecha_Inicial__c = date.newinstance(2019, 09, 01);
        novedad3.Fecha_Final__c =date.newinstance(2019, 09, 02);
        novedad3.Descripcion__c = 'prueba';
        insert novedad3;
        
        try{
            novedad3.Fecha_Inicial__c = date.newinstance(2018, 09, 01);
            novedad3.Fecha_Final__c =date.newinstance(2018, 10, 01);
            update novedad3;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya tiene un ausentimo, incapacidad o licencia registrada en el rango de fechas') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Método test para el trigger de Seguimiento Sede
    public static testMethod void SST_SeguimientoSedeTrigger(){
        Test.StartTest();
        ID idAuditorias = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosByName().get('Auditorías').getRecordTypeId();
        ID idPlanes = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosByName().get('Planes y Programas').getRecordTypeId();
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        SST_Seguimiento__c seguimientoPlan = new SST_Seguimiento__c();
        seguimientoPlan.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        seguimientoPlan.RecordTypeId = idPlanes;
        seguimientoPlan.Name = 'Seguimiento plan';
        seguimientoPlan.Tipo__c = 'PL_002';
        seguimientoPlan.Fecha_inicial__c = system.today();
        seguimientoPlan.Fecha_final__c = system.today();
        seguimientoPlan.Objetivo__c = 'test plan';
        Insert seguimientoPlan;
        
        SST_Seguimiento__c seguimientoPlan2 = new SST_Seguimiento__c();
        seguimientoPlan2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        seguimientoPlan2.RecordTypeId = idPlanes;
        seguimientoPlan2.Name = 'Seguimiento plan 2';
        seguimientoPlan2.Tipo__c = 'PL_002';
        seguimientoPlan2.Fecha_inicial__c = system.today();
        seguimientoPlan2.Fecha_final__c = system.today();
        seguimientoPlan2.Objetivo__c = 'test plan 2';
        Insert seguimientoPlan2;
        
        SST_Seguimiento__c seguimientoAuditoria = new SST_Seguimiento__c();
        seguimientoAuditoria.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        seguimientoAuditoria.RecordTypeId = idPlanes;
        seguimientoAuditoria.Name = 'Seguimiento auditoria';
        seguimientoAuditoria.Tipo__c = 'PL_004';
        seguimientoAuditoria.Fecha_inicial__c = system.today();
        seguimientoAuditoria.Fecha_final__c = system.today();
        seguimientoAuditoria.Objetivo__c = 'test auditoria';
        Insert seguimientoAuditoria;
        
        SST_Seguimiento__c seguimientoAuditoria2 = new SST_Seguimiento__c();
        seguimientoAuditoria2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        seguimientoAuditoria2.RecordTypeId = idAuditorias;
        seguimientoAuditoria2.Name = 'Seguimiento auditoria 2';
        seguimientoAuditoria2.Fecha_inicial__c = system.today();
        seguimientoAuditoria2.Fecha_final__c = system.today();
        seguimientoAuditoria2.Objetivo__c = 'test auditoria 2';
        Insert seguimientoAuditoria2;
        
        SST_sede__c sede = new SST_sede__c();
        sede.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        sede.name = 'sede';
        sede.Departamento__c = '5';
        sede.Municipio__c = '5002';
        sede.Direccion__c = 'direccion';
        sede.Zona__c = 'URBANA';
        sede.Estado__c = SST_Constantes.ACTIVO;
        Insert sede;
        
        SST_Seguimiento_sede__c asociacion = new SST_Seguimiento_sede__c();
        asociacion.seguimiento__c = seguimientoPlan.id;
        asociacion.Sede__c = sede.Id;
        insert asociacion;
        
        try{
            SST_Seguimiento_sede__c asociacion2 = new SST_Seguimiento_sede__c();
            asociacion2.seguimiento__c = seguimientoPlan2.id;
            asociacion2.Sede__c = sede.Id;
            insert asociacion2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya está asociada a un seguimiento de tipo') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        try{
            SST_Seguimiento_sede__c asociacionAuditoria = new SST_Seguimiento_sede__c();
            asociacionAuditoria.seguimiento__c = seguimientoAuditoria.id;
            asociacionAuditoria.Sede__c = sede.Id;
            insert asociacionAuditoria;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya está asociada al seguimiento') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Método test para el trigger de Cargo Formación
    public static testMethod void SST_FormacionCargoTrigger(){
        Test.StartTest();
        ID idEntrenamiento = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Entrenamientos').getRecordTypeId();
        ID idResponsabilidadesCargos = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();
        ID idResponsabilidadesComites = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades comités').getRecordTypeId();
        ID idCompetencia = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Competencias').getRecordTypeId();
        ID idCargoComite = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Comité').getRecordTypeId();     
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Formacion__c formacion = new SST_Formacion__c();
        formacion.RecordTypeId = idEntrenamiento;
        formacion.Nombre__c = 'entrenamiento de prueba';
        insert formacion;
        
        SST_Formacion__c formacion2 = new SST_Formacion__c();
        formacion2.RecordTypeId = idEntrenamiento;
        formacion2.Nombre__c = 'entrenamiento de prueba 2';
        insert formacion2;
        
        SST_Formacion__c formacionResponsabilidadComite = new SST_Formacion__c();
        formacionResponsabilidadComite.RecordTypeId = idResponsabilidadesComites;
        formacionResponsabilidadComite.Nombre__c = 'Responsabilidad de Comité de Prueba';
        insert formacionResponsabilidadComite;
        
        SST_Formacion__c formacionResponsabilidadComite2 = new SST_Formacion__c();
        formacionResponsabilidadComite2.RecordTypeId = idResponsabilidadesComites;
        formacionResponsabilidadComite2.Nombre__c = 'Responsabilidad de Comité de Prueba 2';
        insert formacionResponsabilidadComite2;
        
        SST_Formacion__c formacionResponsabilidadCargo = new SST_Formacion__c();
        formacionResponsabilidadCargo.RecordTypeId = idResponsabilidadesCargos;
        formacionResponsabilidadCargo.Nombre__c = 'Responsabilidad Cargo de Prueba';
        insert formacionResponsabilidadCargo;
        
        SST_Formacion__c formacionCompetencia = new SST_Formacion__c();
        formacionCompetencia.RecordTypeId = idCompetencia;
        formacionCompetencia.Nombre__c = 'Este es un texto largo para realizar una prueba de una formación tipo competencia de más de 80 caracteres';
        formacionCompetencia.competencias__c = 'Comportamental';
        insert formacionCompetencia;
        
        SST_Cargo__c cargoFuncionario = new SST_Cargo__c();
        cargoFuncionario.recordTypeId = idCargoFuncionario;
        cargoFuncionario.name = 'Cargo prueba';
        cargoFuncionario.Estado__c = 'ACTIVO';
        insert cargoFuncionario;
        
        SST_Cargo__c cargoComite = new SST_Cargo__c();
        cargoComite.recordTypeId = idCargoComite;
        cargoComite.name = 'Cargo comité prueba';
        cargoComite.Estado__c = 'ACTIVO';
        insert cargoComite;
        
        SST_Formacion_Cargo__c formacionCargo = New SST_Formacion_Cargo__c();
        formacionCargo.Cargo__c = cargoFuncionario.id;
        formacionCargo.Formacion__c = formacion.id;
        insert formacionCargo;
        
        SST_Formacion_Cargo__c formacionCargo2 = New SST_Formacion_Cargo__c();
        formacionCargo2.Cargo__c = cargoFuncionario.id;
        formacionCargo2.Formacion__c = formacionResponsabilidadCargo.id;
        insert formacionCargo2;
        
        SST_Formacion_Cargo__c formacionCargo3 = New SST_Formacion_Cargo__c();
        formacionCargo3.Cargo__c = cargoFuncionario.id;
        formacionCargo3.Formacion__c = formacionCompetencia.id;
        insert formacionCargo3;
        
        SST_Formacion_Cargo__c formacionCargo4 = New SST_Formacion_Cargo__c();
        formacionCargo4.Cargo__c = cargoComite.id;
        formacionCargo4.Formacion__c = formacionResponsabilidadComite.id;
        formacionCargo4.name = cargoComite.name + SST_Constantes.RESPONSABILIDAD_CARGO+': '+formacionResponsabilidadComite2.Nombre__c;
        insert formacionCargo4;
        
        System.assert((cargoComite.name + SST_Constantes.RESPONSABILIDAD_CARGO+': '+formacionResponsabilidadComite2.Nombre__c) == formacionCargo4.name);
        
        formacionCargo4.Formacion__c = formacionResponsabilidadComite2.id;
        Update formacionCargo4;
        
        formacionCargo3.Formacion__c = formacion2.id;
        Update formacionCargo3;
        
        
        
        
        Test.stopTest();             
    }
    
    //Método test para el trigger de Seguimiento Sede
    public static testMethod void SST_SedeTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        ID idPlanes = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosByName().get('Planes y Programas').getRecordTypeId();
        
        SST_Seguimiento__c seguimientoPlan = new SST_Seguimiento__c();
        seguimientoPlan.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        seguimientoPlan.RecordTypeId = idPlanes;
        seguimientoPlan.Name = 'Seguimiento plan';
        seguimientoPlan.Tipo__c = 'PL_002';
        seguimientoPlan.Fecha_inicial__c = system.today();
        seguimientoPlan.Fecha_final__c = system.today();
        seguimientoPlan.Objetivo__c = 'test plan';
        Insert seguimientoPlan;
        
        SST_sede__c sede = new SST_sede__c();
        sede.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        sede.name = 'sede';
        sede.Departamento__c = '5';
        sede.Municipio__c = '5002';
        sede.Direccion__c = 'direccion';
        sede.Zona__c = 'URBANA';
        sede.Estado__c = SST_Constantes.ACTIVO;
        Insert sede;
        
        SST_sede__c sede2 = new SST_sede__c();
        sede2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        sede2.name = 'sede 2';
        sede2.Departamento__c = '5';
        sede2.Municipio__c = '5002';
        sede2.Direccion__c = 'direccion';
        sede2.Zona__c = 'URBANA';
        sede2.Estado__c = SST_Constantes.ACTIVO;
        Insert sede2;
        
        SST_Seguimiento_sede__c asociacion = new SST_Seguimiento_sede__c();
        asociacion.seguimiento__c = seguimientoPlan.id;
        asociacion.Sede__c = sede.Id;
        insert asociacion;
        
        try{
            sede.Estado__c = SST_Constantes.INACTIVO;
            sede.name = 'sede2';
            update sede;
        }catch(Exception e){
            System.assertEquals(e.getMessage().contains('No es posible inactivar la sede')||e.getMessage().contains('Permisos'), true);
        }
        
        SST_Normatividad__c normatividad = New SST_Normatividad__c();
        normatividad.name = 'Normatividad';
        normatividad.empresa__c = empresa;
        normatividad.Entidad__c = 'E-039';
        normatividad.Tipo__c = 'ACUERDO';
        insert normatividad;
        
        SST_normatividad_sede__c asociacion2 = new SST_normatividad_sede__c();
        asociacion2.sede__c = sede.id;
        asociacion2.normatividad__c = normatividad.Id;
        insert asociacion2;
        
        try{
            sede.Estado__c = SST_Constantes.INACTIVO;
            update sede;
        }catch(Exception e){
            System.assertEquals(e.getMessage().contains('No es posible inactivar la sede')||e.getMessage().contains('Permisos'), true);
        }
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='5';
        contacto.SST_Sede__c = sede.id;
        insert contacto;
        
        try{
            sede.Estado__c = SST_Constantes.INACTIVO;
            update sede;
        }catch(Exception e){
            System.assertEquals(e.getMessage().contains('No es posible inactivar la sede')||e.getMessage().contains('Permisos'), true);
        }
        Test.stopTest();
    }
    
    //Método test para el trigger de Seguimiento Sede
    public static testMethod void SST_NormatividadSedeTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        SST_sede__c sede = new SST_sede__c();
        sede.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        sede.name = 'sede';
        sede.Departamento__c = '5';
        sede.Municipio__c = '5002';
        sede.Direccion__c = 'direccion';
        sede.Zona__c = 'URBANA';
        sede.Estado__c = SST_Constantes.ACTIVO;
        Insert sede;
        
        SST_Normatividad__c normatividad = New SST_Normatividad__c();
        normatividad.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        normatividad.name = 'Normatividad';
        normatividad.empresa__c = empresa;
        normatividad.Entidad__c = 'E-039';
        normatividad.Tipo__c = 'ACUERDO';
        insert normatividad;
        
        SST_normatividad_sede__c asociacion = new SST_normatividad_sede__c();
        asociacion.sede__c = sede.id;
        asociacion.normatividad__c = normatividad.Id;
        insert asociacion;
        
        try{
            SST_normatividad_sede__c asociacion2 = new SST_normatividad_sede__c();
            asociacion2.sede__c = sede.id;
            asociacion2.normatividad__c = normatividad.Id;
            insert asociacion2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('ya se encuentra asociada a la normatividad') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Método test para la clase Constantes
    public static testMethod void SST_Constantes(){ 
        String fecha = SST_Constantes.cambiarNombreMes('Jan');
        fecha = SST_Constantes.cambiarNombreMes('Apr');
        fecha = SST_Constantes.cambiarNombreMes('Aug');
        fecha = SST_Constantes.cambiarNombreMes('Dec');
        
        Schema.DescribeFieldResult fieldResultEmpresa = contact.SST_empresa__c.getDescribe();
        List<Schema.PicklistEntry> itemsTempEmpresa = fieldResultEmpresa.getPicklistValues();
        
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        for(Integer i=0; i<=12; i++){
            SST_Constantes.cambiarNumeros(i);
        }
        Map<String,String> mapaIndicadores = SST_Constantes.llenarMapaIndicadoresResultado();
        Map<String,String> mapaIndicadores2 = SST_Constantes.llenarMapaUnidadesIndicadoresResultado();
        
        List<String> datos = new List<String>();
        datos.add('Prueba');
        SST_Constantes.EnviarNotificacionFuncionariosInactivos(datos,empresa);
        List<List<sObject>> searchList = SST_Utilitarios.busquedaSosl('texto');
    }
    
    //Método test para el trigger de Account
    public static testMethod void SST_AccountTrigger(){
        Test.StartTest();
        
          
            SST_Estandar_minimo__c estandar_minimo = New SST_Estandar_minimo__c();
            estandar_minimo.Ciclo__c='PLANEAR';
            estandar_minimo.Estandar_agrupador__c='RECURSOS (10%)';
            estandar_minimo.Item_estandar__c='0.1.1. Responsable del Sistema de Gestión de Seguridad en el Trabajo ';
            estandar_minimo.Puntaje__c= 0.5;
            estandar_minimo.Estandar__c='Recursos financieros, técnicos,  humanos  para coordinar y desarrollar el Sistema de Gestión de la Seguridad (4%)';
            estandar_minimo.Tipo_empresa__c= 'Pequena';
            insert estandar_minimo;
        
            SST_Estandar_minimo__c estandar_minimo2 = New SST_Estandar_minimo__c();
            estandar_minimo2.Ciclo__c='HACER';
            estandar_minimo2.Estandar_agrupador__c='RECURSOS (10%)';
            estandar_minimo2.Item_estandar__c='0.1.2. Responsable del Sistema en el Trabajo ';
            estandar_minimo2.Puntaje__c= 0.5;
            estandar_minimo2.Estandar__c='Recursos financieros para desarrollar el Sistema de Gestión de la Seguridad ';
            estandar_minimo2.Tipo_empresa__c= 'Pequena';
            insert estandar_minimo2;
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.SST_Periodicidad_examen_ocupacional__c=360;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.SST_Cuenta_indicadores_globales__c = true;
       
        insert cuenta;
        cuenta.SST_Nivel_Riesgo__c = 'Riesgo 5';  
        update cuenta;
        Account cuentaSinPeriodo = new Account();
        cuentaSinPeriodo.name = 'empresa';
        cuentaSinPeriodo.Type = 'Customer';
        cuentaSinPeriodo.SST_horas_habiles__c = 9;
        cuentaSinPeriodo.SST_nit__c = 109;
        cuentaSinPeriodo.SST_Periodicidad_examen_ocupacional__c=360;
        insert cuentaSinPeriodo;
        
        SST_Sede__c sede = SST_TestDataFactory.crearSede();
        
        SST_Area_trabajo__c area = SST_TestDataFactory.crearArea();
        
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
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
        contacto.SST_empresa__c= empresa;
        contacto.AccountId = cuenta.id;
        
        insert contacto;
        
        
        SST_Examen_ocupacional__c examen = new SST_Examen_ocupacional__c();
        examen.Funcionario_examen__c = contacto.id;
        examen.tipo_examen__c = SST_Constantes.INGRESO;
        examen.periodicidad_calculada__c = true;
        Date myDate = Date.newInstance(2019, 2, 17);
        examen.fecha_examen__c = myDate;
        insert examen;
        
        List<SST_Examen_ocupacional__c> examenes = [SELECT id,fecha_examen__c,funcionario_examen__r.accountId FROM SST_Examen_ocupacional__c where funcionario_examen__r.sst_empresa__c =:empresa and periodicidad_calculada__c = true and proximo_examen__c>=:system.today()];
        
        
        cuenta.SST_Periodicidad_examen_ocupacional__c=60;
        update cuenta;
        
        try{
            Account cuenta2 = new Account();
            cuenta2.name = 'Cliente 2';
            cuenta.SST_nit__c = Decimal.valueOf(empresa);
            cuenta2.SST_periodo_notificacion__c = 2;
            cuenta2.SST_Cuenta_indicadores_globales__c = true;
            insert cuenta2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El periodo de notificación debe ser el mismo para todas las empresas del grupo empresarial') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        Account cuenta2 = new Account();
        cuenta2.name = 'Cliente 2';
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta2.SST_periodo_notificacion__c = 1;
        insert cuenta2;
        
        contacto.SST_Fecha_Retiro__c = system.today();
        update contacto;
        
        cuenta2.SST_periodo_notificacion__c = 2;
        update cuenta2;
        

        Test.stopTest();
    }
    
    //Método test para el trigger de Formación
    public static testMethod void SST_FormacionTrigger(){
        Test.StartTest();
        ID idEntrenamiento = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Entrenamientos').getRecordTypeId();
        
        SST_Formacion__c formacion = new SST_Formacion__c();
        formacion.RecordTypeId = idEntrenamiento;
        formacion.Nombre__c = 'entrenamiento de prueba';
        insert formacion;
        
        try{
            SST_Formacion__c formacion2 = new SST_Formacion__c();
            formacion2.RecordTypeId = idEntrenamiento;
            formacion2.Nombre__c = 'entrenamiento de prueba';
            insert formacion2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una formación con el Tipo de Registro') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        SST_Formacion__c formacion2 = new SST_Formacion__c();
        formacion2.RecordTypeId = idEntrenamiento;
        formacion2.Nombre__c = 'entrenamiento de prueba 2';
        insert formacion2;
        
        try{
            formacion2.Nombre__c = 'entrenamiento de prueba';
            update formacion2;
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una formación con el Tipo de Registro') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Método test para el trigger de Examen Ocupacional
    public static testMethod void SST_ExamenOcupacionalTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.SST_Periodicidad_examen_ocupacional__c = 15;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        insert cuenta;
        
        SST_Sede__c sede = SST_TestDataFactory.crearSede();
        
        SST_Area_trabajo__c area = SST_TestDataFactory.crearArea();
        
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
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
        
        try{
            SST_Examen_ocupacional__c examen = new SST_Examen_ocupacional__c();
            examen.Funcionario_examen__c = contacto.id;
            examen.tipo_examen__c = SST_Constantes.INGRESO;
            examen.fecha_examen__c = system.today();
            insert examen;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No se ha indicado la periodicidad de los exámenes ocupacionales en la empresa') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        cuenta.SST_Periodicidad_examen_ocupacional__c = 30;
        update cuenta;
        
        SST_Examen_ocupacional__c examen = new SST_Examen_ocupacional__c();
        examen.Funcionario_examen__c = contacto.id;
        examen.tipo_examen__c = SST_Constantes.INGRESO;
        examen.fecha_examen__c = system.today();
        insert examen;
        
        cuenta.SST_Periodicidad_examen_ocupacional__c = 30;
        update cuenta;
        
        Test.stopTest();       
    }
    
    //Método test para el trigger de Contact
    public static testMethod void SST_ContactTrigger(){
        Test.StartTest();
        
        ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();
        
        try{
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
            contacto.SST_Departamento__c = '5';
            contacto.RecordTypeId = idContratista;
            insert contacto;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No se han configurado los datos de la empresa') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        insert cuenta;
        
        Contact contacto = New Contact();
        contacto.LastName='Pereira';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c = '63';
        contacto.RecordTypeId = idContratista;
        contacto.sst_codigo_dane_municipio__c = '099';
        contacto.SST_Codigo_DANE_Nacimiento__c = '099';
        
        try{
            insert contacto;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Debe indicar el número de identificación del contacto') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        contacto.SST_Identificacion__c = '122"#"30';
        try{
            insert contacto;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El número de identificación no debe contener caracteres diferentes a letras o números') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        contacto.SST_Identificacion__c = '1230';
        insert contacto;
        
        try{
            Contact contacto2 = New Contact();
            contacto2.LastName='Pereira';
            contacto2.FirstName='Maria';
            contacto2.Email='contacto@hotmail.com';
            contacto2.SST_isActive__c='true';
            contacto2.SST_Tipo_Identificacion__c = 'C';
            contacto2.SST_Identificacion__c = '1230';
            contacto2.MobilePhone = '3101234567';
            contacto2.SST_Contacto_Emergencia__c = 'contacto';
            contacto2.SST_Telefono_Emergencia__c = '123';
            contacto2.SST_Departamento__c = '63';
            contacto2.RecordTypeId = idContratista;
            contacto2.sst_codigo_dane_municipio__c = '099';
            contacto2.SST_Codigo_DANE_Nacimiento__c = '099';
            insert contacto2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El contacto ya se encuentra actualmente registrado en la empresa') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        } 
        Contact contacto2 = New Contact();
        contacto2.LastName='Pereira';
        contacto2.FirstName='Mario';
        contacto2.Email='contacto@hotmail.com';
        contacto2.SST_isActive__c='true';
        contacto2.SST_Tipo_Identificacion__c = 'C';
        contacto2.SST_Identificacion__c = '12301230';
        contacto2.MobilePhone = '3101234567';
        contacto2.SST_Contacto_Emergencia__c = 'contacto';
        contacto2.SST_Telefono_Emergencia__c = '123';
        contacto2.SST_Departamento__c = '63';
        contacto2.RecordTypeId = idContratista;
        contacto2.sst_codigo_dane_municipio__c = '63130';
        contacto2.SST_Codigo_DANE_Nacimiento__c = '63130';
        contacto2.SST_Documentacion_contacto__c = 'DOC01';
        insert contacto2;
        try{
            contacto2.SST_Identificacion__c = '1230';
            update(contacto2);
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un contacto con el mismo número de identificación registrado.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        } 
        
        contacto2.SST_Identificacion__c = '12301230';
        contacto2.SST_Gestionar_documentos__c = false;
        contacto2.SST_Notificar_link__c = true;
        update contacto2;
        
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        Contact funcionario = SST_TestDataFactory.crearFuncionario(cuenta, cargoFuncionario);
        try{
            Contact funcionario2 = funcionario;
            funcionario2.id=null;
            insert funcionario2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El funcionario ya se encuentra actualmente registrado en la empresa.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        } 
        Contact funcionario2 = funcionario;
        funcionario2.id=null;
        funcionario2.SST_Identificacion__c = '1231';
        insert(funcionario2);
        try{
            funcionario2.SST_Identificacion__c = '12#$##$31';
            update(funcionario2);
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El número de identificación no debe contener caracteres diferentes a letras o números') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        } 
        
        try{
            funcionario2.SST_Identificacion__c = '1230';
            update funcionario2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un funcionario con el mismo número de identificación registrado en esta empresa.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        } 
        funcionario2.SST_Identificacion__c = '1233';
        update funcionario2;        
        
    }
    
    //Método test para el trigger de Comunicación y Acto Condición Insegura
    public static testMethod void SST_ComunicacionTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        SST_Sede__c sede = SST_TestDataFactory.crearSede();
        
        SST_Area_trabajo__c area = SST_TestDataFactory.crearArea();
        
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
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
        
        
        SST_Comunicacion__c reporte = new SST_Comunicacion__c();
        reporte.Informador__c = contacto.Id;
        reporte.Descripcion__c = 'prueba comunicación';
        reporte.Tipo_reporte__c = 'CONDICION_INSEGURA';
        insert reporte;
        
        reporte.Tipo_reporte__c= 'ACTO_INSEGURO';
        reporte.Estado__c = 'TRAMITADO';
        update reporte;
        
        SST_Comunicacion__c reporte2 = new SST_Comunicacion__c();
        reporte2.Informador__c = contacto.Id;
        reporte2.Descripcion__c = 'prueba comunicación';
        reporte2.Tipo_reporte__c = 'CONDICION_INSEGURA';
        insert reporte2;
        
        try{
            delete reporte2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No es posible eliminar un registro de comunicaciones') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();        
    }
    
    //Método test para el trigger de Encuesta sociodemográfica
    public static testMethod void SST_EncuestaSociodemograficaTrigger(){
        Test.StartTest();
        Date hoy = system.today();
        try{
            SST_Encuesta_sociodemografica__c encuesta1 = new SST_Encuesta_sociodemografica__c();
            encuesta1.Fecha_inicio__c = hoy;
            encuesta1.Fecha_fin__c = hoy.addDays(1);
            encuesta1.descripcion__c = 'encuesta 1';
            insert encuesta1; 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No hay actualmente configurada una empresa como cuenta principal') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.SST_Estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_grupo_empresarial__c = 'Heinsohn';
        cuenta.SST_Link_encuesta_sociodemografica__c='www.link.com';
        cuenta.SST_Link_gestion_documental__c = 'www.link.com';
        insert cuenta;
        
        SST_Sede__c sede = new SST_Sede__c();
        sede.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        sede.Name = 'Sede prueba';
        sede.Departamento__c = '5';
        sede.Municipio__c = '5002';
        sede.Estado__c = SST_Constantes.ACTIVO;
        sede.Direccion__c = 'Direccion';
        sede.Zona__c = 'URBANA';
        insert Sede;
        
        SST_Area_trabajo__c area = new SST_Area_trabajo__c();
        area.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        area.Name = 'Area prueba';
        area.Estado__c = SST_Constantes.ACTIVO;
        insert area;
        
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.SST_Empresa__c = String.valueOf(cuenta.SST_nit__c);
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
        
        SST_Encuesta_sociodemografica__c encuesta1 = new SST_Encuesta_sociodemografica__c();
        encuesta1.Fecha_inicio__c = hoy;
        encuesta1.Fecha_fin__c = hoy.addDays(1);
        encuesta1.descripcion__c = 'encuesta 1';
        insert encuesta1;
        
        SST_Encuesta_sociodemografica__c encuesta2 = new SST_Encuesta_sociodemografica__c();
        encuesta2.Fecha_inicio__c = hoy;
        encuesta2.Fecha_fin__c = hoy.addDays(1);
        encuesta2.descripcion__c = 'encuesta 2';
        insert encuesta2;  
        
        cuenta.type = '';
        update cuenta;
        
        try{
            encuesta2.Fecha_fin__c = hoy.addDays(2);
            update encuesta2; 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('No hay actualmente configurada una empresa como cuenta principal') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        cuenta.Type = 'Customer';
        update cuenta;
        
        encuesta2.Fecha_fin__c = hoy.addDays(2);
        update encuesta2; 
        
        
        Test.stopTest();
    }
    
    //Método test para la clase SST_HomeSiteCC
    public static testMethod void SST_HomeSiteCC(){
        Test.StartTest();
        
        SST_HomeSiteCC homeCC = new SST_HomeSiteCC();
        System.assert(homeCC.linkSST.contains('force'));
        System.assert(homeCC.comunicaciones.contains('/sstcomunicaciones'));
        System.assert(homeCC.gestionDocumental.contains('/sstgestiondocumental'));
        System.assert(homeCC.encuestaSociodemografica.contains('/sstencuestasociodemografica'));
        
        Test.stopTest();
    }
    
    //Método test para el trigger de Seguimientos ELC Diagnósticos
    public static testMethod void SST_SeguimientosELCDiagnosticosTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        
        Contact contacto = New Contact();
        contacto.recordTypeId = idFuncionario;
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='5';
        insert contacto;
        
        SST_Diagnostico_CIE10__c cie= new SST_Diagnostico_CIE10__c();
        cie.Name = 'A040';
        cie.codigo_externo__c = 'A040';
        cie.Nombre_diagnostico__c = 'diagnostico 1';
        insert cie;
        
        SST_Diagnostico_CIE10__c cie2= new SST_Diagnostico_CIE10__c();
        cie2.Name = 'A041';
        cie2.codigo_externo__c = 'A041';
        cie2.Nombre_diagnostico__c = 'diagnostico 2';
        insert cie2;
        
        Date hoy = system.today();
        
        SST_Seguimiento_ELC__c segELC = new SST_Seguimiento_ELC__c();
        segELC.Funcionario__c = contacto.id;
        segELC.origen__c = 'Laboral';
        segELC.Fecha_dx__c = hoy.addDays(-10);
        segELC.Entidad_califica__c = 'entidad';
        segELC.Recomendaciones__c = 'Si';
        segELC.Fecha_inicio_recomendaciones__c = hoy.addDays(-5);
        segELC.Tiempo_recomendaciones__c = 10;
        insert segELC;
        
        SST_SeguimientoELC_DiagnosticoCIE10__c segDiagnostico = new SST_SeguimientoELC_DiagnosticoCIE10__c();
        segDiagnostico.Seguimiento_ELC__c  = segELC.id;
        segDiagnostico.Diagnostico_CIE10__c = cie.id;
        insert segDiagnostico;
        
        try{
            SST_SeguimientoELC_DiagnosticoCIE10__c segDiagnostico2 = new SST_SeguimientoELC_DiagnosticoCIE10__c();
            segDiagnostico2.Seguimiento_ELC__c  = segELC.id;
            segDiagnostico2.Diagnostico_CIE10__c = cie.id;
            insert segDiagnostico2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El diagnóstico ya se encuentra asociado al seguimiento de ELC') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        SST_Seguimiento_ELC__c segELC2 = new SST_Seguimiento_ELC__c();
        segELC2.Funcionario__c = contacto.id;
        segELC2.origen__c = 'Laboral';
        segELC2.Fecha_dx__c = hoy.addDays(-10);
        segELC2.Entidad_califica__c = 'entidad';
        segELC2.Recomendaciones__c = 'Si';
        segELC2.Fecha_inicio_recomendaciones__c = hoy.addDays(-5);
        segELC2.Tiempo_recomendaciones__c = 10;
        insert segELC2;
        
        try{
            SST_SeguimientoELC_DiagnosticoCIE10__c segDiagnostico2 = new SST_SeguimientoELC_DiagnosticoCIE10__c();
            segDiagnostico2.Seguimiento_ELC__c  = segELC2.id;
            segDiagnostico2.Diagnostico_CIE10__c = cie.id;
            insert segDiagnostico2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El funcionario asociado al seguimiento de ELC actual') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        SST_SeguimientoELC_DiagnosticoCIE10__c segDiagnostico2 = new SST_SeguimientoELC_DiagnosticoCIE10__c();
        segDiagnostico2.Seguimiento_ELC__c  = segELC2.id;
        segDiagnostico2.Diagnostico_CIE10__c = cie2.id;
        insert segDiagnostico2;
        
        try{
            segDiagnostico2.Diagnostico_CIE10__c = cie.id;
            update segDiagnostico2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('El diagnóstico ya se encuentra asociado al seguimiento de ELC') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        
        Test.stopTest();
    }
    
    //Método test para el trigger de ControlEPP
    public static testMethod void SST_ControlEPPTrigger(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c; 
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        SST_Cargo__c cargoFuncionario = SST_TestDataFactory.crearCargoFuncionario();
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();
        Contact contacto = SST_TestDataFactory.crearFuncionario(cuenta, cargoFuncionario);
        
        SST_Elemento_proteccion_personal__c epp = new SST_Elemento_proteccion_personal__c();
        epp.codigo__c='EPP1';
        epp.descripcion__c ='Elemento proteccion';
        epp.vida_util__c =45;
        insert(epp);
        
        SST_Elemento_proteccion_personal__c epp2 = new SST_Elemento_proteccion_personal__c();
        epp2.codigo__c='EPP2';
        epp2.descripcion__c ='Elemento proteccion';
        epp2.vida_util__c =45;
        insert(epp2);
        
        SST_Cargo_EPP__c cargoEPP = New SST_Cargo_EPP__c();
        cargoEPP.Cargo__c = cargoFuncionario.id;
        cargoEPP.Elemento_Proteccion_Personal__c = epp.id;
        insert cargoEPP;
        
        
        SST_Control_EPP__c controlEpp = new SST_Control_EPP__c();
        controlEpp.Funcionario__c = contacto.id;
        controlEpp.Elemento_proteccion_personal__c = epp.id;
        controlEpp.Cantidad__c = 1;
        controlEpp.Descripcion__c = 'Epp de prueba';
        controlEpp.Fecha_entrega__c = system.today();
        controlEpp.Motivo_entrega__c = 'REPOSICION';
        insert controlEpp;
        
        try{
            controlEpp.Funcionario__c = contacto.id;
            controlEpp.Elemento_proteccion_personal__c = epp2.id;
            controlEpp.Cantidad__c = 1;
            controlEpp.Descripcion__c = 'Epp de prueba';
            controlEpp.Fecha_entrega__c = system.today();
            controlEpp.Motivo_entrega__c = 'REPOSICION';
            update controlEpp;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Debe seleccionar un Elemento Protección Personal que esté asociado al cargo del funcionario ') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        } 
        
        Test.stopTest();
    }
    
    
}