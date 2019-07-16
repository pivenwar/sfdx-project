/*Clase controlador encargada de asociar seguimientos a un indicador previamente seleccionado
* @Yanebi Tamayo
* @date 19/11/2018
*/
public with sharing class SST_IndicadorSeguimientoCC {
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
     /*indicador seleccionado para asociar el seguimiento*/
    public SST_Indicador__c indicadorSeleccionado {get;set;}
    
    /*Listas para el manejo de los Seguimientos*/
    public List<SelectOption> selectedValues {get;set;}
    public List<SelectOption> unSelectedValues {get;set;}
    Map<id,DTORegistro> leftValues = new Map<id,DTORegistro>();
    Map<id,DTORegistro> rightValues = new Map<id,DTORegistro>();
    
    /*Variable para almacenar la url de detalle del indicador donde se retornará luego de asociar formaciones*/
    public String urlIndicador {get;set;}
    
    /*Variable para mostrar el mensaje de éxito o error en el modal*/
    public String mensaje {get;set;}
    
    /*Variable para almacenar la acción del botón principal en el modal de advertencia*/
    public String accion {get;set;}
    
    /*Variable para mostrar el nombre de la empresa del indicador seleccionado*/
    public String nombreEmpresa {get;set;}
    
    /*Método constructor*/    
    public SST_IndicadorSeguimientoCC(ApexPages.StandardController stdController){
        try{
          mensajesPaginaPrincipal = new  List<SST_MensajesPagina>();
            accion = '';
            mensaje = '';
            selectedValues = new List<SelectOption>();
            unSelectedValues = new List<SelectOption>();
            List<ID> idExistentes = new List<ID> ();
            List<String> listaUnselect = new List<String>();
            List<String> listaSelect = new List<String>();
            indicadorSeleccionado= (SST_Indicador__c)stdController.getRecord();
            indicadorSeleccionado = [SELECT Name, id, empresa__c, Nombre_Indicador__c FROM SST_Indicador__c where id = :indicadorSeleccionado.Id];
            urlIndicador =  SST_Constantes.retornarUrl();
			if(urlIndicador<>null && urlIndicador.endsWith('sfdcpage/')){
            	urlIndicador = urlIndicador.removeEnd('sfdcpage/');    
            }
            urlIndicador =  urlIndicador+SST_Constantes.PAGINA_DETALLE_INDICADOR+'/'+indicadorSeleccionado.Id;
			
            /*se consultan los seguimientos que ya estan asociados al seguimiento seleccionado*/
            for(SST_Indicador_Seguimiento__c indicadorSeguimiento :[SELECT id,name,seguimiento__r.name,seguimiento__c,seguimiento__r.recordType.Name, Indicador__c, Indicador__r.name FROM SST_Indicador_Seguimiento__c WHERE Indicador__c=:indicadorSeleccionado.id]){ 
                DTORegistro temp = new DTORegistro();
                temp.nombre = indicadorSeguimiento.seguimiento__r.name;
                temp.id = indicadorSeguimiento.id;
                temp.tipoSeguimiento = indicadorSeguimiento.seguimiento__r.recordType.Name;
                idExistentes.add(indicadorSeguimiento.seguimiento__c);   
                listaSelect.add(temp.nombre+'//'+indicadorSeguimiento.seguimiento__c);
                rightValues.put(indicadorSeguimiento.seguimiento__c,temp);
            }
            
            
            /*Se consulta el label de la empresa que tiene el indicador seleccionado*/
                Schema.DescribeFieldResult campo = SST_Indicador__c.Empresa__c.getDescribe();
                List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
                nombreEmpresa = null;
                for(Schema.PicklistEntry pickItem : picklist){
                    if(pickItem.getValue() == indicadorSeleccionado.empresa__c){
                        nombreEmpresa = pickItem.getLabel();
                        break;
                    }
                }
            
            /*se consultan los seguimientos que no estan asociados al indicador existente*/
            for(SST_Seguimiento__c seguimiento :[SELECT id,name,estado__c, recordType.Name FROM SST_Seguimiento__c WHERE id NOT IN :idExistentes and estado__c =: SST_Constantes.ACTIVO and empresa__c = : indicadorSeleccionado.empresa__c and recordType.name =:SST_Constantes.RECORD_TYPE_PLANES_PROGRAMAS ORDER BY name]){ 
                DTORegistro temp = new DTORegistro();
                temp.nombre = seguimiento.name;
                temp.id = null;
                temp.tipoSeguimiento = seguimiento.recordType.Name;
                leftValues.put(seguimiento.id,temp);
                listaUnselect.add(temp.nombre+'//'+seguimiento.id);
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

        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error construyendo el objeto, por favor contacte al administrador'));
            System.debug('Error en la línea:'+e.getLineNumber()+' - '+e.getMessage());
        }
    }
    
     /*Método que se encarga de regresar a la pagina anterior*/
    public PageReference regresar(){
        if(!accion.equals('Cancelar')){
            PageReference detalleIndicador = new pageReference(urlIndicador);
            return detalleIndicador;   
        } else {
            return null;
        }
    }
     
     /*Método encargado de guardar los seguimientos elegidos por el usuario para un indicador previamente seleccionado*/
    public void guardar(){
        accion = '';
        mensajesPaginaPrincipal.clear();
        List<SST_Indicador_Seguimiento__c> registrosGuardar =  new List<SST_Indicador_Seguimiento__c>();
        List<SST_Indicador_Seguimiento__c> registrosEliminar =  new List<SST_Indicador_Seguimiento__c>();
        system.debug('SelectedValues: '+SelectedValues);
        system.debug('unSelectedValues: '+unSelectedValues);
        /*Se recorre la lista con las sedes seleccionadas, para guardar los nuevos registros*/
        for(SelectOption temp : SelectedValues){
            if(rightValues.get(temp.getValue()) == null){ 
                SST_Indicador_Seguimiento__c indicadorSeguimiento = new SST_Indicador_Seguimiento__c();
                indicadorSeguimiento.indicador__c = indicadorSeleccionado.id;
                indicadorSeguimiento.seguimiento__c = temp.getValue();
                registrosGuardar.add(indicadorSeguimiento);
            }
        }

        /*Se recorre la lista con las sedes sin seleccionar, para eliminar los registros removidos*/
        for(SelectOption temp : unSelectedValues){
            if(rightValues.get(temp.getValue()) <> null){
                SST_Indicador_Seguimiento__c indicadorSeguimiento = new SST_Indicador_Seguimiento__c();
                indicadorSeguimiento.id = rightValues.get(temp.getValue()).id;
                registrosEliminar.add(indicadorSeguimiento);
            }
        } 
        

        try{
            if (Schema.sObjectType.SST_Indicador_Seguimiento__c.fields.seguimiento__c.isCreateable()&&
                Schema.sObjectType.SST_Indicador_Seguimiento__c.fields.indicador__c.isCreateable()&&
                Schema.sObjectType.SST_Indicador_Seguimiento__c.fields.seguimiento__c.isUpdateable()&&
                Schema.sObjectType.SST_Indicador_Seguimiento__c.fields.indicador__c.isUpdateable()&&
                SST_Indicador_Seguimiento__c.sObjectType.getDescribe().isDeletable()){
                    if(registrosEliminar.size()>0){
                        delete(registrosEliminar);   
                    }
                    if(registrosGuardar.size()>0){
                        Database.UpsertResult [] results = Database.upsert(registrosGuardar, true);
                    }
                    mensaje = 'Se han actualizado los indicadores para el seguimiento en forma exitosa';
                    accion = 'Aceptar';  
                }else{
                     mensaje = 'Permisos insuficientes para eliminar o registrar asociaciones de seguimientos con Indicadores';
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
        public String tipoSeguimiento {get;set;}
    }
}