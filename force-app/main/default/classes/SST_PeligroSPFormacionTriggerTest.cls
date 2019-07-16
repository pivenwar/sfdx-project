@isTest
public class SST_PeligroSPFormacionTriggerTest {
    //Método test para el trigger de PeligroSP
    public static testMethod void SST_PeligroSPFormacionTriggerTest(){
        Test.StartTest();
        
        SST_Area_trabajo__c area = new SST_Area_trabajo__c();
        area.name = 'Area prueba';
        area.estado__c = 'ACTIVO';
        insert(area);
        
        ID idResponsabilidadCargo = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();     
        SST_Formacion__c responsabilidadFuncionario1 = new SST_Formacion__c();
        responsabilidadFuncionario1.RecordTypeId = idResponsabilidadCargo;
        responsabilidadFuncionario1.Tipo_Cargo__c = 'CARGO FUNCIONARIO';
        responsabilidadFuncionario1.Nombre__c = 'Responsabilidad';
        responsabilidadFuncionario1.Descripcion__c = 'Esta es una responsabilidad de funcionario de prueba';
        insert responsabilidadFuncionario1;
        
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
        
        SST_Peligro_SP_Formacion__c asociacion = new SST_Peligro_SP_Formacion__c();
        asociacion.Formacion__c = responsabilidadFuncionario1.id;
        asociacion.Peligro_SP__c = peligro.id;
        insert asociacion; 
        
         asociacion.Formacion__c = responsabilidadFuncionario2.id;
        update asociacion;
        System.assert(responsabilidadFuncionario2.id == asociacion.Formacion__c);
    }

}