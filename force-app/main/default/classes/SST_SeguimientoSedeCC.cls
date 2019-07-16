/*Clase controlador encargada de asociar sedes a un seguimiento previamente seleccionado
* @Marcela Taborda
* @date 27/08/2018
* @version 1.0
*
* @author Marcela Taborda
* @date 31/01/2019
* @version 2.0
*/
public with sharing class SST_SeguimientoSedeCC {
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    /*cargo seleccionado para asociar la formación*/
    public SST_Seguimiento__c seguimientoSeleccionado {get;set;}
    
    /*Listas para el manejo de Responsabilidades*/
    public List<SelectOption> selectedValues {get;set;}
    public List<SelectOption> unSelectedValues {get;set;}
    Map<id,DTORegistro> leftValues = new Map<id,DTORegistro>();
    Map<id,DTORegistro> rightValues = new Map<id,DTORegistro>();
    
    /*Variable para mostrar el recordType Name del cargo seleccionado*/
    public String tipoSeguimiento {get;set;}
    
    /*Variable para mostrar el nombre de la empresa del Seguimiento seleccionado*/
    public String nombreEmpresa {get;set;}
    
    /*Variable para almacenar la url de detalle del cargo donde se retornará luego de asociar formaciones*/
    public String urlSeguimiento {get;set;}
    
    /*Variable para mostrar el mensaje de éxito o error en el modal*/
    public String mensaje {get;set;}
    
    /*Variable para almacenar la acción del botón principal en el modal de advertencia*/
    public String accion {get;set;}
    
    /*Variable para mostrar u ocultar las listas en página cuando el seguimiento está activo o inactivo*/
    public Boolean activo {get;set;}
    
    /*Método constructor de los seguimientos y sedes*/    
    public SST_SeguimientoSedeCC(ApexPages.StandardController stdController){
        try{
            mensajesPaginaPrincipal = new  List<SST_MensajesPagina>();
            accion = '';
            mensaje = '';
            activo = true;
            selectedValues = new List<SelectOption>();
            unSelectedValues = new List<SelectOption>();
            List<ID> idExistentes = new List<ID> ();
            seguimientoSeleccionado= (SST_Seguimiento__c)stdController.getRecord();
            
            seguimientoSeleccionado = [SELECT RecordTypeId, Name, estado__c, empresa__c, id FROM SST_Seguimiento__c where id = :seguimientoSeleccionado.Id];
            tipoSeguimiento = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosById().get(seguimientoSeleccionado.RecordTypeId).getName();     
            
            urlSeguimiento =  SST_Constantes.retornarUrl();
            if(urlSeguimiento<>null && urlSeguimiento.endsWith('sfdcpage/')){
                urlSeguimiento = urlSeguimiento.removeEnd('sfdcpage/');    
            }
            urlSeguimiento =  urlSeguimiento+SST_Constantes.PAGINA_DETALLE_seguimiento+'/'+seguimientoSeleccionado.Id;
            
            /*Si el cargo seleccionado está inactivo, se muestra mensaje en la página y no se permite asociar o desasociar EPP*/
            if(seguimientoSeleccionado.estado__c.equals(SST_Constantes.INACTIVO)){
                activo = false;
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El seguimiento seleccionado se encuentra inactivo.  Sólo puede asociar sedes a seguimientos activos.'));
            } else {
                List<String> listaUnselect = new List<String>();
                List<String> listaSelect = new List<String>();
                /*se consultan las formaciones que ya estan asociadas al cargo seleccionado*/
                for(SST_Seguimiento_Sede__c seguimientoSede :[SELECT id,name,seguimiento__r.name,seguimiento__c,seguimiento__r.recordType.Name, Sede__c, Sede__r.name FROM SST_Seguimiento_Sede__c WHERE seguimiento__c=:seguimientoSeleccionado.id]){ 
                    DTORegistro temp = new DTORegistro();
                    temp.nombre = seguimientoSede.Sede__r.name;
                    temp.id = seguimientoSede.id;
                    rightValues.put(seguimientoSede.Sede__c,temp);
                    idExistentes.add(seguimientoSede.Sede__c);   
                    listaSelect.add(temp.nombre+'//'+seguimientoSede.Sede__c);
                }
                /*se consultan las formaciones que no estan asociadas al cargo existentes*/
                String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
                
                /*Se consulta el label de la empresa que tiene el seguimiento seleccionado*/
                Schema.DescribeFieldResult campo = SST_Seguimiento__c.Empresa__c.getDescribe();
                List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
                nombreEmpresa = null;
                for(Schema.PicklistEntry pickItem : picklist){
                    if(pickItem.getValue() == seguimientoSeleccionado.empresa__c){
                        nombreEmpresa = pickItem.getLabel();
                        break;
                    }
                }
                
                for(SST_Sede__c sede :[SELECT id,name,estado__c FROM SST_Sede__c WHERE id NOT IN :idExistentes and estado__c =: SST_Constantes.ACTIVO AND empresa__c = :seguimientoSeleccionado.empresa__c ORDER BY name]){ 
                    DTORegistro temp = new DTORegistro();
                    temp.nombre = sede.name;
                    temp.id = null;
                    leftValues.put(sede.id,temp);
                    listaUnselect.add(temp.nombre+'//'+sede.id);
                }
                listaSelect.sort();
                listaUnselect.sort();
                /*Se llena el select list con las sedes disponibles para asociar*/
                for(String temp: listaSelect){
                    String[] t = temp.split('//');
                    selectedValues.add(new SelectOption(t[1],t[0]));
                }
                /*Se llena el select list con las sedes asociadas al cargo*/
                for(String temp: listaUnselect){
                    String[] t = temp.split('//');
                    unselectedValues.add(new SelectOption(t[1],t[0]));
                }
            }
            
        } catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error construyendo el objeto, por favor contacte al administrador'));
            System.debug('Error en la línea:'+e.getLineNumber()+' - '+e.getMessage());
        }
        
    }
    
    /*Método que se encarga de regresar a la pagina anterior*/
    public PageReference regresar(){
        if(!accion.equals('Cancelar')){
            PageReference detalleSeguimiento = new pageReference(urlSeguimiento);
            return detalleSeguimiento;   
        } else {
            return null;
        }
    }
    
    /*Método encargado de guardar las sedes elegidas por el usuario para un seguimiento previamente seleccionado*/
    public void guardar(){ 
        accion = '';
        mensajesPaginaPrincipal.clear();
        Map<id,DTORegistro> registros = new Map<id,DTORegistro>();
        registros.putAll(rightValues);
        List<id> idGuardar = new List<Id>();
        List<SST_Seguimiento_Sede__c> registrosGuardar = new List<SST_Seguimiento_Sede__c>();
        List<SST_Seguimiento_Sede__c> registrosEliminar = new List<SST_Seguimiento_Sede__c>();
        
        /*Se recorre la lista con los EPP seleccionados, para guardar los nuevos registros*/
        for(SelectOption temp : SelectedValues){
            if(rightValues.get(temp.getValue()) == null){ 
                SST_Seguimiento_Sede__c seguimientoSede = new SST_Seguimiento_Sede__c();
                seguimientoSede.seguimiento__c = seguimientoSeleccionado.id;
                seguimientoSede.Sede__c = temp.getValue();
                registrosGuardar.add(seguimientoSede);
            }
        }
        
        /*Se recorre la lista con los EPP sin seleccionar, para eliminar los registros removidos*/
        for(SelectOption temp : unSelectedValues){
            if(rightValues.get(temp.getValue()) <> null){
                SST_Seguimiento_Sede__c seguimientoSede = new SST_Seguimiento_Sede__c();
                seguimientoSede.id = rightValues.get(temp.getValue()).id;
                registrosEliminar.add(seguimientoSede);
            }
        } 
        try{
            if (Schema.sObjectType.SST_Seguimiento_Sede__c.fields.seguimiento__c.isCreateable()&&
                Schema.sObjectType.SST_Seguimiento_Sede__c.fields.Sede__c.isCreateable()&&
                Schema.sObjectType.SST_Seguimiento_Sede__c.fields.seguimiento__c.isUpdateable()&&
                Schema.sObjectType.SST_Seguimiento_Sede__c.fields.Sede__c.isUpdateable()&&
                SST_Seguimiento_Sede__c.sObjectType.getDescribe().isDeletable()){
                    if(registrosEliminar.size()>0){
                        delete(registrosEliminar);   
                    }
                    
                    if(registrosGuardar.size()>0){
                        Database.UpsertResult [] results = Database.upsert(registrosGuardar, true);
                    }
                    mensaje = 'Se han actualizado las sedes para el seguimiento en forma exitosa';
                    accion = 'Aceptar';
                }else{
                    mensaje = 'Permisos insuficientes para eliminar o registrar asociaciones de sedes con Seguimientos';
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
    }
}