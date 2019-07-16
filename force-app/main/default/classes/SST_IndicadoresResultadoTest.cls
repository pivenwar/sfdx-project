@IsTest
public class SST_IndicadoresResultadoTest {
    static testMethod void SST_IndicadoresResultadoTest1(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;     
        
        Date hoy = system.today();
        hoy = hoy.toStartOfMonth();
        hoy = hoy.addDays(-1);
        
        Account cuenta = new Account();
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.sst_Frecuencia_IEL__c = '1';
        cuenta.sst_meta_IEL__c = 1;
        cuenta.sst_Frecuencia_IFA__c = '1';
        cuenta.sst_meta_IFA__c = 1;
        cuenta.sst_Frecuencia_IFAT__c = '1';
        cuenta.sst_meta_IFAT__c = 1;
        cuenta.sst_Frecuencia_IFIAT__c = '1';
        cuenta.sst_meta_IFIAT__c = 1;
        cuenta.sst_Frecuencia_ILIAT__c = '1';
        cuenta.sst_meta_ILIAT__c = 1;
        cuenta.sst_Frecuencia_ISAT__c = '1';
        cuenta.sst_meta_ISAT__c = 1;
        cuenta.sst_Frecuencia_MAT__c = '1';
        cuenta.sst_meta_MAT__c = 1;
        cuenta.sst_Frecuencia_ACM__c = '1';
        cuenta.sst_meta_ACM__c = 1;
        cuenta.sst_Frecuencia_PEL__c = '1';
        cuenta.sst_meta_PEL__c = 1;
        cuenta.sst_Frecuencia_PTP__c = '1';
        cuenta.sst_meta_PTP__c = 1;
        cuenta.sst_Frecuencia_FA__c = '1';
        cuenta.sst_meta_FA__c = 1;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.sst_estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_Cuenta_indicadores_globales__c = true;
        insert cuenta;
        SST_cargo__c cargo = SST_TestDataFactory.crearCargoFuncionario();
        SST_sede__c sede = SST_TestDataFactory.crearSede();
       
        
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     
        Contact contacto = New Contact();
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='63';
        contacto.recordTypeId = idFuncionario;
        contacto.SST_Fecha_Ingreso__c = hoy.addDays(-180);
        contacto.SST_Empresa__c = empresa;
        contacto.SST_fondo_pensiones__c = '860007379';
        contacto.SST_ARL__C ='860002183';
        contacto.SST_EPS__c= '830113831';
        contacto.SST_cargo__c = cargo.Id;
        contacto.SST_sede__c=sede.id;
        contacto.SST_Jornada__c ='LUNES_A_VIERNES';
        contacto.SST_Tipo_Contrato__c = 'TEMPORAL';
        insert contacto;
        
        
        SST_Diagnostico_CIE10__c cie3= new SST_Diagnostico_CIE10__c();
        cie3.Name = 'A040';
        cie3.codigo_externo__c = 'A040';
        cie3.Nombre_diagnostico__c = 'diagnostico 1';
        
        SST_Diagnostico_CIE10__c cie2= new SST_Diagnostico_CIE10__c();
        cie2.Name = 'A041';
        cie2.codigo_externo__c = 'A041';
        cie2.Nombre_diagnostico__c = 'diagnostico 2';
        
         SST_Diagnostico_CIE10__c cie= new SST_Diagnostico_CIE10__c();
        cie.Name = 'A042';
        cie.codigo_externo__c = 'A042';
        cie.Nombre_diagnostico__c = 'nada';

        List<SST_Diagnostico_CIE10__c> diagnosticos = new List<SST_Diagnostico_CIE10__c>();
        diagnosticos.add(cie3);
        diagnosticos.add(cie2);
        diagnosticos.add(cie);
        insert(diagnosticos);
        
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
        segDiagnostico.Diagnostico_CIE10__c = cie3.id;
        insert segDiagnostico;
        
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();     
        
       
        
        List <SST_Registro_de_Novedades__c>  novedades  = new List <SST_Registro_de_Novedades__c>();
        
        SST_Registro_de_Novedades__c ausentismo = New SST_Registro_de_Novedades__c();
        ausentismo.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        ausentismo.Funcionario__c=contacto.id;
        ausentismo.recordTypeId = ausentismos;
        ausentismo.Tipo__c = 'PERMISO';
        ausentismo.Cantidad_Horas__c = 5;
        ausentismo.Fecha_Inicial__c = hoy.addDays(-25);
        ausentismo.Fecha_Final__c = hoy.addDays(-25);
        ausentismo.Descripcion__c = 'prueba';
        novedades.add(ausentismo);
        
        SST_Registro_de_Novedades__c accidente = New SST_Registro_de_Novedades__c();
        accidente.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        accidente.Funcionario__c=contacto.id;
        accidente.recordTypeId = accidentes;
        accidente.Tipo__c = 'MORTAL';
        accidente.Dias_cargados__c = 6000;
        accidente.Fecha_Inicial__c = hoy.addDays(-24);
        novedades.add(accidente);
        
        SST_Registro_de_Novedades__c accidente2 = New SST_Registro_de_Novedades__c();
        accidente2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        accidente2.Funcionario__c=contacto.id;
        accidente2.recordTypeId = accidentes;
        accidente2.Tipo__c = 'LEVE';
        accidente2.Fecha_Inicial__c = hoy.addDays(-23);
        novedades.add(accidente2);
        
        SST_Registro_de_Novedades__c incapacidad = New SST_Registro_de_Novedades__c();
        incapacidad.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        incapacidad.Funcionario__c=contacto.id;
        incapacidad.recordTypeId = incapacidades;
        incapacidad.Fecha_Inicial__c = hoy.addDays(-22);
        incapacidad.Fecha_Final__c = hoy.addDays(-20);
        incapacidad.Naturaleza__c = 'ACCIDENTE_TRABAJO';
        novedades.add(incapacidad);
        
        SST_Registro_de_Novedades__c incapacidad2 = New SST_Registro_de_Novedades__c();
        incapacidad2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        incapacidad2.Funcionario__c=contacto.id;
        incapacidad2.recordTypeId = incapacidades;
        incapacidad2.Fecha_Inicial__c = hoy.addDays(-19);
        incapacidad2.Fecha_Final__c = hoy.addDays(-18);
        incapacidad2.Naturaleza__c = 'ENFERMEDAD_PROFESIONAL';
        novedades.add(incapacidad2);
        
        insert(novedades);
        
        SST_Indicador__c indicador = New SST_Indicador__c();
        indicador.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        indicador.Nombre_Indicador__c = 'IEL';
        indicador.Fecha_Inicial__c = hoy.addDays(-30);
        indicador.Fecha_Final__c = hoy;
        indicador.Calculo__c ='No se han registrado incapacidades en la empresa hasta el periodo seleccionado';
        indicador.Analisis__c = 'Análisis';
        insert indicador;
        
        SST_Hora_extra__c horaExtra = new SST_Hora_extra__c();
        horaExtra.Funcionario__c = contacto.id;
        horaExtra.Cantidad_horas__c = 5;
        Integer mes = hoy.month();
        horaExtra.Mes__c = String.valueOf(mes);
        horaExtra.Anio__c = hoy.year();
        insert horaExtra;
        
        SST_IndicadoresResultadoCC consultaIndicadores = new SST_IndicadoresResultadoCC();
        consultaIndicadores.getIndicadores();
        consultaIndicadores.fechaFin = hoy;
        consultaIndicadores.consultar();
        consultaIndicadores.indicadorSelect = 'IEL';
        consultaIndicadores.consultar();
        System.assert('IEL' == consultaIndicadores.indicadorSelect);
        consultaIndicadores.guardar();
        System.assert(consultaIndicadores.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Se ha actualizado el análisis para el indicador')||
                     consultaIndicadores.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Permisos'));
        
        consultaIndicadores.indicadorSelect = 'IFA';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'IFAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'IFIAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'ILIAT';
        consultaIndicadores.consultar();
        Test.StopTest();
    }
    
    static testMethod void SST_IndicadoresResultadoTest2(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        Date hoy = system.today();
        hoy = hoy.toStartOfMonth();
        hoy = hoy.addDays(-1);
        
        Account cuenta = new Account();
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.sst_Frecuencia_IEL__c = '1';
        cuenta.sst_meta_IEL__c = 1;
        cuenta.sst_Frecuencia_IFA__c = '1';
        cuenta.sst_meta_IFA__c = 1;
        cuenta.sst_Frecuencia_IFAT__c = '1';
        cuenta.sst_meta_IFAT__c = 1;
        cuenta.sst_Frecuencia_IFIAT__c = '1';
        cuenta.sst_meta_IFIAT__c = 1;
        cuenta.sst_Frecuencia_ILIAT__c = '1';
        cuenta.sst_meta_ILIAT__c = 1;
        cuenta.sst_Frecuencia_ISAT__c = '1';
        cuenta.sst_meta_ISAT__c = 1;
        cuenta.sst_Frecuencia_MAT__c = '1';
        cuenta.sst_meta_MAT__c = 1;
        cuenta.sst_Frecuencia_ACM__c = '1';
        cuenta.sst_meta_ACM__c = 1;
        cuenta.sst_Frecuencia_PEL__c = '1';
        cuenta.sst_meta_PEL__c = 1;
        cuenta.sst_Frecuencia_PTP__c = '1';
        cuenta.sst_meta_PTP__c = 1;
        cuenta.sst_Frecuencia_FA__c = '1';
        cuenta.sst_meta_FA__c = 1;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.sst_estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_Cuenta_indicadores_globales__c = true;
        insert cuenta;
        
        SST_cargo__c cargo = SST_TestDataFactory.crearCargoFuncionario();
        SST_sede__c sede = SST_TestDataFactory.crearSede();
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     
        
        Contact contacto = New Contact();
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='63';
        contacto.recordTypeId = idFuncionario;
        contacto.SST_Fecha_Ingreso__c = hoy.addDays(-180);
        contacto.SST_Empresa__c = String.valueOf(cuenta.SST_nit__c);
        contacto.SST_fondo_pensiones__c = '860007379';
        contacto.SST_ARL__C ='860002183';
        contacto.SST_EPS__c= '830113831';
        contacto.SST_Cargo__c = cargo.id;
        contacto.SST_sede__c=sede.id;
        contacto.SST_Jornada__c ='LUNES_A_VIERNES';
        contacto.SST_Tipo_Contrato__c = 'TEMPORAL';
        insert contacto;
        
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();     

        
        SST_Diagnostico_CIE10__c cie= new SST_Diagnostico_CIE10__c();
        cie.Name = 'A040';
        cie.codigo_externo__c = 'A040';
        cie.Nombre_diagnostico__c = 'nada';
        insert cie;
        
        List <SST_Registro_de_Novedades__c>  novedades  = new List <SST_Registro_de_Novedades__c>();
        
        SST_Registro_de_Novedades__c ausentismo = New SST_Registro_de_Novedades__c();
        ausentismo.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        ausentismo.Funcionario__c=contacto.id;
        ausentismo.recordTypeId = ausentismos;
        ausentismo.Tipo__c = 'PERMISO';
        ausentismo.Cantidad_Horas__c = 5;
        ausentismo.Fecha_Inicial__c = hoy.addDays(-25);
        ausentismo.Fecha_Final__c = hoy.addDays(-25);
        ausentismo.Descripcion__c = 'prueba';
        novedades.add(ausentismo);
        
        SST_Registro_de_Novedades__c accidente = New SST_Registro_de_Novedades__c();
        accidente.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        accidente.Funcionario__c=contacto.id;
        accidente.recordTypeId = accidentes;
        accidente.Tipo__c = 'MORTAL';
        accidente.Dias_cargados__c = 6000;
        accidente.Fecha_Inicial__c = hoy.addDays(-24);
        novedades.add(accidente);
        
        SST_Registro_de_Novedades__c accidente2 = New SST_Registro_de_Novedades__c();
        accidente2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        accidente2.Funcionario__c=contacto.id;
        accidente2.recordTypeId = accidentes;
        accidente2.Tipo__c = 'LEVE';
        accidente2.Fecha_Inicial__c = hoy.addDays(-23);
        novedades.add(accidente2);
        
        SST_Registro_de_Novedades__c incapacidad = New SST_Registro_de_Novedades__c();
        incapacidad.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        incapacidad.Funcionario__c=contacto.id;
        incapacidad.recordTypeId = incapacidades;
        incapacidad.Fecha_Inicial__c = hoy.addDays(-22);
        incapacidad.Fecha_Final__c = hoy.addDays(-20);
        incapacidad.Naturaleza__c = 'ACCIDENTE_TRABAJO';
        novedades.add(incapacidad);
        
        SST_Registro_de_Novedades__c incapacidad2 = New SST_Registro_de_Novedades__c();
        incapacidad2.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        incapacidad2.Funcionario__c=contacto.id;
        incapacidad2.recordTypeId = incapacidades;
        incapacidad2.Fecha_Inicial__c = hoy.addDays(-19);
        incapacidad2.Fecha_Final__c = hoy.addDays(-18);
        incapacidad2.Naturaleza__c = 'ENFERMEDAD_PROFESIONAL';
        novedades.add(incapacidad2);
        
        insert novedades;
        
        SST_Indicador__c indicador = New SST_Indicador__c();
        indicador.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        indicador.Nombre_Indicador__c = 'IEL';
        indicador.Fecha_Inicial__c = hoy;
        indicador.Fecha_Final__c = hoy.addDays(30);
        indicador.Calculo__c ='No se han registrado incapacidades en la empresa hasta el periodo seleccionado';
        indicador.Analisis__c = 'Análisis';
        insert indicador;
        
        SST_Hora_extra__c horaExtra = new SST_Hora_extra__c();
        horaExtra.Funcionario__c = contacto.id;
        horaExtra.Cantidad_horas__c = 5;
        Integer mes = hoy.month();
        horaExtra.Mes__c = String.valueOf(mes);
        horaExtra.Anio__c = hoy.year();
        insert horaExtra;
        
        SST_IndicadoresResultadoCC consultaIndicadores = new SST_IndicadoresResultadoCC();
        consultaIndicadores.getIndicadores();
        consultaIndicadores.fechaFin = hoy;
        
        consultaIndicadores.indicadorSelect = 'ISAT';
        consultaIndicadores.consultar();
        System.assert('ISAT' == consultaIndicadores.indicadorSelect);
        
        consultaIndicadores.indicadorSelect = 'MAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'ACM';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'PEL';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'PTP';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'FA';
        consultaIndicadores.consultar();
        Test.StopTest();
    }
    
    static testMethod void SST_IndicadoresResultadoTest3(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Date hoy = system.today();
        hoy = hoy.toStartOfMonth();
        hoy = hoy.addDays(-1);
        
        Account cuenta = new Account();
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.sst_Frecuencia_IEL__c = '1';
        cuenta.sst_meta_IEL__c = 1;
        cuenta.sst_Frecuencia_IFA__c = '1';
        cuenta.sst_meta_IFA__c = 1;
        cuenta.sst_Frecuencia_IFAT__c = '1';
        cuenta.sst_meta_IFAT__c = 1;
        cuenta.sst_Frecuencia_IFIAT__c = '1';
        cuenta.sst_meta_IFIAT__c = 1;
        cuenta.sst_Frecuencia_ILIAT__c = '1';
        cuenta.sst_meta_ILIAT__c = 1;
        cuenta.sst_Frecuencia_ISAT__c = '1';
        cuenta.sst_meta_ISAT__c = 1;
        cuenta.sst_Frecuencia_MAT__c = '1';
        cuenta.sst_meta_MAT__c = 1;
        cuenta.sst_Frecuencia_ACM__c = '1';
        cuenta.sst_meta_ACM__c = 1;
        cuenta.sst_Frecuencia_PEL__c = '1';
        cuenta.sst_meta_PEL__c = 1;
        cuenta.sst_Frecuencia_PTP__c = '1';
        cuenta.sst_meta_PTP__c = 1;
        cuenta.sst_Frecuencia_FA__c = '1';
        cuenta.sst_meta_FA__c = 1;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.sst_estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_Cuenta_indicadores_globales__c = true;
        insert cuenta;
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     
        
        Contact contacto = New Contact();
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='63';
        contacto.recordTypeId = idFuncionario;
        contacto.SST_Fecha_Ingreso__c = hoy.addDays(-180);
        contacto.SST_Empresa__c = String.valueOf(cuenta.SST_nit__c);
        insert contacto;
        
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();     
        
        SST_IndicadoresResultadoCC consultaIndicadores = new SST_IndicadoresResultadoCC();
        consultaIndicadores.getIndicadores();
        consultaIndicadores.fechaFin = hoy;
        
        consultaIndicadores.indicadorSelect = 'IEL';
        consultaIndicadores.consultar();
        System.assert('IEL' == consultaIndicadores.indicadorSelect);
        consultaIndicadores.guardar();
        System.assert(consultaIndicadores.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Se ha actualizado el análisis para el indicador')||consultaIndicadores.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Permisos'));
        
        
        consultaIndicadores.indicadorSelect = 'IFA';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'IFAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'IFIAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'ILIAT';
        consultaIndicadores.consultar();
        Test.StopTest();
    }
    
