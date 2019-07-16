/*Clase que se encarga de construir la lista de las ubicaciones de las sedes*/
public inherited sharing class SST_SitioMapCC {
    
    @AuraEnabled
    /*Método que construye las ubicaciones de la sede y su punto de encuentro.*/
    public static List<SST_Sede__c> getAllSitios(){
        List <SST_Sede__c> sitios = New List <SST_Sede__c>();
        for(SST_Sede__c sede: [Select id, Name, Telefono__c, email_sede__c, Ubicacion__Latitude__s, Ubicacion__Longitude__s,Ubicacion_Punto_encuentro__Latitude__s,Ubicacion_Punto_encuentro__Longitude__s from SST_Sede__c where (Ubicacion__Latitude__s!= null AND Ubicacion__Longitude__s!=null) OR(Ubicacion_Punto_encuentro__Latitude__s!=null AND Ubicacion_Punto_encuentro__Longitude__s!=null AND estado__c =:SST_Constantes.ACTIVO)]){
            /*Se agrega la ubicación*/
            if(sede.Ubicacion__Latitude__s!=null){
                SST_Sede__c sitio = New SST_Sede__c();
                sitio.Ubicacion__Latitude__s = sede.Ubicacion__Latitude__s;
                sitio.Ubicacion__Longitude__s = sede.Ubicacion__Longitude__s;
                sitio.Name = sede.name;
 				if(sede.Telefono__c!=null){
                	sitio.Telefono__c = sede.Telefono__c;
                }
                if(sede.email_sede__c!=null){
                	sitio.email_sede__c = sede.email_sede__c;
                }
                sitios.add(sitio);
            }
            /*se agrega el punto de encuentro*/
            if(sede.Ubicacion_Punto_encuentro__Latitude__s!=null){
                SST_Sede__c sitio = New SST_Sede__c();
                sitio.Ubicacion__Latitude__s = sede.Ubicacion_Punto_encuentro__Latitude__s;
                sitio.Ubicacion__Longitude__s = sede.Ubicacion_Punto_encuentro__Longitude__s;
                sitio.Name = 'Punto de encuentro '+sede.name;
                if(sede.Telefono__c!=null){
                	sitio.Telefono__c = sede.Telefono__c;
                }
                if(sede.email_sede__c!=null){
                	sitio.email_sede__c = sede.email_sede__c;
                }
                sitios.add(sitio);
            }
        } 
        return sitios;
        
    }
    
}