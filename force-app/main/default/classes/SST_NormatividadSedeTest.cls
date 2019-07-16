/**
* Clase test que da cubrimiento a SST_NormatividadSedeTest
* @author: Marcela Taborda
* @date 29/08/2018
*/

@isTest
public class SST_NormatividadSedeTest {
    
    public static testMethod void SST_NormatividadSedeTest(){
        
        SST_Normatividad__c normatividad = New SST_Normatividad__c();
        normatividad.name = 'Normatividad';
        normatividad.Entidad__c = 'E-039';
        normatividad.Tipo__c = 'ACUERDO';
        insert normatividad;
        
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
        
        
        SST_normatividad_sede__c asociacion = new SST_normatividad_sede__c();
        asociacion.sede__c = sede.id;
        asociacion.normatividad__c = normatividad.Id;
        insert asociacion;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(normatividad);
	    SST_NormatividadSedeCC controlador = new SST_NormatividadSedeCC(sc);
        controlador.selectedValues.add(controlador.unselectedValues.get(0));
        controlador.unselectedValues.add(controlador.selectedValues.get(0));
        controlador.selectedValues.remove(0);
        controlador.guardar();
        System.assert(('Se han actualizado las sedes para la normatividad en forma exitosa')==controlador.mensaje||('Permisos insuficientes para eliminar o registrar asociaciones de sedes con Normatividades')==controlador.mensaje);
        controlador.regresar();
        
    }

}