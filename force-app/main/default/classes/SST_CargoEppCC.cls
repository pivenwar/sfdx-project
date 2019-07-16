/*Clase controlador encargada de asociar Elementos de Protección Personal a un cargo previamente seleccionado
* @Yanebi Tamayo
* @date 17/01/2019
* @version 1.0
*
* @author Marcela Taborda
* @date 31/01/2019
* @version 2.0
*/
public with sharing class SST_CargoEppCC {
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    /*cargo seleccionado para asociar el epp*/
    public SST_Cargo__c cargoSeleccionado {get;set;}
    
    /*Atributos para el manejo de los EPP*/
    public List<SelectOption> selectedValues {get;set;}
    public List<SelectOption> unSelectedValues {get;set;}
    Map<id,DTORegistro> leftValues = new Map<id,DTORegistro>();
    Map<id,DTORegistro> rightValues = new Map<id,DTORegistro>();
    
    /*Variable para mostrar el recordType Name del cargo seleccionado*/
    public String tipoCargo {get;set;}
    
    /*Variable para mostrar el nombre de la empresa del cargo seleccionado*/
    public String nombreEmpresa {get;set;}
    
    /*Variable para almacenar la url de detalle del cargo donde se retornará luego de asociar EPP*/
    public String urlCargo {get;set;}
    
    /*Variable para mostrar el mensaje de éxito o error en el modal*/
    public String mensaje {get;set;}
    
    /*Variable para almacenar la acción del botón principal en el modal de advertencia*/
    public String accion {get;set;}
    
    /*Variable para mostrar u ocultar las listas en página cuando el cargo está activo o inactivo*/
    public Boolean activo {get;set;}
    
    /*Método constructor de los Cargo y EPP*/
    public SST_CargoEppCC(ApexPages.StandardController stdController){
        try{
            mensajesPaginaPrincipal = new  List<SST_MensajesPagina>();
            accion = '';
            mensaje = '';
            activo = true;
            selectedValues = new List<SelectOption>();
            unSelectedValues = new List<SelectOption>();
            List<ID> idExistentes = new List<ID> ();
            cargoSeleccionado= (SST_Cargo__c)stdController.getRecord();
            
            cargoSeleccionado = [SELECT RecordTypeId, Name, id, estado__c, empresa__c FROM SST_Cargo__c where id = :cargoSeleccionado.Id];
            tipoCargo = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosById().get(cargoSeleccionado.RecordTypeId).getName();     
            
            urlCargo =  SST_Constantes.retornarUrl();
            if(urlCargo<>null && urlCargo.endsWith('sfdcpage/')){
                urlCargo = urlCargo.removeEnd('sfdcpage/');    
            }
            urlCargo =  urlCargo+SST_Constantes.PAGINA_DETALLE_CARGO+'/'+cargoSeleccionado.Id;
            
            /*Si el cargo seleccionado está inactivo, se muestra mensaje en la página y no se permite asociar o desasociar EPP*/
            if(cargoSeleccionado.estado__c.equals(SST_Constantes.INACTIVO)){
                activo = false;
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El cargo seleccionado se encuentra inactivo.  Sólo puede asociar Elementos de Protección Personal a cargos activos.'));
            } else {
                List<String> listaUnselect = new List<String>();
                List<String> listaSelect = new List<String>();
                
                /*se consultan los EPP que ya estan asociados al cargo seleccionado*/
                for(SST_Cargo_EPP__c cargoEpp :[SELECT id,name,Cargo__r.name,Cargo__c,Cargo__r.recordType.Name, Elemento_Proteccion_Personal__c, Elemento_Proteccion_Personal__r.name FROM SST_Cargo_EPP__c WHERE Cargo__c=:cargoSeleccionado.id]){ 
                    DTORegistro temp = new DTORegistro();
                    temp.nombre = cargoEpp.Elemento_Proteccion_Personal__r.name;
                    temp.id = cargoEpp.id;
                    rightValues.put(cargoEpp.Elemento_Proteccion_Personal__c,temp);
                    listaSelect.add(temp.nombre+'//'+cargoEpp.Elemento_Proteccion_Personal__c);
                    idExistentes.add(cargoEpp.Elemento_Proteccion_Personal__c);   
                }
                /*se consultan los EPP que no estan asociados al cargo existentes*/
                //String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
                
                /*Se consulta el label de la empresa que tiene el cargo seleccionado*/
                Schema.DescribeFieldResult campo = SST_Cargo__c.Empresa__c.getDescribe();
                List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
                nombreEmpresa = null;
                for(Schema.PicklistEntry pickItem : picklist){
                    if(pickItem.getValue() == cargoSeleccionado.empresa__c){
                        nombreEmpresa = pickItem.getLabel();
                        break;
                    }
                }
                for(SST_Elemento_Proteccion_Personal__c epp :[SELECT id,name,estado__c FROM SST_Elemento_Proteccion_Personal__c WHERE id NOT IN :idExistentes and estado__c =: SST_Constantes.ACTIVO AND empresa__c =: cargoSeleccionado.empresa__c ORDER BY name]){
                    DTORegistro temp = new DTORegistro();
                    temp.nombre = epp.name;
                    temp.id = null;
                    leftValues.put(epp.id,temp);
                    listaUnselect.add(temp.nombre+'//'+epp.id);
                }
                listaSelect.sort();
                listaUnselect.sort();
                
                /*Se llena el select list con los EPP disponibles para asociar*/
                for(String temp: listaSelect){
                    String[] t = temp.split('//');
                    selectedValues.add(new SelectOption(t[1],t[0]));
                }
                /*Se llena el select list con los EPP asociados al cargo*/
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
            PageReference detalleCargo = new pageReference(urlCargo);
            return detalleCargo;   
        } else {
            return null;
        }
    }
    
    /*Método encargado de guardar los EPP elegidos por el usuario para un Cargo previamente seleccionado*/
    public void guardar(){ 
        accion = '';
        mensajesPaginaPrincipal.clear();
        List<SST_Cargo_EPP__c> registrosGuardar = new List<SST_Cargo_EPP__c>();
        List<SST_Cargo_EPP__c> registrosEliminar = new List<SST_Cargo_EPP__c>();
        /*Se recorre la lista con los EPP seleccionados, para guardar los nuevos registros*/
        for(SelectOption temp : SelectedValues){
            if(rightValues.get(temp.getValue()) == null){ 
                SST_Cargo_EPP__c cargoEpp = new SST_Cargo_EPP__c();
                cargoEpp.Cargo__c = cargoSeleccionado.id;
                cargoEpp.Elemento_Proteccion_Personal__c = temp.getValue();
                registrosGuardar.add(cargoEpp);
            }
        }
        
        /*Se recorre la lista con los EPP sin seleccionar, para eliminar los registros removidos*/
        for(SelectOption temp : unSelectedValues){
            if(rightValues.get(temp.getValue()) <> null){
                SST_Cargo_EPP__c cargoEpp = new SST_Cargo_EPP__c();
                cargoEpp.id = rightValues.get(temp.getValue()).id;
                registrosEliminar.add(cargoEpp);
            }
        } 
        try{
            /*se buscan todos los Cargo EPP del cargo seleccionado y que no hayan sido seleccionadas por el usuario, y así eliminarlas*/
            if (Schema.sObjectType.SST_Cargo_EPP__c.fields.Cargo__c.isCreateable()&&
                Schema.sObjectType.SST_Cargo_EPP__c.fields.Elemento_Proteccion_Personal__c.isCreateable()&&
                Schema.sObjectType.SST_Cargo_EPP__c.fields.Cargo__c.isUpdateable()&&
                Schema.sObjectType.SST_Cargo_EPP__c.fields.Elemento_Proteccion_Personal__c.isUpdateable()&&
                SST_Cargo_EPP__c.sObjectType.getDescribe().isDeletable()){
                if(registrosEliminar.size()>0){
                    delete(registrosEliminar); 
                }
                if(registrosGuardar.size()>0){
                    upsert(registrosGuardar);   
                }
                mensaje = 'Se han actualizado los Elementos de Protección Personal para el cargo en forma exitosa';
                accion = 'Aceptar';
            }else{
                mensaje = 'Permisos insuficientes para eliminar o registrar asociaciones de cargos con Elementos de Protección Personal';
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