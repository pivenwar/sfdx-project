@isTest
public class SST_MatrizPeligroCCTest {
    static testMethod void SST_MatrizPeligroCCTest(){
        
        SST_Cargo__c cargo = new SST_Cargo__c();
        cargo.Name = 'Cargo prueba';
        insert (cargo);
        
        SST_Area_trabajo__c area = new SST_Area_trabajo__c();
        area.name = 'Area prueba';
        area.estado__c = 'ACTIVO';
        insert(area);
        
        SST_Sede__c sede = new SST_Sede__c();
        sede.name = 'Fábrica Armenia';
        sede.departamento__c ='63';
        sede.municipio__c = '63001';
        sede.direccion__c = 'CARRERA 19 # 15N40';
        sede.zona__c = 'URBANA';
        sede.estado__c = 'ACTIVO';
        insert(sede);
        
        SST_Proceso__c proceso = new SST_Proceso__c();
        proceso.Name='Proceso prueba';
        insert(proceso);
        
        SST_Elemento_Proteccion_Personal__c epp = new SST_Elemento_Proteccion_Personal__c();
        epp.Name ='Casco';
        epp.Codigo__c = '01';
        epp.Zona_proteccion__c ='CABEZA';
        epp.Estado__c ='ACTIVO';
        epp.Vida_util__c = 1;
        insert(epp);
       
        SST_Normatividad__c normatividadEmpresa = New SST_Normatividad__c();
        normatividadEmpresa.name ='Normatividad prueba';
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
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        //String objectType =  Schema.SObjectType.SST_Cargo__c.getName();
        //List <RecordType> recordTypeCargo = [SELECT Id, Name, SobjectType FROM RecordType where SobjectType = :objectType order by name];
        //RecordType recordTypeFuncionario = recordTypeCargo.get(1);
        
        //Se crean los cargos de prueba
        SST_Cargo__c cargoFuncionario = New SST_Cargo__c();
        cargoFuncionario.RecordTypeId=idCargoFuncionario;
        cargoFuncionario.Name='Cargo Funcionario';
        insert cargoFuncionario;
        
        ID idResponsabilidadCargo = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();     
        //objectType =  Schema.SObjectType.SST_Formacion__c.getName();
        //List <RecordType> recordTypeResponsabilidad = [SELECT Id, Name, SobjectType FROM RecordType where SobjectType = :objectType and name like '%cargos%'];
        //RecordType recordTypeCargoFuncionario = recordTypeResponsabilidad.get(0);
        
        SST_Formacion__c responsabilidadFuncionario1 = new SST_Formacion__c();
        responsabilidadFuncionario1.RecordTypeId = idResponsabilidadCargo;
        responsabilidadFuncionario1.Tipo_Cargo__c = 'CARGO FUNCIONARIO';
        responsabilidadFuncionario1.Nombre__c = 'Responsabilidad';
        responsabilidadFuncionario1.Descripcion__c = 'Esta es una responsabilidad de funcionario de prueba';
        insert responsabilidadFuncionario1;
        
        SST_Formacion_cargo__c responsabilidadAsociada = new SST_Formacion_cargo__c();
        responsabilidadAsociada.formacion__c=responsabilidadFuncionario1.id;
        responsabilidadAsociada.Cargo__c=cargoFuncionario.id;
        insert(responsabilidadAsociada);
        
        SST_Formacion__c responsabilidadFuncionario2 = new SST_Formacion__c();
        responsabilidadFuncionario2.RecordTypeId = idResponsabilidadCargo;
        responsabilidadFuncionario2.Tipo_Cargo__c = 'CARGO FUNCIONARIO';
        responsabilidadFuncionario2.Nombre__c = 'Responsabilidad 2';
        responsabilidadFuncionario2.Descripcion__c = 'Esta es una responsabilidad de funcionario de prueba';
        insert responsabilidadFuncionario2; 
         
        SST_Peligro__c peligro = new SST_Peligro__c();
        peligro.sede__c = sede.id;
        peligro.area__c = area.id;
        peligro.Responsabilidad_cargo__c = responsabilidadFuncionario1.id;
        peligro.proceso__c = proceso.id;
        peligro.Tarea__c = 'Tarea prueba de peligro';
        peligro.Efectos_posibles__c = 'Efectos posibles prueba';
        peligro.Fuente__c = 'fuente de prueba';
        peligro.medio__c= 'medio de prueba';
        peligro.Individuo__c = 'individuo de prueba';
        peligro.Clasificacion_peligro__c = 'RIESGO_FISICO';
        peligro.Tipo_clasificacion__c = 'RF01';
        insert(peligro);
        
        SST_Peligro__c peligroGuardado = new SST_Peligro__c();
        peligroGuardado.sede__c = sede.id;
        peligroGuardado.area__c = area.id;
        peligroGuardado.Responsabilidad_cargo__c = responsabilidadFuncionario2.id;
        peligroGuardado.proceso__c = proceso.id;
        peligroGuardado.Tarea__c = 'Tarea prueba de peligro';
        peligroGuardado.Efectos_posibles__c = 'Efectos posibles prueba';
        peligroGuardado.Fuente__c = 'fuente de prueba';
        peligroGuardado.medio__c= 'medio de prueba';
        peligroGuardado.Individuo__c = 'individuo de prueba';
        peligroGuardado.Clasificacion_peligro__c = 'RIESGO_FISICO';
        peligroGuardado.Tipo_clasificacion__c = 'RF01';
        peligroGuardado.nivel_Deficiencia__c ='2';
        peligroGuardado.nivel_Exposicion__c ='1';
        peligroGuardado.nivel_Consecuencia__c ='10';
        peligroGuardado.EPP__c ='Casco';
        peligroGuardado.Normatividad__c ='Normatividad prueba';
        insert(peligroGuardado);

        peligroGuardado.nivel_Deficiencia__c ='2';
        peligroGuardado.nivel_Exposicion__c ='3';
		peligroGuardado.id = null;
        insert(peligroGuardado);
        
        peligroGuardado.nivel_Deficiencia__c ='6';
        peligroGuardado.nivel_Exposicion__c ='4';
        peligroGuardado.id = null;
        insert(peligroGuardado);
        
        peligroGuardado.nivel_Deficiencia__c ='10';
        peligroGuardado.nivel_Exposicion__c ='4';
        peligroGuardado.nivel_Consecuencia__c ='100';
        peligroGuardado.id = null;
        insert(peligroGuardado);
        
        peligroGuardado.area__c =null;
        peligroGuardado.id = null;
        insert(peligroGuardado);
        
		peligroGuardado.area__c =null;
        peligroGuardado.id = null;
        insert(peligroGuardado);
        
        
        
        SST_MatrizPeligroCC controlador = new SST_MatrizPeligroCC();
        controlador.getNivelesConsecuencia();
        controlador.getNivelesDeficiencia();
        controlador.getNivelesExposicion();
        controlador.getAcciones();
        controlador.getSedes();
        controlador.getAreas();
        controlador.getProcesos();
        controlador.getEstados(); 
        controlador.getValoresAceptabilidad(); 
        
        /*se selecciona uno de los peligros*/
        System.currentPagereference().getParameters().put('idPeligro',peligro.id);
        controlador.seleccionarPeligroEvaluacion();
        
        /*se le ingresan valores del formulario*/
        controlador.peligroSeleccionado.nivelDeficiencia =6;
        controlador.peligroSeleccionado.nivelExposicion = 3;
        controlador.peligroSeleccionado.nivelConsecuencia = 25;
        controlador.peligroSeleccionado.accion='Sustituir';
        controlador.obtenerInterpretacion();
        controlador.obtenerInterpretacionRiesgo();
        controlador.guardarPeligro();
        
        /*se selecciona uno de los peligros*/
        System.currentPagereference().getParameters().put('idPeligro',peligro.id);
        controlador.seleccionarPeligroEvaluacion();
        
        /*se le ingresan valores del formulario*/
        controlador.peligroSeleccionado.nivelDeficiencia =10;
        controlador.peligroSeleccionado.nivelExposicion = 3;
        controlador.peligroSeleccionado.nivelConsecuencia = 25;
        controlador.peligroSeleccionado.accion='Sustituir';
        controlador.obtenerInterpretacion();
        controlador.obtenerInterpretacionRiesgo();
        controlador.guardarPeligro();
        
        
        
        
        System.currentPagereference().getParameters().put('idPeligro',peligroGuardado.id);
        controlador.seleccionarPeligroEvaluacion();
        controlador.peligroSeleccionado.nivelDeficiencia =10;
        controlador.peligroSeleccionado.nivelExposicion = 4;
        controlador.peligroSeleccionado.nivelConsecuencia = 100;
        controlador.peligroSeleccionado.numeroExpuestosPlanta = 2;
        controlador.peligroSeleccionado.numeroExpuestosContratistas = 3;
        controlador.peligroSeleccionado.peorConsecuencia = 'Peor consecuencia';
        controlador.obtenerInterpretacion();
        controlador.obtenerInterpretacionRiesgo();
        controlador.guardarPeligro();
        
        
        
       	controlador.peligroSeleccionado.controlesIngenieria = 'Controles de ingeniería';
        controlador.peligroSeleccionado.controlesAdministrativos = 'Controles administrativos';
        controlador.peligroSeleccionado.accion = 'Eliminar';
        controlador.guardarPeligro();
        System.assert(controlador.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Ocurrió un error guardando los datos del peligro, por favor contacte al administrador')||
                     controlador.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Permisos'));

        controlador.consultarExpuestos();
        
        controlador.area=area.id;
        controlador.proceso=proceso.id;
        controlador.sede=sede.id;
        controlador.consultarPeligros();
        controlador.verSiguiente();
        controlador.verAnterior();
        controlador.verInicio();
        controlador.verInicio();
        controlador.verFinal();
        
         
    } 
    
}