/* Clase controlador encargada de asociar Responsabilidades al peligro de Super Polo
* @Yanebi Tamayo
* 14/12/2018
*/ 
public with sharing class SST_PeligroSPFormacionCC {
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    /*peligro seleccionado para asociar la responsabilidad*/
    public SST_Peligro_SP__c peligroSeleccionado {get;set;}
    
    /*Listas para el manejo de las Responsabilidades*/
    public List<Id> leftSelected{get;set;}
    public List<Id> rightSelected{get;set;}
    Map<id,DTORegistro> leftValues = new Map<id,DTORegistro>();
    Map<id,DTORegistro> rightValues = new Map<id,DTORegistro>();
    
    /*Variable para almacenar la url de detalle del peligro donde se retornará luego de asociar Responsabilidades*/
    public String urlPeligro {get;set;}
    
    /*Variable para mostrar el mensaje de éxito o error en el modal*/
    public String mensaje {get;set;}
    
    /*Variable para almacenar la acción del botón principal en el modal de advertencia*/
    public String accion {get;set;}
    
    /*Método constructor*/    
    public SST_PeligroSPFormacionCC(ApexPages.StandardController stdController){
        try{
            mensajesPaginaPrincipal = new  List<SST_MensajesPagina>();
            accion = '';
            mensaje = '';
            leftSelected = new List<Id>();
            rightSelected = new List<Id>();
            List<ID> idExistentes = new List<ID> ();
            peligroSeleccionado= (SST_Peligro_SP__c)stdController.getRecord();
            peligroSeleccionado = [SELECT Name, id, Peligro__c FROM SST_Peligro_SP__c where id = :peligroSeleccionado.Id];
            urlPeligro =  SST_Constantes.retornarUrl();
            if(urlPeligro<>null && urlPeligro.endsWith('sfdcpage/')){
                urlPeligro = urlPeligro.removeEnd('sfdcpage/');    
            }
            urlPeligro =  urlPeligro+SST_Constantes.PAGINA_DETALLE_PELIGRO_SP+'/'+peligroSeleccionado.Id;
            
            /*se consultan los seguimientos que ya estan asociados al seguimiento seleccionado*/
            for(SST_Peligro_SP_Formacion__c peligroSPFormacion :[SELECT id,name,formacion__r.Nombre__c,formacion__c,formacion__r.recordType.Name, Peligro_SP__c, Peligro_SP__r.name FROM SST_Peligro_SP_Formacion__c WHERE Peligro_SP__c=:peligroSeleccionado.id]){ 
                DTORegistro temp = new DTORegistro();
                temp.nombre = peligroSPFormacion.formacion__r.Nombre__c;
                temp.id = peligroSPFormacion.id;
                temp.tipoFormacion = peligroSPFormacion.formacion__r.recordType.Name;
                if(peligroSPFormacion.formacion__r.recordType.Name.contains(SST_Constantes.RECORD_TYPE_RESPONSABILIDADES)){
                    rightValues.put(peligroSPFormacion.formacion__c,temp);
                }
                idExistentes.add(peligroSPFormacion.formacion__c);   
            }
            
            /*se consultan los seguimientos que no estan asociados al indicador existente*/
            
            for(SST_Formacion__c formacion :[SELECT id,name,recordType.Name, Nombre__c FROM SST_Formacion__c WHERE id NOT IN :idExistentes ORDER BY name]){
                DTORegistro temp = new DTORegistro();
                temp.nombre = formacion.Nombre__c;
                temp.id = null;
                temp.tipoFormacion = formacion.recordType.Name;
                if(formacion.recordType.Name.contains(SST_Constantes.RECORD_TYPE_RESPONSABILIDADES)){
                    leftValues.put(formacion.id,temp);
                }
            }
            
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error construyendo el objeto, por favor contacte al administrador'));
            System.debug('Error en la línea:'+e.getLineNumber()+' - '+e.getMessage());
        }
    }
    
    /*Método que se encarga de regresar a la pagina anterior*/
    public PageReference regresar(){
        if(!accion.equals('Cancelar')){
            PageReference detalleIndicador = new pageReference(urlPeligro);
            return detalleIndicador;   
        } else {
            return null;
        }
    }
    
    /*Método que actualiza la lista cuando se selecciona una responsabilidad*/
    public PageReference selectClick(){
        for(Id id : leftSelected){
            DTORegistro nombreFormacion = leftValues.get(id);
            leftValues.remove(id);
            rightValues.put(id,nombreFormacion);
        }
        return null;
    }
    
    /*Método que actualiza la lista cuando se remueve una Responsabilidad*/
    public PageReference unselectclick(){
        for(Id id : rightSelected){
            DTORegistro nombreFormacion = rightValues.get(id);
            rightValues.remove(id);
            leftValues.put(id,nombreFormacion);
        }
        return null;
    }
    
    /*Método que actualiza la lista a mostrar de las responsabilidades que ya han sido seleccionadas*/
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        for(Id id : rightValues.keySet())
            options1.add(new SelectOption(id,rightValues.get(id).nombre));
        return options1;
    }
    
    /*Método que actualiza la lista a mostrar de los elementos que no han sido seleccionados*/
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        for(Id id: leftValues.keySet())
            options.add(new SelectOption(id,leftValues.get(id).nombre));
        return options;
    }
    
    /*Método encargado de guardar los seguimientos elegidos por el usuario para un indicador previamente seleccionado*/
    public void guardar(){
        try{
            accion = '';
            mensajesPaginaPrincipal.clear();
            if (Schema.sObjectType.SST_Peligro_SP_Formacion__c.fields.Formacion__c.isCreateable()&&
                Schema.sObjectType.SST_Peligro_SP_Formacion__c.fields.Peligro_SP__c.isCreateable()&&
                Schema.sObjectType.SST_Peligro_SP_Formacion__c.fields.Formacion__c.isUpdateable()&&
                Schema.sObjectType.SST_Peligro_SP_Formacion__c.fields.Peligro_SP__c.isUpdateable()&&
                SST_Peligro_SP_Formacion__c.sObjectType.getDescribe().isDeletable()){
                    
                    Map<id,DTORegistro> registros = new Map<id,DTORegistro>();
                    registros.putAll(rightValues);
                    
                    List<SST_Peligro_SP_Formacion__c> registrosGuardar = new List<SST_Peligro_SP_Formacion__c>();
                    List<ID> idPeligrosFormacion = new List<ID>();
                    for(Id id : registros.keySet()){
                        idPeligrosFormacion.add(registros.get(id).id);
                    }
                    
                    List<id> idGuardar = new List<Id>();
                    for(SST_Peligro_SP_Formacion__c peligroSPFormacion : [SELECT id FROM SST_Peligro_SP_Formacion__c WHERE id in :idPeligrosFormacion]){
                        for(Id id : registros.keySet()){
                            if(id == peligroSPFormacion.id){
                                peligroSPFormacion.Peligro_SP__c = peligroSeleccionado.id;
                                peligroSPFormacion.Formacion__c = id;
                                registrosGuardar.add(peligroSPFormacion);
                            } 
                        }
                    }
                    List<SST_Peligro_SP_Formacion__c> registrosEliminar = [SELECT id FROM SST_Peligro_SP_Formacion__c WHERE Peligro_SP__c=:peligroSeleccionado.id AND formacion__c NOT IN :idGuardar];
                    
                    if(registrosEliminar.size()>0){
                        delete(registrosEliminar);   
                    }
                    
                    if(registrosGuardar.size()>0){
                        Database.UpsertResult [] results = Database.upsert(registrosGuardar, true);
                    }
                    mensaje = 'Se han actualizado las formaciones para el peligro en forma exitosa';
                    accion = 'Aceptar';
                }else{
                    mensaje = 'Permisos insuficientes para eliminar o registrar asociaciones de formaciones con peligros';
                    accion = 'Cancelar';  
                }
            
        }catch(Exception e){
            String [] errores = e.getMessage().split(',');
            String error = errores[errores.size()-1];
            mensaje = error.substringBefore(':');
            accion = 'Cancelar';
            System.debug('Error en la línea:'+e.getLineNumber()+' - '+e.getMessage());
        }
        
        
    }
    
    
    public class DTORegistro{
        public String nombre {get;set;}
        public String id {get;set;}
        public String tipoFormacion {get;set;}
    }
    
}