@isTest
public class SST_EstandaresMinimosCCTest {
    
    static testMethod void SST_EstandaresMinimosCCTest(){
        
        SST_Estandar_minimo__c estandarPlanear = new SST_Estandar_minimo__c();	
        estandarPlanear.Ciclo__c = SST_Constantes.CICLO_PLANEAR;
        estandarPlanear.Estandar_agrupador__c = 'RECURSOS (10%)';
        estandarPlanear.Estandar__c = 'Recursos financieros, técnicos,  humanos y de otra índole requeridos para coordinar y desarrollar el Sistema de Gestión de la Seguridad y la Salud en el Trabajo (SG-SST) (4%)';
		estandarPlanear.Item_estandar__c ='1.1.1. Responsable del Sistema de Gestión de Seguridad y Salud en el Trabajo SG-SST';            
        estandarPlanear.cumplimiento__c ='CUMPLE';
        estandarPlanear.Puntaje__c = 0.5;
        estandarPlanear.Justificacion__c = 'Justificación';
        
        
       	SST_Estandar_minimo__c estandarHacer = new SST_Estandar_minimo__c();	
        estandarHacer.Ciclo__c = SST_Constantes.CICLO_HACER;
        estandarHacer.Estandar_agrupador__c = 'GESTIÓN DE LA SALUD (20%)';
        estandarHacer.Estandar__c = 'Condiciones de salud en el trabajo (9%)';
		estandarHacer.Item_estandar__c ='3.1.1 Evaluación Médica Ocupacional';            
        estandarHacer.cumplimiento__c ='NO_CUMPLE';
        estandarHacer.Puntaje__c = 1.00;
        estandarPlanear.Justificacion__c = 'Justificación';
        
       	SST_Estandar_minimo__c estandarVerificar = new SST_Estandar_minimo__c();	
        estandarVerificar.Ciclo__c = SST_Constantes.CICLO_VERIFICAR;
        estandarVerificar.Estandar_agrupador__c = 'VERIFICACIÓN DEL SG-SST (5%)';
        estandarVerificar.Estandar__c = 'Gestión y resultados del SG-SST (5%)';
		estandarVerificar.Item_estandar__c ='6.1.1 Indicadores estructura, proceso y resultado';            
        estandarVerificar.cumplimiento__c ='NO_APLICA';
        estandarVerificar.Justificacion__c = 'El estándar no aplica';
        estandarVerificar.Puntaje__c = 1.25;
        estandarPlanear.Justificacion__c = 'Justificación';
        System.assert(Double.valueOf('1.25')==estandarVerificar.Puntaje__c);
        
        SST_Estandar_minimo__c estandarActuar= new SST_Estandar_minimo__c();	
        estandarActuar.Ciclo__c = SST_Constantes.CICLO_ACTUAR;
        estandarActuar.Estandar_agrupador__c = 'MEJORAMIENTO (10%)';
        estandarActuar.Estandar__c = 'Acciones preventivas y correctivas con base en los resultados del SG-SST (10%)';
		estandarActuar.Item_estandar__c ='7.1.1 Definir acciones de Promoción y Prevención con base en resultados del Sistema de Gestión de Seguridad y Salud en el Trabajo SG-SST';            
        estandarActuar.cumplimiento__c ='NO_APLICA';
        estandarActuar.Puntaje__c = 2.50;
        estandarPlanear.Justificacion__c = 'Justificación';
        
        /*se añaden los estandares a guardar*/
        List<SST_Estandar_minimo__c> estandares = new List<SST_Estandar_minimo__c>();
        estandares.add(estandarPlanear);
        estandares.add(estandarHacer);
        estandares.add(estandarVerificar);
        estandares.add(estandarActuar);
        
        insert(estandares);
        
       
        
        ApexPages.currentPage().getHeaders().put('Referer', 'test');
        SST_EstandaresMinimosCC  controlador = new SST_EstandaresMinimosCC();
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;     
        
        SST_Calificacion_norma__c calificacionNorma = new SST_Calificacion_norma__c();
        calificacionNorma.calificacion__c = controlador.total;
        calificacionNorma.norma_calificada__c = 'ESTANDAR MINIMO';
        calificacionNorma.Comentarios__c='comentarios';
        calificacionNorma.ultima_calificacion__c=true;
        calificacionNorma.empresa__c = empresa;
        insert(calificacionNorma);
        
        
        controlador.getCumplimiento();
        controlador.cicloActual = estandarPlanear.ciclo__c;
        controlador.estandarAgrupadorActual = estandarPlanear.Estandar_agrupador__c;
        controlador.estandarActual = estandarPlanear.Estandar__c; 
        controlador.actualizarCalificacion();
        controlador.guardarEvaluacionEstandar();
        controlador.generarReporteEstandaresMinimos();
        try{
        controlador.guardarCalificacion(controlador.total,calificacionNorma.norma_calificada__c);
        }catch(Exception e){
            
        }
        
        Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
        ApexPages.currentPage().getHeaders().put('Referer', 'test');
        SST_EstandaresMinimosCC  controladorConEncabezado = new SST_EstandaresMinimosCC();
        
        
  
    }

}