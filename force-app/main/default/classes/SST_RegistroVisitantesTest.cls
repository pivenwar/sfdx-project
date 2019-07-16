/**Clase test para el controlador del registro de visitantes.
*/
@isTest
public class SST_RegistroVisitantesTest {

    /*Método que realiza el test para el caso de un visitante ocasional*/
    public static testMethod void SST_RegistroVisitantesCC(){
        Test.StartTest();
        
        String empresa = SST_TestDataFactory.returnEmpresa();
        /*se crea una cuenta con lector de cédula*/
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        SST_Cargo__c cargo = SST_TestDataFactory.crearCargoFuncionario();
        Contact funcionario = SST_TestDataFactory.crearFuncionario(cuenta,cargo);
        Contact contratista = SST_TestDataFactory.crearContratista(cuenta);
        
        SST_RegistroVisitantesCC registroVisitantes = new SST_RegistroVisitantesCC();
        /*Ejecución de los metodos que alimentan las listas desplegables*/
        registroVisitantes.getARL();
        registroVisitantes.getEPS();
        registroVisitantes.getTipoSangre();
        registroVisitantes.getTiposIdentificacion();
        
        
        /*Ingreso para visitante ocasional*/
        registroVisitantes.tipoIdentificacion = 'C';
        registroVisitantes.numeroIdentificacion = '2890';
		registroVisitantes.nombreFiltro = 'Toro Angelica';
        registroVisitantes.tipoSangreFiltro = 'A-';
        registroVisitantes.consultarVisitante();
        registroVisitantes.nombreFuncionarioFiltro ='Mar';
        registroVisitantes.consultarFuncionario();
        /*Se ingresan los datos de la visita y se guarda la visita*/
        registroVisitantes.funcionarioSeleccionado= funcionario.id;
        registroVisitantes.seleccionarFuncionario();
        registroVisitantes.visitante.arl = '860002183';
        registroVisitantes.visitante.contactoEmergencia = 'Contacto de emergencia';
        registroVisitantes.visitante.eps = '830113831';
        registroVisitantes.visitante.telefonoEmergencia = '74845';
        registroVisitantes.visitante.observaciones='Observacion visitante';
        registroVisitantes.visitante.empresaRepresentacion='Heinsohn';
		registroVisitantes.guardarVisitante();
        
        /*registro de salida*/
        registroVisitantes.tipoIdentificacion = 'C';
        registroVisitantes.numeroIdentificacion = '2890';
		registroVisitantes.nombreFiltro = 'Toro Angelica';
        registroVisitantes.tipoSangreFiltro = 'A-';
        registroVisitantes.consultarVisitante();
        
        /*se registra una nueva entrada para el el mismo ocasional*/
        registroVisitantes.tipoIdentificacion = 'C';
        registroVisitantes.numeroIdentificacion = '2890';
		registroVisitantes.nombreFiltro = 'Toro Angelica';
        registroVisitantes.tipoSangreFiltro = 'A-';
        registroVisitantes.consultarVisitante();
        registroVisitantes.nombreFuncionarioFiltro ='Mar';
        registroVisitantes.consultarFuncionario();
        /*Se ingresan los datos de la visita y se guarda la visita*/
        registroVisitantes.funcionarioSeleccionado= funcionario.id;
        registroVisitantes.seleccionarFuncionario();
        registroVisitantes.visitante.arl = '860002183';
        registroVisitantes.visitante.contactoEmergencia = 'Contacto de emergencia';
        registroVisitantes.visitante.eps = '830113831';
        registroVisitantes.visitante.telefonoEmergencia = '74845';
        registroVisitantes.visitante.observaciones='Observacion visitante';
        registroVisitantes.visitante.empresaRepresentacion='Heinsohn';
		registroVisitantes.guardarVisitante();
        
        /*Ingreso de los filtros para buscar el visitante*/
        registroVisitantes.tipoIdentificacion = 'C';
        registroVisitantes.numeroIdentificacion = '001094907';
		registroVisitantes.nombreFiltro = 'Perez Mario';
        registroVisitantes.consultarVisitante();
       	/*si falta algún filtro debe sacar mensaje de error*/
        //System.Assert(registroVisitantes.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Debe ingresar los campos requeridos para realizar la búsqueda'));
        registroVisitantes.tipoSangreFiltro = 'A+';
        registroVisitantes.consultarVisitante();
        /*se selecciona el funcionario destino*/
        registroVisitantes.nombreFuncionarioFiltro ='Mar';
        registroVisitantes.consultarFuncionario();
        /*Se ingresan los datos de la visita y se guarda la visita*/
        registroVisitantes.funcionarioSeleccionado= funcionario.id;
        registroVisitantes.seleccionarFuncionario();
        registroVisitantes.visitante.arl = '860002183';
        registroVisitantes.visitante.contactoEmergencia = 'Contacto de emergencia';
        registroVisitantes.visitante.eps = '830113831';
        registroVisitantes.visitante.observaciones='Observacion visitante';
		registroVisitantes.guardarVisitante();
        System.debug(registroVisitantes.mensajesPaginaPrincipal.get(0).mensajePage);
        System.Assert(registroVisitantes.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Todos los campos del formulario son obligatorios, por favor diligencie la información')||
                     registroVisitantes.mensajesPaginaPrincipal.get(0).mensajePage.startsWith('Permisos'));
        registroVisitantes.visitante.telefonoEmergencia = '74845';
        registroVisitantes.visitante.empresaRepresentacion = 'La nueva empresa';
        registroVisitantes.guardarVisitante();
        System.Assert(!registroVisitantes.mensajesPaginaPrincipal.isEmpty());
       	/*Ingreso de los filtros para buscar el visitante, y registrar salida*/
        registroVisitantes.tipoIdentificacion = 'C';
        registroVisitantes.numeroIdentificacion = '01094907';
		registroVisitantes.nombreFiltro = 'Perez Mario';
        registroVisitantes.consultarVisitante();
        registroVisitantes.tipoSangreFiltro = 'A+';
        registroVisitantes.consultarVisitante();
        
       	/*Ingreso de los filtros para buscar el visitante,en este caso existe como contratista*/
        id idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();
        registroVisitantes.tipoIdentificacion = 'C';
        registroVisitantes.numeroIdentificacion = '000'+contratista.sst_identificacion__C;
		registroVisitantes.nombreFiltro = 'Pereira Maria';
        registroVisitantes.tipoSangreFiltro = 'A-';
        registroVisitantes.consultarVisitante();
        /*se selecciona el funcionario destino*/
        registroVisitantes.nombreFuncionarioFiltro ='Mar';
        registroVisitantes.consultarFuncionario();
        /*Se ingresan los datos de la visita y se guarda la visita*/
        registroVisitantes.funcionarioSeleccionado= funcionario.id;
        registroVisitantes.seleccionarFuncionario();
        registroVisitantes.visitante.arl = '860002183';
        registroVisitantes.visitante.contactoEmergencia = 'Contacto de emergencia';
        registroVisitantes.visitante.eps = '830113831';
        registroVisitantes.visitante.telefonoEmergencia = '74845';
        registroVisitantes.visitante.observaciones='Observacion visitante';
		registroVisitantes.guardarVisitante();
        
                
        
        Test.stopTest();
    }
    
}