    static testMethod void SST_IndicadoresResultadoTest4(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Date hoy = system.today();
        hoy = hoy.toStartOfMonth();
        hoy = hoy.addDays(-1);
        
        Account cuenta = new Account();
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.sst_Frecuencia_IEL__c = '1';
        cuenta.sst_meta_IEL__c = 1;
        cuenta.sst_Frecuencia_IFA__c = '1';
        cuenta.sst_meta_IFA__c = 1;
        cuenta.sst_Frecuencia_IFAT__c = '1';
        cuenta.sst_meta_IFAT__c = 1;
        cuenta.sst_Frecuencia_IFIAT__c = '1';
        cuenta.sst_meta_IFIAT__c = 1;
        cuenta.sst_Frecuencia_ILIAT__c = '1';
        cuenta.sst_meta_ILIAT__c = 1;
        cuenta.sst_Frecuencia_ISAT__c = '1';
        cuenta.sst_meta_ISAT__c = 1;
        cuenta.sst_Frecuencia_MAT__c = '1';
        cuenta.sst_meta_MAT__c = 1;
        cuenta.sst_Frecuencia_ACM__c = '1';
        cuenta.sst_meta_ACM__c = 1;
        cuenta.sst_Frecuencia_PEL__c = '1';
        cuenta.sst_meta_PEL__c = 1;
        cuenta.sst_Frecuencia_PTP__c = '1';
        cuenta.sst_meta_PTP__c = 1;
        cuenta.sst_Frecuencia_FA__c = '1';
        cuenta.sst_meta_FA__c = 1;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.sst_estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_Cuenta_indicadores_globales__c = true;
        insert cuenta;
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     
        
        Contact contacto = New Contact();
        contacto.LastName='Perez';
        contacto.FirstName='Maria';
        contacto.Email='contacto@hotmail.com';
        contacto.SST_isActive__c='true';
        contacto.SST_Tipo_Identificacion__c = 'C';
        contacto.SST_Identificacion__c = '1230';
        contacto.MobilePhone = '3101234567';
        contacto.SST_Contacto_Emergencia__c = 'contacto';
        contacto.SST_Telefono_Emergencia__c = '123';
        contacto.SST_Departamento__c='63';
        contacto.recordTypeId = idFuncionario;
        contacto.SST_Fecha_Ingreso__c = hoy.addDays(-180);
        contacto.SST_Empresa__c = String.valueOf(cuenta.SST_nit__c);
        insert contacto;
        
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();             
        
        
        SST_IndicadoresResultadoCC consultaIndicadores = new SST_IndicadoresResultadoCC();
        consultaIndicadores.getIndicadores();
        consultaIndicadores.fechaFin = hoy;
        
        consultaIndicadores.indicadorSelect = 'ISAT';
        consultaIndicadores.consultar();
        System.assert('ISAT' == consultaIndicadores.indicadorSelect);
        
        consultaIndicadores.indicadorSelect = 'MAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'ACM';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'PEL';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'PTP';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'FA';
        consultaIndicadores.consultar();
        Test.StopTest();
    }
    
