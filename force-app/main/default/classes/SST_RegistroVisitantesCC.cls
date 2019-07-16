/**
* Clase que se encarga de la administración del registro de visitantes a la empresa
* @author Angélica Toro Murillo
*/
public with sharing class SST_RegistroVisitantesCC {
    
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    /*Variable que contiene el tipo de identificación del visitante*/
    public String tipoIdentificacion {get; set;}
    
    /*Variable que contiene el número de identificaión del visitante*/
    public String numeroIdentificacion {get; set;}
    
    /*Variable que contiene el tipo de sangre del lector de cédula*/
    public String tipoSangreFiltro {get; set;}
    
    /*Variable que contienee los nombre del lector de cédula*/
    public String nombreFiltro {get; set;}
    
    /*Variable que contienee los nombre del lector de cédula*/
    public String nombreFuncionarioFiltro {get; set;}
    
    /*Objeto con los datos del visitante*/
    public VisitanteDTO visitante {get; set;}
    
    /*si el visitante se encuentra repetido aqui se almacena el seleccionado*/
    public Id visitanteSeleccionado{get; set;}
    
    /*Variable que contiene el id del funcionario seleccionado*/
    public Id funcionarioSeleccionado{get; set;}
    
    /*variable que indica si la empresa tiene el lector de cedulas*/
    public Boolean lectorCedula{get; set;}
    
    /*listado de los funcionarios encontrados con el filtro*/
    public List<Contact> funcionarios {get; set;}
    
    public String tipoIdentificacionMostrar {get; set;}
    
    public Id idFoto {get; set;}
    
    
    
    /*Método constructor */
    public SST_RegistroVisitantesCC(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
        tipoIdentificacion = 'C';
        consultarParametrizacionCuenta();
    }
    
    /*Método encargado de buscar el visitante, por tipo y número identificación, revisando si se trata de un contacto de proveedor, contratista, o proveedor*/
    public void consultarVisitante(){
        try{
            mensajesPaginaPrincipal.clear();
            ajustarFiltros();
            if((tipoIdentificacion<>null && numeroIdentificacion<>null && tipoIdentificacion<>'-1' && !String.isEmpty(numeroIdentificacion)&& !lectorCedula)
               ||(tipoIdentificacion<>null && numeroIdentificacion<>null && tipoIdentificacion<>'-1' && !String.isEmpty(numeroIdentificacion)&& nombreFiltro<> null && !String.isEmpty(nombreFiltro) && tipoSangreFiltro<>null && tipoSangreFiltro<>'-1'&& lectorCedula)){
                   /*se verifica si hay visitas del día de hoy sin registrar salida, entonces se trata de registrar salida*/
                   boolean registrarSalida = false;
                   for(SST_Control_de_acceso__c controlAcceso :[SELECT id FROM SST_Control_de_acceso__c WHERE ((numero_identificacion__c = :numeroIdentificacion AND tipo_identificacion__c  = :tipoIdentificacion)OR  (contacto__r.sst_identificacion__c=:numeroIdentificacion AND contacto__r.sst_tipo_identificacion__c =:tipoIdentificacion)) AND  salida__c = null ORDER by createdDate DESC LIMIT 1]){
                       registrarSalida(controlAcceso.id);
                       registrarSalida = true;
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.INFO,'Se ha registrado la salida exitosamente'));    
                       limpiarDatos();
                   }
                   /*si no se trata de una salida*/
                   if(!registrarSalida){
                       
                       /*se obtienen los valores de los recordtype de contratista, proveedor y contactos de proveedor*/
                       List<ID> idsRecordTypeContacto = new List<ID>();
                       ID contratistas = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contratistas SST').getRecordTypeId();
                       ID proveedores = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Proveedores SST').getRecordTypeId();
                       ID contactosProveedor = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contactos Proveedor').getRecordTypeId();
                       idsRecordTypeContacto.add(contratistas);
                       idsRecordTypeContacto.add(proveedores);
                       idsRecordTypeContacto.add(contactosProveedor);
                       
                       
                       /*se consultan proveedores, contactos de proveedor y contratistas*/
                       for(Contact contacto :[SELECT id,firstName,lastName,SST_Tipo_sangre__c,sst_rh__c,sst_eps__c,sst_arl__c,sst_contacto_emergencia__c, sst_telefono_emergencia__c,recordtype.name,sst_proveedor__r.name,sst_proveedor__r.sst_estado__c,sst_estado__c,sst_retirado__c  FROM Contact WHERE sst_tipo_identificacion__c=:tipoIdentificacion AND sst_identificacion__c=:numeroIdentificacion AND recordTypeId in :idsRecordTypeContacto]){
                           visitante = convertirContactAVisitanteDTO(contacto);
                           /*Aunque se encuentra como contacto se manejará como visitante ocasional*/
                           if((contacto.sst_estado__c == 'INACTIVO'&& contacto.RecordTypeId == contactosProveedor) || (contacto.sst_retirado__c &&(contacto.RecordTypeId==contratistas)||contacto.RecordTypeId==proveedores)){
                               visitante.idContacto = null; 
                               visitante.estado = null;
                               visitante.empresaRepresentacion= null;
                               visitante.tipoVisitante = 'Ocasional';
                           }
                           
                       }
                       /*si no se encuentran registros de proveedor, contratista o contacto de proveedor, se busca registros anteriors como ocasional*/
                       if(visitante== null){
                           visitante  = new VisitanteDTO();
                           /*se verifica si es un visitante ocasional se busca en el registro de visitantes para obtener la información guardada anteriormente*/
                           for(SST_Control_de_acceso__c controlAcceso :[SELECT nombres__c,tipo_sangre__c,rh__c,entidad_promotora_salud__c, administradora_riesgos_laborales__c,contacto_emergencia__c,telefono_emergencia__c,empresa_representa__c FROM SST_Control_de_acceso__c WHERE numero_identificacion__c = :numeroIdentificacion AND tipo_identificacion__c  = :tipoIdentificacion ORDER by createdDate DESC LIMIT 1]){
                               
                               visitante = convertirControlAccesoAVisitanteDTO(controlAcceso);
                               visitante.tipoVisitante = 'Ocasional';
                           }
                           
                           if(visitante.nombre == null){
                               /*si no hay ningun registro guardado y es lector de cédula se pone por defecto el valor de los nombres y rh*/
                               visitante.nombre = nombreFiltro;
                               visitante.tipoSangre = tipoSangreFiltro;
                               visitante.tipoVisitante = 'Ocasional';
                           }
                       }   
                       consultarFoto();
                   }
               }else{
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Debe ingresar los campos requeridos para realizar la búsqueda'));    
               }
        }catch(ApplicationException e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,e.getMessage()));   
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error consultando el visitante, por favor contacte al administrador'+e.getLineNumber()+e.getMessage()+e.getCause()));
            System.debug('Error en consultarVisitante()'+e.getLineNumber()+e.getMessage());
        }
    }
    
    private void consultarFoto(){
        List<Attachment> archivo = [SELECT Id, Body FROM Attachment where parentId in(SELECT id FROM SST_Control_de_acceso__c WHERE tipo_Identificacion__c = :tipoIdentificacion AND numero_identificacion__c= :numeroIdentificacion) order by createddate desc limit 1];
        if(archivo != null && !archivo.isEmpty()){
            idFoto = archivo.get(0).id;
        }else{
            idFoto = null;
        }
    }
    /*Método encargado de guardar el registro de visitas y actualizar si es el caso los valores del contacto*/
    public void guardarVisitante(){
        try{
            String value = system.currentpagereference().getParameters().get('firstvalue');
            mensajesPaginaPrincipal.clear();
            if(Schema.sObjectType.SST_Control_de_acceso__c.fields.funcionario_destino__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.nombres__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.tipo_visitante__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.empresa_representa__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.observaciones__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.entidad_promotora_salud__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.administradora_riesgos_laborales__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.contacto_emergencia__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.telefono_emergencia__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.tipo_identificacion__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.numero_identificacion__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.rh__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.tipo_sangre__c.isCreateable()&&
               Schema.sObjectType.SST_Control_de_acceso__c.fields.contacto__c.isCreateable()&&
               Schema.sObjectType.Contact.fields.sst_tipo_sangre__c.isUpdateable()&&
               Schema.sObjectType.Contact.fields.sst_rh__c.isUpdateable()&&
               Schema.sObjectType.Contact.fields.sst_eps__c.isUpdateable()&&
               Schema.sObjectType.Contact.fields.sst_arl__c.isUpdateable()&&
               Schema.sObjectType.Contact.fields.sst_contacto_emergencia__c.isUpdateable()&&
               Schema.sObjectType.Contact.fields.sst_telefono_emergencia__c.isUpdateable()){
                   if(visitante.idFuncionarioDestino == null || visitante.tipoSangre=='-1' || visitante.eps=='-1'  || visitante.arl=='-1' ||visitante.contactoEmergencia==''|| visitante.telefonoEmergencia=='' ||
                      visitante.empresaRepresentacion == '' ||visitante.contactoEmergencia==null || visitante.telefonoEmergencia == null ||visitante.empresaRepresentacion == null){
                          mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Todos los campos del formulario son obligatorios, por favor diligencie la información'));
                          return;
                      }
                   SST_Control_de_acceso__c controlAcceso = new SST_Control_de_acceso__c();
                   
                   /*si se trata de un visitante que se encuentra entre los contactos*/
                   if(visitante.idContacto<>null){
                       Contact contacto = convertirVisitanteDTOAContacto(visitante);
                       update(contacto); 
                       controlAcceso.contacto__c = visitante.idContacto;
                       
                   }
                   /*si no es un contacto se guarda toda la información sobre el control de acceso*/
                   controlAcceso = convertirVisitanteDTOAControlAcceso(visitante,controlAcceso);
                   insert(controlAcceso);
                   
                   if(value!= null){
                       if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable()&&
                          Schema.sObjectType.Attachment.fields.Body.isCreateable()&&
                          Schema.sObjectType.Attachment.fields.ContentType.isCreateable()&&
                          Schema.sObjectType.Attachment.fields.name.isCreateable()){
                              
                              Attachment archivo = new Attachment();
                              archivo.ParentId = controlAcceso.id;
                              String[] split = value.split(',');
                              archivo.Body = EncodingUtil.base64Decode(split[1]);
                              archivo.ContentType = 'image/png';
                              archivo.Name = numeroIdentificacion+'-visitante.png';
                              insert archivo;
                              
                          }
                   }
                   
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'La visita se creo exitosamente'));
                   limpiarDatos();
               }else{
                   throw new ApplicationException('Permisos insuficientes para modificar o registrar el registro de visitante');
               }
        }catch(ApplicationException ae){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,ae.getMessage()));
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error guardando los datos de la visita, por favor contacte al administrador'+e.getLineNumber()+e.getMessage()));
            System.debug('Error en guardarVisitante()'+e.getLineNumber()+e.getMessage());
        }
    }
    
    
    
    /*Método que se encarga de consultar los funcionarios de acuerdo al filtro de búsqueda*/
    public void consultarFuncionario(){
        try{
            funcionarios = new List<Contact>();
            if(nombreFuncionarioFiltro<> null && !nombreFuncionarioFiltro.equals('')){
                String filtro = '%'+nombreFuncionarioFiltro+'%';
                for(Contact funcionario : [SELECT id,name,sst_area_trabajo__r.name,sst_cargo__r.name FROM Contact WHERE name like :filtro  AND recordType.name ='Funcionarios' ORDER by name]){
                    funcionarios.add(funcionario);
                }
            }
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error consultando los funcionarios'+e.getLineNumber()+e.getMessage()));
            System.debug('Error en consultarFuncionario()'+e.getLineNumber()+e.getMessage());
        }
    }
    /*Método encargado de seleccionar el funcionario despues de realizada la búsqueda*/
    public void seleccionarFuncionario(){
        try{
            visitante.idFuncionarioDestino= funcionarioSeleccionado;
            for(Contact funcionario : funcionarios){
                if(funcionario.Id == funcionarioSeleccionado){
                    visitante.funcionarioDestino = funcionario.Name;  
                }   
            }
            nombreFuncionarioFiltro = null;
            funcionarioSeleccionado = null;
            funcionarios = null;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error seleccionando al funcionario a visitar'+e.getLineNumber()+e.getMessage()));
            System.debug('Error en seleccionarFuncionario()'+e.getLineNumber()+e.getMessage());
        }
    }
    
    /*Método que se encarga de consultar la parametrizacion del lector de cédulas de la cuenta*/
    private void consultarParametrizacionCuenta(){
        try{          
            String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
            Account cuenta = [SELECT SST_lector_cedulas__c FROM Account WHERE SST_nit__c = :Decimal.valueOf(empresaAutenticada)];
            lectorCedula = cuenta.SST_lector_cedulas__c;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error consultando la parametrización de la cuenta'+e.getLineNumber()+e.getMessage()));
            System.debug('Error en consultarParametrizacionCuenta()'+e.getLineNumber()+e.getMessage());
        }
    }
    
    private void ajustarFiltros(){
        if(numeroIdentificacion != null && numeroIdentificacion != ''){
            if(numeroIdentificacion.startsWith('000')){
                numeroIdentificacion = numeroIdentificacion.substring(3,numeroIdentificacion.length());
            }else if(numeroIdentificacion.startsWith('00')){
                numeroIdentificacion = numeroIdentificacion.substring(2,numeroIdentificacion.length());
            }else if(numeroIdentificacion.startsWith('0')){
                numeroIdentificacion = numeroIdentificacion.substring(1,numeroIdentificacion.length());
            }
        }
        if(tipoIdentificacion != null && tipoIdentificacion != ''){
            Schema.DescribeFieldResult campo = Contact.sst_tipo_identificacion__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            
            for( Schema.PicklistEntry pickItem : picklist){
                if(pickItem.getValue()== tipoIdentificacion){
                    tipoIdentificacionMostrar = pickItem.getLabel();
                }
            }   
        }
    }
    
    /*Método que lipiar los valores ingresados en el formulario*/
    private void limpiarDatos(){
        visitante = null;
        tipoIdentificacion = 'C';
        visitanteSeleccionado = null;
        numeroIdentificacion = null;
        tipoSangreFiltro = null;
        nombreFiltro = null;
        nombreFuncionarioFiltro = null; 
    }
    
    /*Método encargado de convertir un visitante DTO a un control de acceso*/
    private SST_Control_de_Acceso__c convertirVisitanteDTOAControlAcceso(VisitanteDTO visitante,SST_Control_de_Acceso__c controlAcceso){
        
        controlAcceso.entidad_promotora_salud__c = visitante.eps ;
        controlAcceso.administradora_riesgos_laborales__c = visitante.arl;
        controlAcceso.contacto_emergencia__c = visitante.contactoEmergencia;
        controlAcceso.telefono_emergencia__c = visitante.telefonoEmergencia;
        controlAcceso.tipo_identificacion__c = tipoIdentificacion;
        controlAcceso.numero_identificacion__c = numeroIdentificacion;
        controlAcceso.tipo_sangre__c = visitante.tipoSangre.substring(0,1);
        controlAcceso.nombres__c = visitante.nombre;
        if(visitante.tipoSangre.contains('+')){
            controlAcceso.rh__c = 'POSITIVO';
        }else{
            controlAcceso.rh__c = 'NEGATIVO';
        }
        controlAcceso.funcionario_destino__c = visitante.idFuncionarioDestino;
        controlAcceso.nombres__c = visitante.nombre;
        controlAcceso.tipo_visitante__c = visitante.tipoVisitante;
        controlAcceso.empresa_representa__c = visitante.empresaRepresentacion;
        controlAcceso.observaciones__c = visitante.observaciones;
        return controlAcceso;
    }
    /*Mëtodo encargado de convertir un visitante DTO a un contacto*/
    private Contact convertirVisitanteDTOAContacto(VisitanteDTO visitante){
        Contact contacto = [SELECT id FROM Contact WHERE id =:visitante.idContacto];
        if(visitante.tipoSangre.contains('AB')){
            contacto.sst_tipo_sangre__c ='AB';
        }else{
            contacto.sst_tipo_sangre__c = visitante.tipoSangre.substring(0,1);    
        }
        
        if(visitante.tipoSangre.contains('+')){
            contacto.sst_rh__c = 'POSITIVO';
        }else{
            contacto.sst_rh__c = 'NEGATIVO';
        }
        contacto.sst_eps__c = visitante.eps;
        contacto.sst_arl__c = visitante.arl;
        contacto.sst_contacto_emergencia__c = visitante.contactoEmergencia;
        contacto.sst_telefono_emergencia__c = visitante.telefonoEmergencia;
        return contacto;
    }
    /*Método encargado de convertir el control de acceso a un visitante DTO*/
    private VisitanteDTO convertirControlAccesoAVisitanteDTO(SST_Control_de_Acceso__c controlAcceso){
        VisitanteDTO visitante = new VisitanteDTO();
        visitante.nombre = controlAcceso.nombres__c;
        visitante.tipoSangre = controlAcceso.tipo_sangre__c;
        if(tipoSangreFiltro!=null){
            visitante.tipoSangre= tipoSangreFiltro;
        }else{
            if(controlAcceso.rh__c =='POSITIVO'){
                visitante.tipoSangre = controlAcceso.tipo_sangre__c+'+';    
            }else{
                visitante.tipoSangre = controlAcceso.tipo_sangre__c+'-';
            }
        }
        visitante.eps = controlAcceso.entidad_promotora_salud__c;
        visitante.arl = controlAcceso.administradora_riesgos_laborales__c;
        visitante.contactoEmergencia = controlAcceso.contacto_emergencia__c;
        visitante.contactoEmergencia = controlAcceso.contacto_emergencia__c;
        visitante.telefonoEmergencia = controlAcceso.telefono_emergencia__c;
        visitante.empresaRepresentacion = controlAcceso.empresa_representa__c;
        
        
        return visitante;
        
    }
    /*Método que se encarga de convertir un contacto a un visitante DTO*/
    private VisitanteDTO convertirContactAVisitanteDTO(Contact contacto){
        VisitanteDTO visitanteContacto = new VisitanteDTO();
        visitanteContacto.nombre = contacto.lastName+ ' '+contacto.FirstName;
        if(contacto.sst_rh__c =='POSITIVO'){
            visitanteContacto.tipoSangre = contacto.SST_Tipo_sangre__c+'+';
        }else{
            visitanteContacto.tipoSangre = contacto.SST_Tipo_sangre__c+'-';
        }
        visitanteContacto.eps = contacto.sst_eps__c;
        visitanteContacto.arl = contacto.sst_arl__c;
        visitanteContacto.contactoEmergencia = contacto.sst_contacto_emergencia__c;
        visitanteContacto.telefonoEmergencia = contacto.sst_telefono_emergencia__c;
        visitanteContacto.idContacto = contacto.id;
        visitanteContacto.tipoVisitante = contacto.recordType.name;
        
        if(contacto.sst_proveedor__r.name != null){
            visitanteContacto.empresaRepresentacion = contacto.sst_proveedor__r.name;
            visitanteContacto.estado = contacto.sst_proveedor__r.sst_estado__c;
        }else{
            visitanteContacto.empresaRepresentacion = contacto.lastName+' '+contacto.FirstName;
            visitanteContacto.estado = contacto.sst_estado__c;
        }
        return visitanteContacto;
    }
    /*Método encargado de registrar la salida del visitante*/
    private void registrarSalida(Id id){
        
        SST_Control_de_Acceso__c controlAcceso= [SELECT id FROM SST_Control_de_Acceso__c WHERE id= :id ];
        controlAcceso.salida__c = DateTime.now();
        if(Schema.sObjectType.SST_Control_de_acceso__c.fields.salida__c.isUpdateable()){
            update(controlAcceso);
        }else{
            throw new ApplicationException('Permisos insuficientes para registrar la salida del visitante');
        }
    }
    
    
    /*Método que obtiene los tipos de identificación de un visitante*/
    public List<SelectOption> getTiposIdentificacion(){
        try{
            Schema.DescribeFieldResult campo = Contact.sst_tipo_identificacion__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('-1',SST_Constantes.ITEM_VACIO_PICKLIST));
            for( Schema.PicklistEntry pickItem : picklist){
                lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
            }   
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista del tipo de identificación, por favor contacte al administrador'));
            System.debug('Error en getTiposIdentificacion()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    
    /*Método que obtiene los RH*/
    public List<SelectOption> getTipoSangre(){
        try{
            
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('-1',SST_Constantes.ITEM_VACIO_PICKLIST));
            lista.add(new SelectOption('A+','A+'));
            lista.add(new SelectOption('A-','A-'));
            lista.add(new SelectOption('AB+','AB+'));
            lista.add(new SelectOption('AB-','AB-'));
            lista.add(new SelectOption('B+','B+'));
            lista.add(new SelectOption('B-','B-'));            
            lista.add(new SelectOption('O+','O+'));
            lista.add(new SelectOption('O-','O-'));             
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista de RH, por favor contacte al administrador'));
            System.debug('Error en getRhs()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /*Método que obtiene las EPS*/
    public List<SelectOption> getEPS(){
        try{
            Schema.DescribeFieldResult campo = Contact.sst_EPS__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('-1',SST_Constantes.ITEM_VACIO_PICKLIST));
            for( Schema.PicklistEntry pickItem : picklist){
                lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
            }   
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista de las EPS, por favor contacte al administrador'));
            System.debug('Error en getEPS()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /*Método que obtiene las ARL*/
    public List<SelectOption> getARL(){
        try{
            Schema.DescribeFieldResult campo = Contact.sst_ARL__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('-1',SST_Constantes.ITEM_VACIO_PICKLIST));
            for( Schema.PicklistEntry pickItem : picklist){
                lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
            }   
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista de las ARL, por favor contacte al administrador'));
            System.debug('Error en getArl()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    
    /*Clase que contiene el DTO para la administración de los visitantes */
    public class VisitanteDTO{
        public String numeroIdentificacion {get; set;}
        public String tipoIdentificacion{get; set;}
        public ID idControlAcceso {get; set;}
        public String nombre {get; set;}
        public String tipoSangre {get; set;}
        public String eps {get; set;}
        public String arl {get; set;}
        public String contactoEmergencia {get; set;}
        public String telefonoEmergencia {get; set;}
        public ID idContacto {get; set;}
        public ID idFuncionarioDestino {get; set;}
        public String funcionarioDestino {get; set;}
        public String tipoVisitante {get; set;}
        public String estado {get; set;}
        public String empresaRepresentacion {get; set;}
        public String observaciones {get; set;}
    }
    /*Clase exception*/
    public class ApplicationException extends Exception {}
}