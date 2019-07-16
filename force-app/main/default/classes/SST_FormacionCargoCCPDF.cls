/*
* @autor: Yanebi Tamayo
* @fecha: 05/06/2019
* @version: 1.0
*/


//Clase para consultar los datos que serán exportados en el reporte de las Responsabilidades asociadas al cargo.

public with sharing class SST_FormacionCargoCCPDF {
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    //Atributo para obtener la fecha y hora para el encabezado del reporte
    Public String fechaReporte {get;set;}
    
    //Atributos para obtener el nombre y nit de la empresa para el encabezado del reporte
    Public String empresa {get;set;}
    Public String nit {get;set;}

    /*cargo seleccionado para asociar la formación*/
    public SST_Cargo__c cargoSeleccionado {get;set;}
    
    /*String para guardar el nombre de la responsabilidad para el reporte*/
    public List<ListaDTO> Responsabilidad {get;set;}
    
    /*Mapa con el tipo de la responsabilidad*/
    public Map <String,String> mapaTipoResponsabilidad{get; set;}
    
    public SST_FormacionCargoCCPDF(ApexPages.StandardController stdController){
        cargoSeleccionado= (SST_Cargo__c)stdController.getRecord();
        cargoSeleccionado = [SELECT RecordTypeId, Name, id, estado__c, empresa__c FROM SST_Cargo__c where id = :cargoSeleccionado.Id];
        Responsabilidad = new List <ListaDTO>();
        mapaTipoResponsabilidad = new Map <String,String>();
        generarDatosEncabezado();
        consultarInformacion();
    }
    
    //Método para generar los datos para el encabezado del reporte
    public void generarDatosEncabezado(){
        Account cuenta = new Account();
        cuenta = SST_Constantes.consultarDatosEmpresa(SST_Constantes.getEmpresaAutenticada());
        if(cuenta == null){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No hay actualmente configurada una empresa como cuenta principal.  Verifique y complete la configuración de los datos de la empresa para continuar'));            
        } else {
            Datetime fecha = system.now(); 
            fechaReporte = fecha.format(SST_Constantes.FORMATO_FECHA_REPORTE);
            fechaReporte = SST_Constantes.cambiarNombreMes(fechaReporte);
            empresa = cuenta.name;
            nit = String.valueOf(cuenta.sst_nit__c); 
        }
    }
    
    /*Método que consulta la información para el reporte*/
    public void consultarInformacion(){
        
        /*Se consulta el label del picklist tipo responsabilidad del objeto formación*/
        Schema.DescribeFieldResult fieldResult = SST_Formacion__c.Tipo_Responsabilidad__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry tipoResponsabilidadTemp : itemsTemp){
            mapaTipoResponsabilidad.put(tipoResponsabilidadTemp.getValue(),tipoResponsabilidadTemp.getLabel());
        }
        
        /*Se consultan las responsabilidades asociadas al cargo */
        Responsabilidad = new List <ListaDTO>();
        for(SST_Formacion_Cargo__c formacionCargo :[SELECT id,name,Cargo__c, formacion__r.Nombre__c, formacion__r.Tipo_Responsabilidad__c, formacion__c,formacion__r.recordType.Name FROM SST_Formacion_Cargo__c where Cargo__c =: cargoSeleccionado.id ORDER BY formacion__r.Tipo_Responsabilidad__c]){
       
            if(formacionCargo.formacion__r.recordType.Name.contains(SST_Constantes.RECORD_TYPE_RESPONSABILIDADES)){
                ListaDTO listaDTO = new ListaDTO();
                listaDTO.idFormacion= formacionCargo.formacion__c;
                listaDTO.nombre = formacionCargo.formacion__r.Nombre__c;
                listaDTO.idFormacionCargo = formacionCargo.id;
                listaDTO.tipoRegistro = formacionCargo.formacion__r.recordType.Name; 
                listaDTO.tipoResponsabilidad = formacionCargo.formacion__r.Tipo_Responsabilidad__c;
                Responsabilidad.add(listaDTO);
            }
            
        }
        
    }
    
    /*Clase DTO*/
     public class ListaDTO{
        public Id idFormacion{get; set;}
        public String nombre{get; set;}
        public Id idFormacionCargo {get; set;}
        public String tipoRegistro {get;set;}
        public String tipoResponsabilidad {get;set;}
    }

}