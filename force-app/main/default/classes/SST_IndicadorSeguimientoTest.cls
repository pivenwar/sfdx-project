@isTest
public class SST_IndicadorSeguimientoTest {
    
    public static testMethod void SST_IndicadorSeguimientoTest(){
        ID idPlan = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosByName().get('Planes y Programas').getRecordTypeId();     
        
        Date hoy = system.today();
        
         Schema.DescribeFieldResult fieldResult = contact.SST_empresa__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        
        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.SST_Estado__c = SST_Constantes.ACTIVO;
        insert cuenta;
        
        SST_Indicador__c indicador = New SST_Indicador__c();
        indicador.Nombre_Indicador__c = 'IEL';
        indicador.Fecha_Inicial__c = hoy;
        indicador.Fecha_Final__c = hoy.addDays(30);
        indicador.Calculo__c ='No se han registrado incapacidades en la empresa hasta el periodo seleccionado';
        indicador.Analisis__c = 'Análisis';
        indicador.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        insert indicador;
        
        SST_Seguimiento__c seguimiento = new SST_Seguimiento__c();
        seguimiento.RecordTypeId = idPlan;
        seguimiento.Name = 'Seguimiento plan 2';
        seguimiento.Tipo__c = SST_Constantes.TIPO_PLAN_ANUAL_TRABAJO;
        seguimiento.Fecha_inicial__c = system.today();
        seguimiento.Fecha_final__c = system.today();
        seguimiento.Objetivo__c = 'test plan';
        seguimiento.Estado__c = 'ACTIVO';
        seguimiento.Empresa__c = String.valueOf(cuenta.SST_nit__c);
        Insert seguimiento;
        
        SST_Seguimiento__c seguimientoPlan = new SST_Seguimiento__c();
        seguimientoPlan.RecordTypeId = idPlan;
        seguimientoPlan.Name = 'Seguimiento plan';
        seguimientoPlan.Tipo__c = SST_Constantes.TIPO_PLAN_ANUAL_TRABAJO;
        seguimientoPlan.Fecha_inicial__c = system.today();
        seguimientoPlan.Fecha_final__c = system.today();
        seguimientoPlan.Objetivo__c = 'test plan';
        seguimientoPlan.Estado__c = 'ACTIVO';
        Insert seguimientoPlan;
        
        SST_Indicador_Seguimiento__c asociacion = new SST_Indicador_Seguimiento__c();
        asociacion.Indicador__c = indicador.id;
        asociacion.Seguimiento__c = seguimientoPlan.id;
        insert asociacion;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(indicador);
        SST_IndicadorSeguimientoCC controlador = new SST_IndicadorSeguimientoCC(sc);
        controlador.selectedValues.add(controlador.unselectedValues.get(0));
        controlador.unselectedValues.add(controlador.selectedValues.get(0));
        controlador.selectedValues.remove(0);
        
        controlador.regresar();
        controlador.guardar();
        System.assert(('Se han actualizado los indicadores para el seguimiento en forma exitosa')==controlador.mensaje||('Permisos insuficientes para eliminar o registrar asociaciones de seguimientos con Indicadores')==controlador.mensaje);

    }

}