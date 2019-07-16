@isTest
public class SST_CargoEppCCTest {
    public static testMethod void SST_CargoEppCCTest(){
        
        ID idPlan = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Funcionario').getRecordTypeId();     
        
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;

        Account cuenta = new Account();
        cuenta.name = 'empresa';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_periodo_notificacion__c = 1;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.SST_Estado__c = SST_Constantes.ACTIVO;
        insert cuenta;
        
        SST_Cargo__c cargo = New SST_Cargo__c();
        cargo.Empresa__c = empresa;
        cargo.RecordTypeId = idPlan;
        cargo.Name = 'Cargo';
        cargo.Estado__c = SST_Constantes.ACTIVO;
        insert cargo;
        
        SST_Elemento_Proteccion_Personal__c epp = New SST_Elemento_Proteccion_Personal__c();
        epp.Empresa__c = empresa;
        epp.Codigo__c = '001';
        epp.Name = 'Guantes';
        epp.Vida_util__c = 30;
        epp.Estado__c = SST_Constantes.ACTIVO;
        insert epp;
        
        SST_Elemento_Proteccion_Personal__c epp2 = New SST_Elemento_Proteccion_Personal__c();
        epp2.Empresa__c = empresa;
        epp2.Codigo__c = '002';
        epp2.Name = 'Casco';
        epp2.Vida_util__c = 30;
        epp2.Estado__c = SST_Constantes.ACTIVO;
        insert epp2;
        
        SST_Cargo_EPP__c asociacion = New SST_Cargo_EPP__c();
        asociacion.Cargo__c = cargo.id;
        asociacion.Elemento_Proteccion_Personal__c = epp.id;
        insert asociacion;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cargo);
	    SST_CargoEppCC controlador = new SST_CargoEppCC(sc);
		controlador.selectedValues.add(controlador.unSelectedValues.get(0));
		controlador.unselectedValues.add(controlador.selectedValues.get(0));
        controlador.selectedValues.remove(0);
        controlador.guardar();
        System.assert('Se han actualizado los Elementos de Protección Personal para el cargo en forma exitosa'==controlador.mensaje ||
                     controlador.mensaje =='Permisos insuficientes para eliminar o registrar asociaciones de cargos con Elementos de Protección Personal');

        controlador.regresar();
       
    }

}