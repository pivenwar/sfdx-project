/*Clase controladora encargada de asociar responsabilidades, competencias y entrenamientos a un cargo previamente seleccionado
* @author Angélica Toro Murillo
* @date 22/08/2018
* @version 1.0
*
* @author Marcela Taborda
* @date 31/01/2019
* @version 2.0
*/
public with sharing class SST_FormacionCargoCC { 
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    /*cargo seleccionado para asociar la formación*/
    public SST_Cargo__c cargoSeleccionado {get;set;}
    
    /*Atributos para el manejo de Responsabilidades*/
    Map<id,ListaDTO> leftRValues = new Map<id,ListaDTO>();
    Map<id,ListaDTO> rightRValues = new Map<id,ListaDTO>();
    public List<SelectOption> selectedRValues {get;set;}
    public List<SelectOption> unSelectedRValues {get;set;}
    
    /*Atributos para el manejo de Competencias*/
    Map<id,ListaDTO> leftCValues = new Map<id,ListaDTO>();
    Map<id,ListaDTO> rightCValues = new Map<id,ListaDTO>();
    public List<SelectOption> selectedCValues {get;set;}
    public List<SelectOption> unSelectedCValues {get;set;}
    
    /*Atributos para el manejo de Entrenamientos*/
    Map<id,ListaDTO> leftEValues = new Map<id,ListaDTO>();
    Map<id,ListaDTO> rightEValues = new Map<id,ListaDTO>();
    public List<SelectOption> selectedEValues {get;set;}
    public List<SelectOption> unSelectedEValues {get;set;}
    
    /*Variable para mostrar el recordType Name del cargo seleccionado*/
    public String tipoCargo {get;set;}
    
    /*Variable para mostrar el nombre de la empresa del cargo seleccionado*/
    public String nombreEmpresa {get;set;}
    
    /*Variable para almacenar la url de detalle del cargo donde se retornará luego de asociar formaciones*/
    public String urlCargo {get;set;}
    
    /*Variable para mostrar el mensaje de éxito o error en el modal*/
    public String mensaje {get;set;}
    
    /*Variable para mostrar u ocultar las listas en página cuando el cargo está activo o inactivo*/
    public Boolean activo {get;set;}
    
    /*Método constructor de la formación de cargos*/    
    public SST_FormacionCargoCC(ApexPages.StandardController stdController){
        try{
            mensajesPaginaPrincipal = new  List<SST_MensajesPagina>();
            mensaje = '';
            activo = true;
            selectedCValues = new List<SelectOption>();
            unSelectedCValues = new List<SelectOption>();
            selectedEValues = new List<SelectOption>();
            unSelectedEValues = new List<SelectOption>();
            selectedRValues = new List<SelectOption>();
            unSelectedRValues = new List<SelectOption>();
            List<ID> idExistentes = new List<ID> ();
            cargoSeleccionado= (SST_Cargo__c)stdController.getRecord();
            cargoSeleccionado = [SELECT RecordTypeId, Name, id, estado__c, empresa__c FROM SST_Cargo__c where id = :cargoSeleccionado.Id];
                 
            String objectTypeCargo = Schema.SObjectType.SST_Cargo__c.getName();
            tipoCargo = Schema.SObjectType.SST_Cargo__c.getRecordTypeInfosById().get(cargoSeleccionado.RecordTypeId).getName();
            urlCargo =  SST_Constantes.retornarUrl();
            if(urlCargo<>null && urlCargo.endsWith('sfdcpage/')){
                urlCargo = urlCargo.removeEnd('sfdcpage/');    
            }
            urlCargo =  urlCargo+SST_Constantes.PAGINA_DETALLE_CARGO+'/'+cargoSeleccionado.Id;
            
            /*Si el cargo seleccionado está inactivo, se muestra mensaje en la página y no se permite asociar o desasociar formaciones*/
            if(cargoSeleccionado.estado__c.equals(SST_Constantes.INACTIVO)){
                activo = false;
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El cargo seleccionado se encuentra inactivo.  Sólo puede asociar formaciones a cargos activos.'));
            } else {
                List<String> listaCUnselect = new List<String>();
                List<String> listaEUnselect = new List<String>();
                List<String> listaRUnselect = new List<String>();
                List<String> listaCselect = new List<String>();
                List<String> listaEselect = new List<String>();
                List<String> listaRselect = new List<String>();
                /*se consultan las formaciones que ya estan asociadas al cargo seleccionado*/
                for(SST_Formacion_Cargo__c formacionCargo :[SELECT id,name,formacion__r.Nombre__c,formacion__c,formacion__r.recordType.Name,formacion__r.Competencias__c FROM SST_Formacion_Cargo__c WHERE cargo__c=:cargoSeleccionado.id]){
                    ListaDTO listaDTO = new ListaDTO();
                    listaDTO.idFormacion= formacionCargo.formacion__c;
                    listaDTO.nombre = formacionCargo.formacion__r.Nombre__c;
                    listaDTO.idFormacionCargo = formacionCargo.id;
                    listaDTO.tipoRegistro = formacionCargo.formacion__r.recordType.Name;
                    if(formacionCargo.formacion__r.recordType.Name.contains(SST_Constantes.RECORD_TYPE_RESPONSABILIDADES)){
                        rightRValues.put(formacionCargo.formacion__c,listaDTO);
                        listaRselect.add(listaDTO.nombre+'//'+formacionCargo.formacion__c);
                    }else if(formacionCargo.formacion__r.recordType.Name.contains(SST_Constantes.RECORD_TYPE_COMPETENCIAS)){
                        listaDTO.nombre = formacionCargo.formacion__r.Competencias__c +': '+formacionCargo.formacion__r.Nombre__c;
                        rightCValues.put(formacionCargo.formacion__c,listaDTO);
                        listaCselect.add(listaDTO.nombre+'//'+formacionCargo.formacion__c);
                    }else if(formacionCargo.formacion__r.recordType.Name.contains(SST_Constantes.RECORD_TYPE_ENTRENAMIENTOS)){
                        rightEValues.put(formacionCargo.formacion__c,listaDTO);
                        listaEselect.add(listaDTO.nombre+'//'+formacionCargo.formacion__c);
                    }
                    idExistentes.add(formacionCargo.formacion__c);
                }
                /*se consultan las formaciones que no estan asociadas al cargo existentes*/
                String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
                               
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
                
                
                for(SST_Formacion__c formacion :[SELECT id,Nombre__c,recordType.Name,Competencias__c, tipo_cargo__c FROM SST_Formacion__c WHERE id NOT IN :idExistentes AND Empresa__c =: cargoSeleccionado.empresa__c ORDER BY Nombre__c,Competencias__c]){
                    ListaDTO listaDTO = new ListaDTO();
                    listaDTO.idFormacion= formacion.id;
                    listaDTO.nombre = formacion.Nombre__c;
                    listaDTO.tipoRegistro = formacion.recordType.Name;
                    if(formacion.recordType.Name.contains(SST_Constantes.RECORD_TYPE_RESPONSABILIDADES) && formacion.tipo_cargo__c != null && formacion.tipo_cargo__c.equalsIgnoreCase(tipoCargo)){
                        leftRValues.put(formacion.id,listaDTO);
                        listaRUnselect.add(listaDTO.nombre+'//'+formacion.id);
                    }else if(formacion.recordType.Name.contains(SST_Constantes.RECORD_TYPE_COMPETENCIAS)){
                        listaDTO.nombre = formacion.Competencias__c +': '+formacion.Nombre__c;
                        leftCValues.put(formacion.id,listaDTO);
                        listaCUnselect.add(listaDTO.nombre+'//'+formacion.id);
                    }else if(formacion.recordType.Name.contains(SST_Constantes.RECORD_TYPE_ENTRENAMIENTOS)){
                        leftEValues.put(formacion.id,listaDTO);
                        listaEUnselect.add(listaDTO.nombre+'//'+formacion.id);
                    }
                }
                listaCUnselect.sort();
                listaEUnselect.sort();
                listaRUnselect.sort();
                listaCselect.sort();
                listaEselect.sort();
                listaRselect.sort();
                
                /*Se llenan los select list con las competencias, entrenamientos y responsabilidades disponibles para asociar*/
                for(String temp: listaCUnselect){
                    String[] t = temp.split('//');
                    unselectedCValues.add(new SelectOption(t[1],t[0]));
                }	
                for(String temp: listaEUnselect){
                    String[] t = temp.split('//');
                    unselectedEValues.add(new SelectOption(t[1],t[0]));
                }
                for(String temp: listaRUnselect){
                    String[] t = temp.split('//');
                    unselectedRValues.add(new SelectOption(t[1],t[0]));
                }
                
                /*Se llena el select list con las competencias, entrenamientos y responsabilidades asociadas al cargo*/
                for(String temp: listaCselect){
                    String[] t = temp.split('//');
                    selectedCValues.add(new SelectOption(t[1],t[0]));
                }
                for(String temp: listaEselect){
                    String[] t = temp.split('//');
                    selectedEValues.add(new SelectOption(t[1],t[0]));
                }
                for(String temp: listaRselect){
                    String[] t = temp.split('//');
                    selectedRValues.add(new SelectOption(t[1],t[0]));
                }
            }
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error construyendo el objeto, por favor contacte al administrador'));
            System.debug('Error en SST_FormacionCargoCC() Linea:'+e.getLineNumber()+' - '+e.getMessage());
        }
    }
    
    
    /*Método encargado de guardar las competencias, entrenamientos y responsabilidades elegidas 
por un usuario para un cargo previamente seleccionado*/
    public void guardar(){ 
        try{
            List<SST_Formacion_Cargo__c> formacionesCargoGuardar = new List<SST_Formacion_Cargo__c>();
            List<SST_Formacion_Cargo__c> formacionesCargoEliminar = new List<SST_Formacion_Cargo__c>();
            
            /*Se recorren las listas con las competencias, entrenamientos y responsabilidades seleccionadas, para guardar las formaciones nuevas */
            for(SelectOption temp : SelectedCValues){
                if(rightCValues.get(temp.getValue()) == null){ 
                    SST_Formacion_Cargo__c formacionCargo = new SST_Formacion_Cargo__c();
                    formacionCargo.cargo__c = cargoSeleccionado.id;
                    formacionCargo.Formacion__c = leftCValues.get(temp.getValue()).idFormacion;
                    formacionesCargoGuardar.add(formacionCargo);
                }
            }
            for(SelectOption temp : SelectedEValues){
                if(rightEValues.get(temp.getValue()) == null){ 
                    SST_Formacion_Cargo__c formacionCargo = new SST_Formacion_Cargo__c();
                    formacionCargo.cargo__c = cargoSeleccionado.id;
                    formacionCargo.Formacion__c = leftEValues.get(temp.getValue()).idFormacion;
                    formacionesCargoGuardar.add(formacionCargo);
                }
            }
            for(SelectOption temp : SelectedRValues){
                if(rightRValues.get(temp.getValue()) == null){ 
                    SST_Formacion_Cargo__c formacionCargo = new SST_Formacion_Cargo__c();
                    formacionCargo.cargo__c = cargoSeleccionado.id;
                    formacionCargo.Formacion__c = leftRValues.get(temp.getValue()).idFormacion;
                    formacionesCargoGuardar.add(formacionCargo);
                }
            }
            
            /*Se recorren las listas con las competencias, entrenamientos y responsabilidades sin seleccionar, para eliminar las formaciones removidas */
            for(SelectOption temp : unSelectedCValues){
                if(rightCValues.get(temp.getValue()) <> null){
                    SST_Formacion_Cargo__c formacionCargo = new SST_Formacion_Cargo__c();
                    formacionCargo.id = rightCValues.get(temp.getValue()).idFormacionCargo;
                    formacionesCargoEliminar.add(formacionCargo);
                }
            } 
            for(SelectOption temp : unSelectedEValues){
                if(rightEValues.get(temp.getValue()) <> null){
                    SST_Formacion_Cargo__c formacionCargo = new SST_Formacion_Cargo__c();
                    formacionCargo.id = rightEValues.get(temp.getValue()).idFormacionCargo;
                    formacionesCargoEliminar.add(formacionCargo);
                }
            }
            for(SelectOption temp : unSelectedRValues){
                if(rightRValues.get(temp.getValue()) <> null){
                    SST_Formacion_Cargo__c formacionCargo = new SST_Formacion_Cargo__c();
                    formacionCargo.id = rightRValues.get(temp.getValue()).idFormacionCargo;
                    formacionesCargoEliminar.add(formacionCargo);
                }
            }
            if (Schema.sObjectType.SST_Formacion_Cargo__c.fields.Cargo__c.isCreateable()&&
                Schema.sObjectType.SST_Formacion_Cargo__c.fields.Formacion__c.isCreateable()&&
                Schema.sObjectType.SST_Formacion_Cargo__c.fields.Cargo__c.isUpdateable()&&
                Schema.sObjectType.SST_Formacion_Cargo__c.fields.Formacion__c.isUpdateable()&&
                Schema.sObjectType.SST_Formacion_Cargo__c.sObjectType.getDescribe().isDeletable()){
                    /*se eliminan las formaciones desasociadas del cargo*/
                    if(formacionesCargoEliminar.size()>0){
                        delete(formacionesCargoEliminar);
                    }	
                    
                    /*se guardar las formaciones nuevas asociadas al cargo*/
                    if(formacionesCargoGuardar.size()>0){
                        upsert(formacionesCargoGuardar);
                    }
                    mensaje = 'Las formaciones para el cargo se han atualizado exitosamente.';
                }else{
                    mensaje = 'Permisos insuficientes para eliminar o registrar asociaciones de formaciones con cargos';
                }
        }catch(Exception e){
            mensaje = 'Ocurrió un error al guardar la información, por favor contacte al administrador.';
            System.debug('Error en SST_FormacionCargoCC.guardar() Linea:'+e.getLineNumber()+' - '+e.getMessage());
        }
    }
    
    /*Método que se encarga de regresar a la pagina anterior*/
    public PageReference regresar(){
        PageReference detalleCargo = new pageReference(urlCargo);
        return detalleCargo;
    }
    
    
    /*Clase interna DTO que contiene la información de nombre y id de formación y formación cargo*/
    public class ListaDTO{
        public Id idFormacion{get; set;}
        public String nombre{get; set;}
        public Id idFormacionCargo {get; set;}
        public String tipoRegistro {get;set;}
    }
    
}