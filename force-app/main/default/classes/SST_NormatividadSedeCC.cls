/*Clase controlador encargada de asociar sedes a un seguimiento previamente seleccionado
* @author Marcela Taborda
* @date 05/02/2019
* @version 2.0
*/
public with sharing class SST_NormatividadSedeCC {
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    /*cargo seleccionado para asociar la formación*/
    public SST_Normatividad__c normaSeleccionada {get;set;}
    
    /*Listas para el manejo de Responsabilidades*/
    public List<SelectOption> selectedValues {get;set;}
    public List<SelectOption> unSelectedValues {get;set;}
    Map<id,DTORegistro> leftValues = new Map<id,DTORegistro>();
    Map<id,DTORegistro> rightValues = new Map<id,DTORegistro>();
    
    /*Variable para almacenar la url de detalle del cargo donde se retornará luego de asociar formaciones*/
    public String urlNorma {get;set;}
    
    /*Variable para mostrar el mensaje de éxito o error en el modal*/
    public String mensaje {get;set;}
    
    /*Variable para almacenar la acción del botón principal en el modal de advertencia*/
    public String accion {get;set;}
    
    /*Variable para mostrar el nombre de la empresa de la normatividad seleccionada*/
    public String nombreEmpresa {get;set;}
    
    /*Método constructor de los seguimientos y sedes*/    
    public SST_NormatividadSedeCC(ApexPages.StandardController stdController){
        try{
            mensajesPaginaPrincipal = new  List<SST_MensajesPagina>();
            accion = '';
            mensaje = '';
            selectedValues = new List<SelectOption>();
            unSelectedValues = new List<SelectOption>();
            List<ID> idExistentes = new List<ID> ();
            List<String> listaUnselect = new List<String>();
            List<String> listaSelect = new List<String>();
            normaSeleccionada= (SST_Normatividad__c)stdController.getRecord();
            normaSeleccionada = [SELECT id, name, empresa__c FROM SST_Normatividad__c where id = :normaSeleccionada.Id];
            urlNorma =  SST_Constantes.retornarUrl();
            if(urlNorma<>null && urlNorma.endsWith('sfdcpage/')){
                urlNorma = urlNorma.removeEnd('sfdcpage/');    
            }
            urlNorma =  urlNorma+SST_Constantes.PAGINA_DETALLE_NORMATIVIDAD+'/'+normaSeleccionada.Id;
            
            /*se consultan las sedes que ya estan asociadas a la normatividad seleccionada*/
            for(SST_Normatividad_Sede__c normaSedes :[SELECT id,name,normatividad__r.name,normatividad__c,Sede__c, Sede__r.name FROM SST_Normatividad_Sede__c WHERE normatividad__c=:normaSeleccionada.id order by sede__r.name]){ 
                DTORegistro temp = new DTORegistro();
                temp.nombre = normaSedes.Sede__r.name;
                temp.id = normaSedes.id;
                rightValues.put(normaSedes.Sede__c,temp);
                idExistentes.add(normaSedes.Sede__c);   
                listaSelect.add(temp.nombre+'//'+normaSedes.Sede__c);
            }
            
            String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
            
            /*Se consulta el label de la empresa que tiene la norma seleccionada*/
            Schema.DescribeFieldResult campo = SST_Normatividad__c.Empresa__c.getDescribe();
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            nombreEmpresa = '';
            for(Schema.PicklistEntry pickItem : picklist){
                if(pickItem.getValue() == normaSeleccionada.empresa__c){
                    nombreEmpresa = pickItem.getLabel();
                    break;
                }
            }
            /*se consultan las sedes que no estan asociadas a la normatividad seleccionada*/
            for(SST_Sede__c sede :[SELECT id,name,estado__c FROM SST_Sede__c WHERE id NOT IN :idExistentes and estado__c =: SST_Constantes.ACTIVO AND empresa__c = : normaSeleccionada.empresa__c ORDER BY name]){
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
            
            /*Se llena el select list con las sedes asociadas a la norma*/
            for(String temp: listaUnselect){
                String[] t = temp.split('//');
                unselectedValues.add(new SelectOption(t[1],t[0]));
            }
            
        } catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error construyendo el objeto, por favor contacte al administrador'));
            System.debug('Error en la línea:'+e.getLineNumber()+' - '+e.getMessage());
        }
        
    }
    
    
    /*Método que se encarga de regresar a la pagina anterior*/
    public PageReference regresar(){
        if(!accion.equals('Cancelar')){
            PageReference detalleNorma = new pageReference(urlNorma);
            return detalleNorma;   
        } else {
            return null;
        }
    }
    
    /*Método encargado de guardar las sedes elegidas por el usuario para una normatividad previamente seleccionada*/
    public void guardar(){ 
        accion = '';
        mensajesPaginaPrincipal.clear();
        List<SST_Normatividad_Sede__c> registrosGuardar = new List<SST_Normatividad_Sede__c>();
        List<SST_Normatividad_Sede__c> registrosEliminar = new List<SST_Normatividad_Sede__c>();
        
        /*Se recorre la lista con las sedes seleccionadas, para guardar los nuevos registros*/
        for(SelectOption temp : SelectedValues){
            if(rightValues.get(temp.getValue()) == null){ 
                SST_Normatividad_Sede__c normaSede = new SST_Normatividad_Sede__c();
                normaSede.normatividad__c = normaSeleccionada.id;
                normaSede.Sede__c = temp.getValue();
                registrosGuardar.add(normaSede);
            }
        }
        
        /*Se recorre la lista con las sedes sin seleccionar, para eliminar los registros removidos*/
        for(SelectOption temp : unSelectedValues){
            if(rightValues.get(temp.getValue()) <> null){
                SST_Normatividad_Sede__c normaSede = new SST_Normatividad_Sede__c();
                normaSede.id = rightValues.get(temp.getValue()).id;
                registrosEliminar.add(normaSede);
            }
        } 
        try{
            if (Schema.sObjectType.SST_Normatividad_Sede__c.fields.normatividad__c.isCreateable()&&
                Schema.sObjectType.SST_Normatividad_Sede__c.fields.Sede__c.isCreateable()&&
                Schema.sObjectType.SST_Normatividad_Sede__c.fields.normatividad__c.isUpdateable()&&
                Schema.sObjectType.SST_Normatividad_Sede__c.fields.Sede__c.isUpdateable()&&
                SST_Normatividad_Sede__c.sObjectType.getDescribe().isDeletable()){
                    if(registrosEliminar.size()>0){
                        delete(registrosEliminar);   
                    }
                    
                    if(registrosGuardar.size()>0){
                        Database.UpsertResult [] results = Database.upsert(registrosGuardar, true);
                    }
                    mensaje = 'Se han actualizado las sedes para la normatividad en forma exitosa';
                    accion = 'Aceptar';
                }else{
                    mensaje = 'Permisos insuficientes para eliminar o registrar asociaciones de sedes con Normatividades';
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