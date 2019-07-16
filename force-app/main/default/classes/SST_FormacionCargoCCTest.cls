/**
* Clase test que da cubrimiento a SST_FormacionCargoCC
* @date 24/08/2018
*/
@isTest
public class SST_FormacionCargoCCTest {
    
    public static testMethod void SST_FormacionCargoCCTest(){
        
        
        SST_Formacion__c formacionCompetencia = new SST_Formacion__c();
        formacionCompetencia.Competencias__c ='COMPORTAMENTAL';
        formacionCompetencia.Nombre__c='Competencia prueba';
        formacionCompetencia.RecordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Competencias').getRecordTypeId();
        insert(formacionCompetencia);
        
        SST_Formacion__c formacionCompetencia2 = new SST_Formacion__c();
        formacionCompetencia2.Competencias__c ='COMPORTAMENTAL';
        formacionCompetencia2.Nombre__c='Competencia prueba 2';
        formacionCompetencia2.RecordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Competencias').getRecordTypeId();
        insert(formacionCompetencia2);
        
        SST_Formacion__c formacionEntrenamiento = new SST_Formacion__c();
        formacionEntrenamiento.Nombre__c='Entrenamiento prueba';
        formacionEntrenamiento.RecordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Entrenamientos').getRecordTypeId();
        insert(formacionEntrenamiento);
        
        SST_Formacion__c formacionEntrenamiento2 = new SST_Formacion__c();
        formacionEntrenamiento2.Nombre__c='Entrenamiento prueba2';
        formacionEntrenamiento2.RecordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Entrenamientos').getRecordTypeId();
        insert(formacionEntrenamiento2);
        
        SST_Formacion__c formacionResponsabilidad = new SST_Formacion__c();
        formacionResponsabilidad.Nombre__c='Responsabilidad prueba';
        formacionResponsabilidad.Tipo_Responsabilidad__c = 'SST';
        formacionResponsabilidad.tipo_cargo__c = 'CARGO COMITÉ';
        formacionResponsabilidad.RecordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();
        insert(formacionResponsabilidad);
        
        SST_Formacion__c formacionResponsabilidad2 = new SST_Formacion__c();
        formacionResponsabilidad2.Nombre__c='Responsabilidad prueba2';
        formacionResponsabilidad2.Tipo_Responsabilidad__c = 'SST';
        formacionResponsabilidad2.tipo_cargo__c = 'CARGO COMITÉ';
        formacionResponsabilidad2.RecordTypeId = Schema.SObjectType.SST_Formacion__c.getRecordTypeInfosByName().get('Responsabilidades cargos').getRecordTypeId();
        insert(formacionResponsabilidad2);
        

        
        SST_Cargo__c cargoFuncionario = new SST_Cargo__c();
        cargoFuncionario.recordTypeId = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosByName().get('Cargo Comité').getRecordTypeId();
        cargoFuncionario.name = 'Cargo prueba';
        cargoFuncionario.Estado__c = SST_Constantes.ACTIVO;
        insert cargoFuncionario;
        
        SST_Formacion_cargo__c formacionCargo = new SST_Formacion_cargo__c();
        formacionCargo.Cargo__c =cargoFuncionario.id;
        formacionCargo.Formacion__c = formacionCompetencia.id;
        insert(formacionCargo);
        
        SST_Formacion_cargo__c formacionCargo2 = new SST_Formacion_cargo__c();
        formacionCargo2.Cargo__c =cargoFuncionario.id;
        formacionCargo2.Formacion__c = formacionEntrenamiento.id;
        insert(formacionCargo2);
        
        SST_Formacion_cargo__c formacionCargo3 = new SST_Formacion_cargo__c();
        formacionCargo3.Cargo__c =cargoFuncionario.id;
        formacionCargo3.Formacion__c = formacionResponsabilidad.id;
        insert(formacionCargo3);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cargoFuncionario);
        SST_FormacionCargoCC controlador = new SST_FormacionCargoCC(sc);

        controlador.SelectedCValues.add(controlador.unselectedCValues.get(0));
        controlador.SelectedEValues.add(controlador.unselectedEValues.get(0));
        controlador.SelectedRValues.add(controlador.unselectedRValues.get(0));
        
        controlador.unSelectedCValues.add(controlador.selectedCValues.get(0));
        controlador.unSelectedEValues.add(controlador.selectedEValues.get(0));
        controlador.unSelectedRValues.add(controlador.selectedRValues.get(0));
        
        controlador.selectedCValues.remove(0);
        controlador.selectedEValues.remove(0);
        controlador.selectedRValues.remove(0);
        controlador.guardar();
        System.assert(('Las formaciones para el cargo se han atualizado exitosamente.')==controlador.mensaje || ('Permisos insuficientes para eliminar o registrar asociaciones de formaciones con cargos')==controlador.mensaje);

        controlador.urlCargo = 'https://test.salesforce.com/';
        controlador.regresar();
         
    }
    
}