@isTest
public class SST_MatrizPeligroSPCCTest {
    static testMethod void SST_MatrizPeligroSPCCTest(){
        
        SST_Cargo__c cargo = new SST_Cargo__c();
        cargo.Name = 'Cargo prueba';
        insert (cargo);
        
        SST_Area_trabajo__c area = new SST_Area_trabajo__c();
        area.name = 'Area prueba';
        area.estado__c = 'ACTIVO';
        insert(area);
        
        SST_Elemento_Proteccion_Personal__c epp = new SST_Elemento_Proteccion_Personal__c();
        epp.Name ='Casco';
        epp.Codigo__c = '01';
        epp.Zona_proteccion__c ='CABEZA';
        epp.Estado__c ='ACTIVO';
        epp.Vida_util__c = 1;
        insert(epp);
        
        SST_Formacion__c capacitacion = new SST_Formacion__c();
        capacitacion.recordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Entrenamientos').getRecordTypeId();
        capacitacion.Nombre__c = 'Capacitación';
        capacitacion.Descripcion__c = 'Esta es una formación de tipo Entrenamiento';
        insert (capacitacion);
        
        //Se crean los cargos de prueba
        ID idCargoFuncionario = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        SST_Cargo__c cargoFuncionario = New SST_Cargo__c();
        cargoFuncionario.RecordTypeId=idCargoFuncionario;
        cargoFuncionario.Name='Cargo Funcionario';
        insert cargoFuncionario;
        
        ID idResponsabilidadCargo = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();     
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
        
        SST_Peligro_SP__c peligro = new SST_Peligro_SP__c();
        peligro.area__c = area.id;
        peligro.Rutinaria__c = true;
        peligro.Expuesto__c = 'Funcionarios';
        peligro.Peligro__c = 'peligro';
        peligro.Fuente_Generadora_Peligro__c = 'Fuente generadora del peligro';
        peligro.Efectos_Salud_Propiedad__c = 'Efectos posibles prueba';
        peligro.Fuente__c = 'fuente de prueba';
        peligro.medio__c= 'medio de prueba';
        peligro.Trabajador__c = 'individuo de prueba';
        insert(peligro);
        
        SST_Peligro_SP__c peligroGuardado = new SST_Peligro_SP__c();
        peligroGuardado.area__c = area.id;
        peligroGuardado.Efectos_Salud_Propiedad__c = 'Efectos posibles prueba';
        peligroGuardado.Fuente__c = 'fuente de prueba';
        peligroGuardado.medio__c= 'medio de prueba';
        peligroGuardado.Trabajador__c = 'individuo de prueba';
        peligroGuardado.Metodo__c = 'Método de prueba';
        peligroGuardado.Nivel_Deficiencia__c ='2';
        peligroGuardado.Nivel_Exposicion__c ='1';
        peligroGuardado.Nivel_Consecuencia__c ='25';
        peligroGuardado.EPP__c ='Casco';
        peligroGuardado.Capacitacion__c ='Normatividad prueba';
        insert(peligroGuardado);
        
        peligroGuardado.nivel_Deficiencia__c ='10';
        peligroGuardado.nivel_Exposicion__c ='4';
        peligroGuardado.Nivel_Consecuencia__c ='100';
		peligroGuardado.id = null;
        insert(peligroGuardado);
        
        peligroGuardado.nivel_Deficiencia__c ='2';
        peligroGuardado.nivel_Exposicion__c ='3';
        peligroGuardado.Nivel_Consecuencia__c ='25';
        peligroGuardado.id = null;
        insert(peligroGuardado);
        
        peligroGuardado.nivel_Deficiencia__c ='2';
        peligroGuardado.nivel_Exposicion__c ='1';
        peligroGuardado.nivel_Consecuencia__c ='10';
        peligroGuardado.id = null;
        insert(peligroGuardado);
        
        SST_MatrizPeligroSPCC controlador = new SST_MatrizPeligroSPCC();
        controlador.getNivelesConsecuencia();
        controlador.getNivelesDeficiencia();
        controlador.getNivelesExposicion();
        controlador.getAreas();
        controlador.getEstados(); 
        
        /*se selecciona uno de los peligros*/
        System.currentPagereference().getParameters().put('idPeligro',peligro.id);
        controlador.seleccionarPeligroEvaluacion();
        controlador.getSelectedCAPValues();
        controlador.getunSelectedCAPValues();
        controlador.getSelectedValues();
        controlador.getunSelectedValues(); 
        
        /*se le ingresan valores del formulario*/
        controlador.peligroSeleccionado.nivelDeficiencia =6;
        controlador.peligroSeleccionado.nivelExposicion = 3;
        controlador.peligroSeleccionado.nivelConsecuencia = 25;
        controlador.peligroSeleccionado.sustituir='Sustituir';
        controlador.obtenerInterpretacion();
        controlador.obtenerInterpretacionRiesgo();
        controlador.leftEPPSelected.add('Casco');
        controlador.selectclick();
        controlador.leftCAPSelected.add('Capacitación prueba');
        controlador.selectCAPClick();
        controlador.guardarPeligro();
        
        System.currentPagereference().getParameters().put('idPeligro',peligroGuardado.id);
        controlador.seleccionarPeligroEvaluacion();
        controlador.peligroSeleccionado.numeroTrabajadoresExpuestos = 2;
        controlador.guardarPeligro();
        
		controlador.peligroSeleccionado.controlesIngenieria = 'Controles de ingeniería';
        controlador.peligroSeleccionado.controlesAdministrativos = 'Controles administrativos';
        controlador.peligroSeleccionado.eliminar = 'Eliminar';
        controlador.guardarPeligro();
        //System.assert(controlador.mensajesPaginaPrincipal.get(0).mensajePage.contains('se ha evaluado')||controlador.mensajesPaginaPrincipal.get(0).mensajePage.contains('Permisos'));

        
        controlador.consultarExpuestos();
        
        controlador.area='Area prueba';
        controlador.consultarPeligros();
        controlador.verAnterior();
        controlador.verInicio();
        controlador.verSiguiente();
        controlador.verFinal();
        
        
    }   

}