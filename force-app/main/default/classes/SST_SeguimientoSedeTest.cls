/**
* Clase test que da cubrimiento a SST_SeguimientoSedeCC
* @date 29/08/2018
*/

@isTest
public class SST_SeguimientoSedeTest {
    
    public static testMethod void SST_SeguimientoSedeTest(){
        ID idPlan = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosByName().get('Planes y Programas').getRecordTypeId();     

        
        SST_Seguimiento__c seguimientoPlan = new SST_Seguimiento__c();
        seguimientoPlan.RecordTypeId = idPlan;
        seguimientoPlan.Name = 'Seguimiento plan';
        seguimientoPlan.Tipo__c = SST_Constantes.TIPO_PLAN_ANUAL_TRABAJO;
        seguimientoPlan.Fecha_inicial__c = system.today();
        seguimientoPlan.Fecha_final__c = system.today();
        seguimientoPlan.Objetivo__c = 'test plan';
        Insert seguimientoPlan;
   
        SST_sede__c sede = new SST_sede__c();
        sede.name = 'sede';
        sede.Departamento__c = '91';
        sede.Municipio__c = '99878';
        sede.Direccion__c = 'direccion';
        sede.Zona__c = 'URBANA';
        sede.Estado__c = SST_Constantes.ACTIVO;
        Insert sede;
        
        SST_sede__c sede2 = new SST_sede__c();
        sede2.name = 'sede 2';
        sede2.Departamento__c = '91';
        sede2.Municipio__c = '99878';
        sede2.Direccion__c = 'direccion';
        sede2.Zona__c = 'URBANA';
        sede2.Estado__c = SST_Constantes.ACTIVO;
        Insert sede2;
        
        SST_Seguimiento_sede__c asociacion = new SST_Seguimiento_sede__c();
        asociacion.seguimiento__c = seguimientoPlan.id;
        asociacion.Sede__c = sede.Id;
        insert asociacion;
      
        ApexPages.StandardController sc = new ApexPages.StandardController(seguimientoPlan);
	    SST_SeguimientoSedeCC controlador = new SST_SeguimientoSedeCC(sc);
        controlador.selectedValues.add(controlador.unselectedValues.get(0));
        controlador.unselectedValues.add(controlador.selectedValues.get(0));
        controlador.selectedValues.remove(0);
        
        controlador.guardar();
        System.assert(('Se han actualizado las sedes para el seguimiento en forma exitosa')==controlador.mensaje||('Permisos insuficientes para eliminar o registrar asociaciones de cargos con Elementos de Protección Personal')==controlador.mensaje);

        controlador.regresar();
    }

}