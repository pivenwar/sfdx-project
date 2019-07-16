@isTest
public class SST_PeligroSPTriggerTest {
    
     //Método test para el trigger de PeligroSP
    public static testMethod void SST_PeligroSPTriggerTest(){
        Test.StartTest();
        
        SST_Area_trabajo__c area = new SST_Area_trabajo__c();
        area.name = 'Area prueba';
        area.estado__c = 'ACTIVO';
        insert(area);
        
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
        peligroGuardado.Eliminar__c = 'Eliminar';
        peligroGuardado.Sustituir__c = 'Sustituir';
        peligroGuardado.Nivel_Deficiencia__c ='2';
        peligroGuardado.Nivel_Exposicion__c ='1';
        peligroGuardado.Nivel_Consecuencia__c ='25';
        peligroGuardado.Riesgo_Cualitativo_Texto__c = 'Riesgo 1';
        peligroGuardado.Valoracion_Riesgo__c = 'Valoración 1';
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
        System.assert(('2') == peligroGuardado.nivel_Deficiencia__c);

        
        peligroGuardado.Fuente__c = 'F';
        peligroGuardado.medio__c = 'M';
        peligroGuardado.Trabajador__c = 'T';
        peligroGuardado.Metodo__c = 'M';
        peligroGuardado.Riesgo_Cualitativo_Texto__c = 'Riesgo 2';
        peligroGuardado.Valoracion_Riesgo__c = 'Valoración 2';
        update (peligroGuardado);
        
        peligroGuardado.Eliminar__c= 'E';
        peligroGuardado.Sustituir__c = 'S';
        update (peligroGuardado); 
        
        
        
    } 

}