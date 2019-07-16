@IsTest
public class SST_Estatus1072Test {
    static testMethod void SST_Estatus1072Test(){
        List <SST_Status_Implementacion_1072__c> registrosCiclo1 = new List <SST_Status_Implementacion_1072__c>();
        SST_Status_Implementacion_1072__c registro1Ciclo1 = new SST_Status_Implementacion_1072__c();
        registro1Ciclo1.idExterno__c = '001';
        registro1Ciclo1.Descripcion__c = 'Ciclo I';
        registro1Ciclo1.Peso__c = 0;
        registrosCiclo1.add(registro1Ciclo1);
        
        SST_Status_Implementacion_1072__c registro1Ciclo2 = new SST_Status_Implementacion_1072__c();
        registro1Ciclo2.idExterno__c = '002';
        registro1Ciclo2.Descripcion__c = 'Ciclo II';
        registro1Ciclo2.Peso__c = 0;
        registrosCiclo1.add(registro1Ciclo2);
        
        SST_Status_Implementacion_1072__c registro1Ciclo3 = new SST_Status_Implementacion_1072__c();
        registro1Ciclo3.idExterno__c = '003';
        registro1Ciclo3.Descripcion__c = 'Ciclo III';
        registro1Ciclo3.Peso__c = 0;
        registrosCiclo1.add(registro1Ciclo3);
        
        SST_Status_Implementacion_1072__c registro1Ciclo4 = new SST_Status_Implementacion_1072__c();
        registro1Ciclo4.idExterno__c = '004';
        registro1Ciclo4.Descripcion__c = 'Ciclo IV';
        registro1Ciclo4.Peso__c = 0;
        registrosCiclo1.add(registro1Ciclo4);
        
        SST_Status_Implementacion_1072__c registro1Ciclo5 = new SST_Status_Implementacion_1072__c();
        registro1Ciclo5.idExterno__c = '005';
        registro1Ciclo5.Descripcion__c = 'Ciclo V';
        registro1Ciclo5.Peso__c = 0;
        registrosCiclo1.add(registro1Ciclo5);
        
        Insert registrosCiclo1;
        
        List <SST_Status_Implementacion_1072__c> registrosArticulos = new List <SST_Status_Implementacion_1072__c>();
        
        SST_Status_Implementacion_1072__c registroArticuloCiclo1 = new SST_Status_Implementacion_1072__c();
        registroArticuloCiclo1.idExterno__c = '006';
        registroArticuloCiclo1.Descripcion__c = 'Articulo I';
        registroArticuloCiclo1.Padre__c = registro1Ciclo1.Id;
        registroArticuloCiclo1.Peso__c = 0;
        registrosArticulos.add(registroArticuloCiclo1);
        
        SST_Status_Implementacion_1072__c registroArticuloCiclo2 = new SST_Status_Implementacion_1072__c();
        registroArticuloCiclo2.idExterno__c = '007';
        registroArticuloCiclo2.Descripcion__c = 'Articulo II';
        registroArticuloCiclo2.Padre__c = registro1Ciclo2.Id;
        registroArticuloCiclo2.Peso__c = 0;
        registrosArticulos.add(registroArticuloCiclo2);
        
        SST_Status_Implementacion_1072__c registroArticuloCiclo3 = new SST_Status_Implementacion_1072__c();
        registroArticuloCiclo3.idExterno__c = '008';
        registroArticuloCiclo3.Descripcion__c = 'Articulo III';
        registroArticuloCiclo3.Padre__c = registro1Ciclo3.Id;
        registroArticuloCiclo3.Peso__c = 0;
        registrosArticulos.add(registroArticuloCiclo3);
        
        SST_Status_Implementacion_1072__c registroArticuloCiclo4 = new SST_Status_Implementacion_1072__c();
        registroArticuloCiclo4.idExterno__c = '009';
        registroArticuloCiclo4.Descripcion__c = 'Articulo IV';
        registroArticuloCiclo4.Padre__c = registro1Ciclo4.Id;
        registroArticuloCiclo4.Peso__c = 0;
        registrosArticulos.add(registroArticuloCiclo4);
        
        SST_Status_Implementacion_1072__c registroArticuloCiclo5 = new SST_Status_Implementacion_1072__c();
        registroArticuloCiclo5.idExterno__c = '010';
        registroArticuloCiclo5.Descripcion__c = 'Articulo V';
        registroArticuloCiclo5.Padre__c = registro1Ciclo5.Id;
        registroArticuloCiclo5.Peso__c = 0;
        registrosArticulos.add(registroArticuloCiclo5);
        
        insert registrosArticulos;
        
        List <SST_Status_Implementacion_1072__c> registrosActividades = new List <SST_Status_Implementacion_1072__c>();
        
        SST_Status_Implementacion_1072__c registroActividad1 = new SST_Status_Implementacion_1072__c();
        registroActividad1.idExterno__c = '011';
        registroActividad1.Descripcion__c = 'Actividad I';
        registroActividad1.Padre__c = registroArticuloCiclo1.Id;
        registroActividad1.Cumplimiento__c = SST_Constantes.CUMPLE;
        registroActividad1.Peso__c = 20;
        registroActividad1.Prioridad__c = 'Alta';
        registrosActividades.add(registroActividad1);
        
        SST_Status_Implementacion_1072__c registroActividad2 = new SST_Status_Implementacion_1072__c();
        registroActividad2.idExterno__c = '012';
        registroActividad2.Descripcion__c = 'Actividad II';
        registroActividad2.Padre__c = registroArticuloCiclo2.Id;
        registroActividad2.Cumplimiento__c = SST_Constantes.NO_CUMPLE;
        registroActividad2.Justificacion__c = 'Justificado';
        registroActividad2.Peso__c = 20;
        registroActividad2.Prioridad__c = 'Alta';
        registrosActividades.add(registroActividad2);
        
        SST_Status_Implementacion_1072__c registroActividad3 = new SST_Status_Implementacion_1072__c();
        registroActividad3.idExterno__c = '013';
        registroActividad3.Descripcion__c = 'Actividad III';
        registroActividad3.Padre__c = registroArticuloCiclo3.Id;
        registroActividad3.Cumplimiento__c = SST_Constantes.NO_APLICA;
        registroActividad3.Peso__c = 20;
        registroActividad3.Prioridad__c = 'Alta';
        registrosActividades.add(registroActividad3);
        
        SST_Status_Implementacion_1072__c registroActividad4 = new SST_Status_Implementacion_1072__c();
        registroActividad4.idExterno__c = '014';
        registroActividad4.Descripcion__c = 'Actividad IV';
        registroActividad4.Padre__c = registroArticuloCiclo4.Id;
        registroActividad4.Cumplimiento__c = SST_Constantes.CUMPLE_PARCIALMENTE;
        registroActividad4.Peso__c = 20;
        registroActividad4.Prioridad__c = 'Alta';
        registrosActividades.add(registroActividad4);
        
        SST_Status_Implementacion_1072__c registroActividad5 = new SST_Status_Implementacion_1072__c();
        registroActividad5.idExterno__c = '015';
        registroActividad5.Descripcion__c = 'Actividad V';
        registroActividad5.Padre__c = registroArticuloCiclo5.Id;
        registroActividad5.Cumplimiento__c = SST_Constantes.NO_CUMPLE;
        registroActividad5.Peso__c = 20;
        registroActividad5.Prioridad__c = 'Alta';
        registrosActividades.add(registroActividad5);
        
        
        insert registrosActividades;
        
        SST_Estatus1072CC controlador = new SST_Estatus1072CC();
        controlador.puntajeTotalParametrizacion = 0;
        controlador.llenarListas();
        controlador.getPrioridad();
        controlador.idModificarParametrizacion = ApexPages.currentPage().getHeaders().put('itemModificar', registroActividad5.id);
        controlador.actualizarValoresParametrizacion();
        controlador.idModificarEvaluacion = ApexPages.currentPage().getHeaders().put('itemModificar', registroActividad5.id);
        controlador.actualizarValoresEvaluacion();
        controlador.guardarParametrizacion();
        controlador.GuardarEvaluacion();
        controlador.generarReporteEstatusImplementacion();
        System.assert(controlador.mensajesPaginaPrincipalEvaluacion.get(0).mensajePage.startsWith('La evaluaciones fueron actualizadas exitosamente.')||controlador.mensajesPaginaPrincipalEvaluacion.get(0).mensajePage.startsWith('Permisos'));
        
        SST_Estatus1072CC controlador2 = new SST_Estatus1072CC();
        controlador2.puntajeTotalParametrizacion = 0;
        controlador2.llenarListas();
        controlador2.getPrioridad();
        controlador2.idModificarEvaluacion = ApexPages.currentPage().getHeaders().put('itemModificar', registroActividad5.id);
        controlador2.actualizarValoresEvaluacion();
        controlador2.idModificarParametrizacion = ApexPages.currentPage().getHeaders().put('itemModificar', registroActividad5.id);
        controlador2.actualizarValoresParametrizacion();
        controlador2.guardarParametrizacion();
        controlador2.GuardarEvaluacion();
        controlador2.generarReporteEstatusImplementacion();
        System.assert(controlador2.mensajesPaginaPrincipalEvaluacion.get(0).mensajePage.startsWith('La evaluaciones fueron actualizadas exitosamente.')||controlador2.mensajesPaginaPrincipalEvaluacion.get(0).mensajePage.startsWith('Permisos'));

		String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;     
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        SST_Estatus1072CC controladorConCuenta = new SST_Estatus1072CC();
        
     }
    
}