    static testMethod void SST_IndicadoresResultadoTest5(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Date hoy = system.today();
        hoy = hoy.toStartOfMonth();
        hoy = hoy.addDays(-1);
        
        Account cuenta = new Account();
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.sst_Frecuencia_IEL__c = '1';
        cuenta.sst_meta_IEL__c = 1;
        cuenta.sst_Frecuencia_IFA__c = '1';
        cuenta.sst_meta_IFA__c = 1;
        cuenta.sst_Frecuencia_IFAT__c = '1';
        cuenta.sst_meta_IFAT__c = 1;
        cuenta.sst_Frecuencia_IFIAT__c = '1';
        cuenta.sst_meta_IFIAT__c = 1;
        cuenta.sst_Frecuencia_ILIAT__c = '1';
        cuenta.sst_meta_ILIAT__c = 1;
        cuenta.sst_Frecuencia_ISAT__c = '1';
        cuenta.sst_meta_ISAT__c = 1;
        cuenta.sst_Frecuencia_MAT__c = '1';
        cuenta.sst_meta_MAT__c = 1;
        cuenta.sst_Frecuencia_ACM__c = '1';
        cuenta.sst_meta_ACM__c = 1;
        cuenta.sst_Frecuencia_PEL__c = '1';
        cuenta.sst_meta_PEL__c = 1;
        cuenta.sst_Frecuencia_PTP__c = '1';
        cuenta.sst_meta_PTP__c = 1;
        cuenta.sst_Frecuencia_FA__c = '1';
        cuenta.sst_meta_FA__c = 1;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.sst_estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_Cuenta_indicadores_globales__c = true;
        insert cuenta;
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     
        
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();     

        
        SST_IndicadoresResultadoCC consultaIndicadores = new SST_IndicadoresResultadoCC();
        consultaIndicadores.getIndicadores();
        consultaIndicadores.fechaFin = hoy;
        consultaIndicadores.indicadorSelect = 'IEL';
        consultaIndicadores.consultar();
        System.assert('IEL' == consultaIndicadores.indicadorSelect);
        consultaIndicadores.guardar();
        System.assert(consultaIndicadores.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Se ha actualizado el análisis para el indicador')||consultaIndicadores.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Permisos'));
        
        
        consultaIndicadores.indicadorSelect = 'IFA';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'IFAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'IFIAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'ILIAT';
        consultaIndicadores.consultar();
        Test.StopTest();
    }
    
    static testMethod void SST_IndicadoresResultadoTest6(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Date hoy = system.today();
        hoy = hoy.toStartOfMonth();
        hoy = hoy.addDays(-1);
        
        Account cuenta = new Account();
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.sst_Frecuencia_IEL__c = '1';
        cuenta.sst_meta_IEL__c = 1;
        cuenta.sst_Frecuencia_IFA__c = '1';
        cuenta.sst_meta_IFA__c = 1;
        cuenta.sst_Frecuencia_IFAT__c = '1';
        cuenta.sst_meta_IFAT__c = 1;
        cuenta.sst_Frecuencia_IFIAT__c = '1';
        cuenta.sst_meta_IFIAT__c = 1;
        cuenta.sst_Frecuencia_ILIAT__c = '1';
        cuenta.sst_meta_ILIAT__c = 1;
        cuenta.sst_Frecuencia_ISAT__c = '1';
        cuenta.sst_meta_ISAT__c = 1;
        cuenta.sst_Frecuencia_MAT__c = '1';
        cuenta.sst_meta_MAT__c = 1;
        cuenta.sst_Frecuencia_ACM__c = '1';
        cuenta.sst_meta_ACM__c = 1;
        cuenta.sst_Frecuencia_PEL__c = '1';
        cuenta.sst_meta_PEL__c = 1;
        cuenta.sst_Frecuencia_PTP__c = '1';
        cuenta.sst_meta_PTP__c = 1;
        cuenta.sst_Frecuencia_FA__c = '1';
        cuenta.sst_meta_FA__c = 1;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.sst_estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_Cuenta_indicadores_globales__c = true;
        insert cuenta;
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     

        
        
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();     

        SST_IndicadoresResultadoCC consultaIndicadores = new SST_IndicadoresResultadoCC();
        consultaIndicadores.getIndicadores();
        consultaIndicadores.fechaFin = hoy;
        
        consultaIndicadores.indicadorSelect = 'ISAT';
        consultaIndicadores.consultar();
        System.assert('ISAT' == consultaIndicadores.indicadorSelect);
        
        consultaIndicadores.indicadorSelect = 'MAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'ACM';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'PEL';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'PTP';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'FA';
        consultaIndicadores.consultar();
        Test.StopTest();
    }
    
    static testMethod void SST_IndicadoresResultadoTest7(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Date hoy = system.today();
        hoy = hoy.toStartOfMonth();
        hoy = hoy.addDays(-1);
        
        Account cuenta = new Account();
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.sst_Frecuencia_IEL__c = '1';
        cuenta.sst_meta_IEL__c = 1;
        cuenta.sst_Frecuencia_IFA__c = '1';
        cuenta.sst_meta_IFA__c = 1;
        cuenta.sst_Frecuencia_IFAT__c = '1';
        cuenta.sst_meta_IFAT__c = 1;
        cuenta.sst_Frecuencia_IFIAT__c = '1';
        cuenta.sst_meta_IFIAT__c = 1;
        cuenta.sst_Frecuencia_ILIAT__c = '1';
        cuenta.sst_meta_ILIAT__c = 1;
        cuenta.sst_Frecuencia_ISAT__c = '1';
        cuenta.sst_meta_ISAT__c = 1;
        cuenta.sst_Frecuencia_MAT__c = '1';
        cuenta.sst_meta_MAT__c = 1;
        cuenta.sst_Frecuencia_ACM__c = '1';
        cuenta.sst_meta_ACM__c = 1;
        cuenta.sst_Frecuencia_PEL__c = '1';
        cuenta.sst_meta_PEL__c = 1;
        cuenta.sst_Frecuencia_PTP__c = '1';
        cuenta.sst_meta_PTP__c = 1;
        cuenta.sst_Frecuencia_FA__c = '1';
        cuenta.sst_meta_FA__c = 1;
        cuenta.sst_Frecuencia_SA__c = '1';
        cuenta.SST_Meta_SA__c = 1;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.sst_estado__c = SST_Constantes.ACTIVO;
        cuenta.SST_Cuenta_indicadores_globales__c = true;
        insert cuenta;
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     
        
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();     
        
        SST_IndicadoresResultadoCC consultaIndicadores = new SST_IndicadoresResultadoCC();
        consultaIndicadores.getIndicadores();
        consultaIndicadores.fechaFin = hoy;
        
        consultaIndicadores.indicadorSelect = 'ISAT';
        consultaIndicadores.consultar();
        System.assert('ISAT' == consultaIndicadores.indicadorSelect);
        
        consultaIndicadores.indicadorSelect = 'MAT';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'ACM';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'PEL';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'PTP';
        consultaIndicadores.consultar();
        
        consultaIndicadores.indicadorSelect = 'FA';
        consultaIndicadores.consultar();
        
		consultaIndicadores.indicadorSelect = 'SA';
        consultaIndicadores.consultar();
        Test.StopTest();
    }
    
    static testMethod void SST_IndicadoresResultadoTest8(){
        Test.StartTest();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Date hoy = system.today();
        hoy = hoy.toStartOfMonth();
        hoy = hoy.addDays(-1);
        
        Account cuenta = new Account();
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.sst_Frecuencia_IEL__c = '1';
        cuenta.sst_meta_IEL__c = 1;
        cuenta.sst_Frecuencia_IFA__c = '1';
        cuenta.sst_meta_IFA__c = 1;
        cuenta.sst_Frecuencia_IFAT__c = '1';
        cuenta.sst_meta_IFAT__c = 1;
        cuenta.sst_Frecuencia_IFIAT__c = '1';
        cuenta.sst_meta_IFIAT__c = 1;
        cuenta.sst_Frecuencia_ILIAT__c = '1';
        cuenta.sst_meta_ILIAT__c = 1;
        cuenta.sst_Frecuencia_ISAT__c = '1';
        cuenta.sst_meta_ISAT__c = 1;
        cuenta.sst_Frecuencia_MAT__c = '1';
        cuenta.sst_meta_MAT__c = 1;
        cuenta.sst_Frecuencia_ACM__c = '1';
        cuenta.sst_meta_ACM__c = 1;
        cuenta.sst_Frecuencia_PEL__c = '1';
        cuenta.sst_meta_PEL__c = 1;
        cuenta.sst_Frecuencia_PTP__c = '1';
        cuenta.sst_meta_PTP__c = 1;
        cuenta.sst_Frecuencia_FA__c = '1';
        System.assert('1' == cuenta.sst_Frecuencia_FA__c);
        cuenta.sst_meta_FA__c = 1;
        cuenta.SST_periodo_notificacion__c = 1;
        insert cuenta;
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Funcionarios').getRecordTypeId();     
        
        ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
        ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
        ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();     
        
        SST_IndicadoresResultadoCC consultaIndicadores = new SST_IndicadoresResultadoCC();
        //System.assert(consultaIndicadores.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('No hay ninguna empresa configurada como cuenta principal'));
        Test.StopTest();
    }
}