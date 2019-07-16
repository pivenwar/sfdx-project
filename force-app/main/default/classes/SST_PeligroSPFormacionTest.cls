@isTest
public class SST_PeligroSPFormacionTest {
    
    public static testMethod void SST_PeligroSPFormacionTest(){
        ID idFormacion = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();     
        Date hoy = system.today();

		SST_Area_trabajo__c area = New SST_Area_trabajo__c();
		area.name = 'Área de Trabajo';
        insert area;
        
        SST_Peligro_SP__c peligro = New SST_Peligro_SP__c();
        peligro.Area__c = area.id;
        peligro.peligro__c = 'peligro sp';
        peligro.Fuente_Generadora_Peligro__c = 'fuente generadora de peligro';
        peligro.Efectos_Salud_Propiedad__c = 'Efectos en la salud';
        peligro.Tiempo_Exposicion_Aproximado__c	= 2;
        peligro.Accidentes_Enfermedades_Ocurridas__c = 'Accidentes';
        peligro.Expuesto__c = 'Funcionarios';
        peligro.Rutinaria__c = true;
        peligro.Fuente__c = 'fuente';
        peligro.Medio__c = 'Medio';
        peligro.Trabajador__c = 'Trabajador';
        peligro.Metodo__c = 'Metodo';
        peligro.Nivel_Deficiencia__c = '2';
        peligro.Nivel_Exposicion__c = '2';
        peligro.Nivel_Consecuencia__c = '10';
        insert peligro;
        
        SST_Formacion__c formacion = New SST_Formacion__c();
        formacion.RecordTypeId = idFormacion;
        formacion.Tipo_Cargo__c = 'Cago Funcionario';
        formacion.Tipo_Responsabilidad__c = 'Propias_cargo';
        formacion.Nombre__c = 'Nombre';
        insert formacion;
        
        SST_Formacion__c formacion2 = New SST_Formacion__c();
        formacion2.RecordTypeId = idFormacion;
        formacion2.Tipo_Cargo__c = 'Cago Funcionario';
        formacion2.Tipo_Responsabilidad__c = 'Propias_cargo';
        formacion2.Nombre__c = 'Nombre2';
        insert formacion2;
        
        SST_Peligro_SP_Formacion__c asociacion = New SST_Peligro_SP_Formacion__c();
        asociacion.Peligro_SP__c = peligro.id;
        asociacion.Formacion__c = formacion.id;
        insert asociacion;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(peligro);
        SST_PeligroSPFormacionCC asociacion2 = New SST_PeligroSPFormacionCC(sc);
        
        asociacion2.regresar();
        asociacion2.selectClick();
        asociacion2.unselectclick();
        asociacion2.getSelectedValues();
        asociacion2.getunSelectedValues();
        asociacion2.guardar();
        System.assert(('Se han actualizado las formaciones para el peligro en forma exitosa')==asociacion2.mensaje||('Permisos insuficientes para eliminar o registrar asociaciones de formaciones con peligros')==asociacion2.mensaje);

        asociacion2.guardar();

    }

}