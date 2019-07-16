public with sharing class SST_EncuestaSociodemograficaCC {       
    
    //Atributos para obtener el consecutivo y el ID de la encuesta vigente, para las notificaciones a SST
    String consecutivoEncuesta {get;set;}
    String idEncuesta {get;set;}
    
    //Atributo para almacenar los datos personales y/o laborales que deben ser modificados del funcionario
    List<String> datosModificados {get;set;}
    
    //Atributos para obtener los datos de los miembros del grupo familiar, que se ingresan por pantalla
    public String idFamiliar {get;set;}
    public String nombreFamiliar {get;set;}
    public String identifFamiliar {get;set;}
    public String familiarDependiente {get;set;}
    public String inicioBeneficioFamiliar {get;set;}
    public String finBeneficioFamiliar {get;set;}
    public String fechaNacFamiliar {get;set;}
    public SST_grupo_familiar__c familiar {get;set;}
    public List<SelectOption> discapacidadFamiliarDisp {get;set;}
    public List<SelectOption> discapacidadFamiliarSelec {get;set;} 
    
    //Atributo con la lista de miembros del grupo familiar del funcionario
    public List<SST_grupo_familiar__c> listaFamiliares {get;set;}
    
    //Atributo con la lista de miembros a eliminar del grupo familiar del funcionario
    List<SST_grupo_familiar__c> familiaresParaRemover {get;set;}
    
    //Atributo con el link de la comunidad SST
    Public String linkSST {get;set;}
    
    //Atributo para establecer la fecha máxima disponible para seleccionar en la página en los campos de fecha
    public String fechaMax {get;set;}
    
    //Atributo para mostrar los mensajes de éxito, confirmación o error en la página y en el modal con los datos de familiares
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    public List<SST_MensajesPagina> mensajesModal {get;set;}
    
    //Atributos para mostrar en pantalla los datos del contacto y capturar las respuestas de la encuesta
    public DTOContacto contacto {get;set;}
    public SST_Informacion_sociodemografica__c infoContacto {get;set;}
    Contact contactoTemp {get;set;}
    
    //Atributos para renderizar las diferentes secciones de la encuesta en pantalla
    public Boolean mostrarSeccion {get;set;}
    public Boolean mostrarSubseccion1 {get;set;}
    public Boolean mostrarSubseccion2 {get;set;}
    public Boolean mostrarSubseccion3 {get;set;}
    public Boolean mostrarSeccion1 {get;set;}
    public Boolean mostrarSeccion2 {get;set;}
    public Boolean mostrarSeccion3 {get;set;}
    public Boolean mostrarSeccion4 {get;set;} 
    public Boolean mostrarSeccion5 {get;set;} 
    
    //Atributos para habilitar la edición de los select de Departamento en pantalla
    public Boolean soloLecturaDepartamento{get;set;}    
    
    //Atributo para obtener el nombre de la empresa
    public String nombreEmpresa {get;set;}
    
    //Atributo para mostrar en pantalla el texto la política de tratamiento de datos personales
    public String textoPolitica {get;set;}
    
    //Atributos para mostrar en pantalla los label de los SelectOptions seleccionados
    public Map<String,String> MapaTipoDoc {get;set;}
    public Map<String,String> MapaEstadoCivil {get;set;}
    public Map<String,String> MapaEscolaridad {get;set;}
    public Map<String,String> MapaDepartamento {get;set;}
    public Map<String,String> MapaMunic {get;set;}
    public Map<String, List<SelectOption>> MapaMunicipios {get;set;}
    public Map<String,String> MapaTipoContrato {get;set;}
    public Map<String,String> MapaEPS {get;set;}
    public Map<String,String> MapaAFP {get;set;}
    public Map<String,String> MapaSede {get;set;}
    public Map<String,String> MapaArea {get;set;} 
    
    //Atributos para obtener los nombres de las páginas con las diferentes secciones de la encuesta
    public String pagina1 {get;set;}
    public String pagina2 {get;set;}
    public String pagina3 {get;set;}
    public String pagina4 {get;set;}
    public String pagina5 {get;set;}
    
    //Atributos con los selectOption para mostrar en pantalla
    public List<SelectOption> sede {get;set;}
    public List<SelectOption> area {get;set;}
    public List<SelectOption> tiposDiscapacidadDisponibles {get;set;}
    public List<SelectOption> tiposDiscapacidadSeleccionados {get;set;}
    public List<SelectOption> origenesDiscapacidadDisponibles {get;set;}
    public List<SelectOption> origenesDiscapacidadSeleccionados {get;set;}
    public List<SelectOption> actividadesBienestarDisponibles {get;set;}
    public List<SelectOption> actividadesBienestarSeleccionados {get;set;}
    
    public SST_EncuestaSociodemograficaCC(){
        pagina1 = 'sstencuestasociodemograficaseccion1';
        pagina2 = 'sstencuestasociodemograficaseccion2';
        pagina3 = 'sstencuestasociodemograficaseccion3';
        pagina4 = 'sstencuestasociodemograficaseccion4';
        pagina5 = 'sstencuestasociodemograficaseccion5';
        inicializarVariables();
        mensajesPaginaPrincipal =  new List<SST_MensajesPagina>();
        mensajesModal =  new List<SST_MensajesPagina>();
        linkSST = SST_Constantes.LINK_SST;
        Date d = system.today();
        fechaMax = String.valueOf(d);
        textoPolitica = SST_Constantes.returnTextoTratamiendoDatos(nombreEmpresa);
        mostrarSeccion = true;
        mostrarSubseccion1 = true;
        mostrarSubseccion2 = false;
        mostrarSubseccion3 = false;
        mostrarSeccion1 = false;
        mostrarSeccion2 = false;
        mostrarSeccion3 = false;
        mostrarSeccion4 = false;
        mostrarSeccion5 = false;
    }
    
    //Método que inicializa todas las variables
    void inicializarVariables(){
        nombreEmpresa = [select sst_grupo_empresarial__c from Account where sst_estado__c =: SST_Constantes.ACTIVO limit 1].sst_grupo_empresarial__c;
        idEncuesta = '';
        consecutivoEncuesta = '';
        idFamiliar = '';
        nombreFamiliar = '';
        identifFamiliar = '';
        contactoTemp = new Contact();
        familiar = new SST_grupo_familiar__c();
        listaFamiliares = new List<SST_grupo_familiar__c>();
        familiaresParaRemover = new List<SST_grupo_familiar__c>();
        datosModificados = new List<String>(); 
        MapaTipoDoc = new Map<String,String>(); 
        MapaEstadoCivil = new Map<String,String>(); 
        MapaEscolaridad = new Map<String,String>(); 
        MapaDepartamento = new Map<String,String>();    
        MapaMunic = new Map<String,String>();   
        MapaMunicipios = new Map<String, List<SelectOption>>();
        MapaTipoContrato = new Map<String,String>();    
        MapaEPS = new Map<String,String>(); 
        MapaAFP = new Map<String,String>(); 
        MapaSede = new Map<String,String>();    
        MapaArea = new Map<String,String>();    
        area = new List<SelectOption>();
        sede = new List<SelectOption>(); 
        tiposDiscapacidadDisponibles = new List<SelectOption>();
        tiposDiscapacidadSeleccionados = new List<SelectOption>();
        origenesDiscapacidadDisponibles = new List<SelectOption>();
        origenesDiscapacidadSeleccionados = new List<SelectOption>();
        actividadesBienestarDisponibles = new List<SelectOption>();
        actividadesBienestarSeleccionados = new List<SelectOption>();
        getTipoDoc();
        getEstadoCivil();
        getEscolaridad();
        getEtnia();
        getDepartamento();
        getTipoContrato();
        getEPS();
        getAFP();
        mensajesModal = new List<SST_MensajesPagina>();
        contacto = new DTOContacto();
        infoContacto = new SST_Informacion_sociodemografica__c();
        soloLecturaDepartamento = true;
    }
    
    //Método para consultar todos los datos del contacto
    public pageReference consultarContacto(){
        contactoTemp = new Contact();
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        mensajesModal = new List<SST_MensajesPagina>();
        infoContacto = new SST_Informacion_sociodemografica__c();
        contacto.identificacion = contacto.identificacion.trim();
        contacto.codigo = contacto.codigo.trim();
        if(String.isEmpty(contacto.identificacion) || String.isEmpty(contacto.codigo)){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Digite el número de identificación y el código de acceso para continuar'));
        } else if(!contacto.identificacion.isAlphanumeric() || !contacto.codigo.isAlphanumeric()){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El texto ingresado en las casillas contiene caracteres no permitidos'));            
        } else {
            //Se llena el selectOption con las sedes
            sede.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
            for (SST_sede__c temp : [select id, name from SST_sede__c where estado__c =: SST_Constantes.ACTIVO]){
                sede.add(new SelectOption(temp.id,temp.name));
                MapaSede.put(temp.id,temp.name);
            }
            //Se llena el selectOption con las áreas
            area.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
            for (SST_area_trabajo__c temp : [select id, name from SST_area_trabajo__c where estado__c =: SST_Constantes.ACTIVO]){
                area.add(new SelectOption(temp.id,temp.name));
                MapaArea.put(temp.id,temp.name);
            }
            //Se consultan los datos del contacto que se alojan en el objeto Contact.  Si el contacto modifica uno o más de estos datos, se envía correo al líder SST con los nuevos valores
            List<Contact> listaContacto = [select id, name, sst_empresa__c, sst_tipo_identificacion__c, recordType.name, SST_Identificacion__c, sst_estado__c, recordTypeId, birthdate, sst_genero__c, 
                                           sst_estado_civil__c, SST_Nivel_Escolaridad__c, SST_Etnia__c, SST_Barrio__c, sst_direccion__c, MobilePhone, phone, sst_departamento__c, sst_municipio__c,
                                           sst_estrato__c, SST_Cargo__c, SST_Cargo__r.name, SST_Tipo_Contrato__c, SST_sede__c, SST_sede__r.name, SST_area_trabajo__c, SST_area_trabajo__r.name,
                                           SST_EPS__c, SST_Fondo_Pensiones__c, SST_Fondo_Cesantias__c, SST_ARL__c from contact where id =:contacto.codigo and sst_identificacion__c =: contacto.identificacion];
            if(listaContacto.size()==0){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El funcionario no está registrado en el sistema.  Verifique el número de identificación y el código de acceso.'));
            } else if(listaContacto.size()>0 && listaContacto.get(0).sst_estado__c.equals(SST_Constantes.INACTIVO)){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El funcionario está inactivo en el sistema.  Comuníquese con el área de seguridad y salud en el trabajo.'));
            } else if(listaContacto.size()>0 && !listaContacto.get(0).recordType.name.equals(SST_Constantes.FUNCIONARIO)){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El contacto no está registrado en el sistema como Funcionario.  Comuníquese con el área de seguridad y salud en el trabajo.'));
            }
            else {
                contactoTemp = listaContacto.get(0);
                List <SST_Encuesta_sociodemografica__c> listaEncuesta = [select id, name, Fecha_inicio__c, Fecha_fin__c, estado__c from SST_Encuesta_sociodemografica__c where vigente__c =: true and empresa__c =: contactoTemp.sst_empresa__c order by CreatedDate DESC limit 1];
                if(listaEncuesta.size()==0){ 
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'La encuesta no ha sido aún configurada.  Comuníquese con el área de seguridad y salud en el trabajo'));
                } else {
                    //Se verifica si la encuesta está en estado Activo, de lo contrario no permite su diligenciamiento
                    if(listaEncuesta.get(0).estado__c.equals(SST_Constantes.INACTIVO)){
                        mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'La encuesta ha sido cerrada y ya no es posible su diligenciamiento.'));  
                        inicializarVariables();
                    } else{  
                        //Se consultan los datos del contacto que se alojan en el objeto SST_Informacion_sociodemografica__c.  Si el contacto modifica uno o más de estos datos, se actualizan en el objeto al finalizar la encuesta
                        List <SST_Informacion_sociodemografica__c> listaInfo = [select id, name, empresa__c, Encuesta_sociodemografica__c, Funcionario__c, Consentimiento__c, Actividades__c, Antiguedad__c,
                                                                                Antiguedad_cargo__c, Cabeza_de_hogar__c, Consume_licor__c, Deporte__c, Discapacidad__c, Datos_modificados__c,
                                                                                Discapacidad_certificada__c, experiencia__c, Extemporaneo__c, Fuma__c, Grupo_sindical__c,
                                                                                Ingresos__c, LGTBI__c, Origen_discapacidad__c, Personas_a_cargo__c, Porcentaje_discapacidad__c,
                                                                                Tipo_discapacidad__c, Tipo_vivienda__c, Tratamiento_discapacidad__c 
                                                                                from SST_Informacion_sociodemografica__c where Funcionario__c =: contactoTemp.id ];
                        
                        idEncuesta = listaEncuesta.get(0).id;
                        if(listaInfo.size()>0 && listaInfo.get(0).Encuesta_sociodemografica__c.equals(idEncuesta)){ 
                            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.INFO,'Usted ya diligenció la encuesta actualmente vigente.  Gracias por su colaboración.'));
                        } else if(listaInfo.size()==0  || !listaInfo.get(0).Encuesta_sociodemografica__c.equals(idEncuesta)){
                            consecutivoEncuesta = listaEncuesta.get(0).name;
                            Schema.DescribeFieldResult fieldResult1 = SST_Informacion_sociodemografica__c.Tipo_discapacidad__c.getDescribe();
                            Schema.DescribeFieldResult fieldResult2 = SST_Informacion_sociodemografica__c.Origen_discapacidad__c.getDescribe();
                            Schema.DescribeFieldResult fieldResult3 = SST_Informacion_sociodemografica__c.Actividades__c.getDescribe();
                            MapaMunic = getMunicipio();
                            MapaMunicipios = getMunicipios();
                            listaFamiliares = [select id, Depende_economicamente__c, Fecha_Nacimiento__c, Funcionario__c, Genero__c, 
                                               Nombre_completo__c, Numero_Identificacion__c, Parentesco__c, Tipo_Documento__c,
                                               Discapacidad__c, trabajo__c, Representante_legal__c, Escolaridad__c, Programa_gubernamental__c, 
                                               Fecha_inicio_beneficio__c, Fecha_final_beneficio__c, Tipo_Discapacidad__c  
                                               from SST_Grupo_familiar__c where Funcionario__c =: contactoTemp.id];
                            contacto.nombre = contactoTemp.name;
                            if(listaFamiliares.size()==0){
                                contacto.tieneFamiliares = '';
                            } else {
                                contacto.tieneFamiliares = 'NO';
                            }
                            contacto.identificacion = contactoTemp.SST_Identificacion__c;
                            if(contactoTemp.sst_tipo_identificacion__c <> null){
                                contacto.tipoIdentificacion = contactoTemp.sst_tipo_identificacion__c;
                            } else {
                                contacto.tipoIdentificacion = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.birthdate <> null){
                                contacto.fechaNacimiento = contactoTemp.birthdate;
                            } else {
                                contacto.fechaNacimiento = null;
                            }
                            if(contactoTemp.sst_genero__c <> null){
                                contacto.genero = contactoTemp.sst_genero__c;    
                            } else {
                                contacto.genero = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.sst_estado_civil__c <> null){
                                contacto.estadoCivil = contactoTemp.sst_estado_civil__c;    
                            } else {
                                contacto.estadoCivil = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_Nivel_Escolaridad__c <> null){
                                contacto.escolaridad = contactoTemp.SST_Nivel_Escolaridad__c;    
                            } else {
                                contacto.escolaridad = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_Etnia__c <> null){
                                contacto.etnia = contactoTemp.SST_Etnia__c;    
                            } else {
                                contacto.etnia = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.sst_estrato__c <>null){
                                contacto.estrato = contactoTemp.sst_estrato__c;
                            } else {
                                contacto.estrato = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_Barrio__c <> null){
                                contacto.barrio = contactoTemp.SST_Barrio__c;
                            } else {
                                contacto.barrio = '';
                            }
                            if(contactoTemp.sst_direccion__c <> null){
                                contacto.direccion = contactoTemp.sst_direccion__c;
                            } else {
                                contacto.direccion = '';
                            }
                            if(contactoTemp.MobilePhone <> null){
                                contacto.celular = String.valueOf(contactoTemp.MobilePhone);
                            } else {
                                contacto.celular = '';
                            }
                            if(contactoTemp.phone <> null){
                                contacto.telefono = String.valueOf(contactoTemp.phone);
                            } else {
                                contacto.telefono = '';
                            }
                            if(contactoTemp.sst_departamento__c <>null){
                                contacto.departamento = contactoTemp.sst_departamento__c;
                                if(contactoTemp.sst_municipio__c <>null){
                                    contacto.municipio = SST_Constantes.ITEM_VACIO_PICKLIST;
                                    for(SelectOption temp : MapaMunicipios.get(contactoTemp.sst_departamento__c)) {
                                        if(temp.getValue().equals(contactoTemp.sst_municipio__c)){
                                            contacto.municipio = contactoTemp.sst_municipio__c;
                                            break;
                                        }
                                    } 
                                } else {
                                    contacto.municipio = SST_Constantes.ITEM_VACIO_PICKLIST;
                                }
                            } else {
                                contacto.departamento = SST_Constantes.ITEM_VACIO_PICKLIST;
                                contacto.municipio = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_Tipo_Contrato__c <>null){
                                contacto.tipoContrato = contactoTemp.SST_Tipo_Contrato__c;
                            } else {
                                contacto.tipoContrato = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_Cargo__c <>null){
                                contacto.cargo = contactoTemp.SST_Cargo__r.name;
                            } else {
                                contacto.cargo = '';
                            }
                            if(contactoTemp.SST_sede__c <>null){
                                contacto.sede = contactoTemp.SST_sede__c;
                            } else {
                                contacto.sede = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_area_trabajo__c <>null){
                                contacto.area = contactoTemp.SST_area_trabajo__c;
                            } else {
                                contacto.area = SST_Constantes.ITEM_VACIO_PICKLIST;
                            } 
                            if(contactoTemp.SST_EPS__c <>null){
                                contacto.EPS = contactoTemp.SST_EPS__c;
                            } else {
                                contacto.EPS = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_Fondo_Pensiones__c <>null){
                                contacto.fondoPensiones = contactoTemp.SST_Fondo_Pensiones__c;
                            } else {
                                contacto.fondoPensiones = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_Fondo_Cesantias__c <>null){
                                contacto.fondoCesantias = contactoTemp.SST_Fondo_Cesantias__c;
                            } else {
                                contacto.fondoCesantias = SST_Constantes.ITEM_VACIO_PICKLIST;
                            }
                            if(contactoTemp.SST_ARL__c <>null){
                                Schema.DescribeFieldResult fieldResult = Contact.SST_ARL__c.getDescribe();
                                List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
                                for(Schema.PicklistEntry temp : fieldResult.getPicklistValues()){
                                    if(contactoTemp.SST_ARL__c.equals(temp.getValue())){
                                        contacto.arl = temp.getLabel();
                                        break;
                                    }
                                }
                            } else {
                                contacto.arl = '';
                            }
                            if(listaInfo.size()==0){
                                infoContacto.Funcionario__c = contacto.codigo;
                                infoContacto.discapacidad__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Discapacidad_certificada__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.actividades__c = '';
                                infoContacto.Origen_discapacidad__c = '';
                                infoContacto.Porcentaje_discapacidad__c = null;
                                infoContacto.Tipo_discapacidad__c = '';
                                infoContacto.Tratamiento_discapacidad__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Tipo_vivienda__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Fuma__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Consume_licor__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Deporte__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Cabeza_de_hogar__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Personas_a_cargo__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.LGTBI__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Antiguedad__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Antiguedad_cargo__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.experiencia__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Grupo_sindical__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                infoContacto.Ingresos__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                                for(Schema.PicklistEntry temp : fieldResult1.getPicklistValues()){
                                    tiposDiscapacidadDisponibles.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                }
                                for(Schema.PicklistEntry temp : fieldResult2.getPicklistValues()){
                                    origenesDiscapacidadDisponibles.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                }
                                for(Schema.PicklistEntry temp : fieldResult3.getPicklistValues()){
                                    actividadesBienestarDisponibles.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                }
                            } 
                            else {
                                infoContacto = listaInfo.get(0);
                                for(Schema.PicklistEntry temp : fieldResult1.getPicklistValues()){
                                    if(String.isEmpty(infoContacto.Tipo_discapacidad__c) || (!String.isEmpty(infoContacto.Tipo_discapacidad__c) && !infoContacto.Tipo_discapacidad__c.contains(temp.getValue()))){
                                        tiposDiscapacidadDisponibles.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                    } else if(!String.isEmpty(infoContacto.Tipo_discapacidad__c) && infoContacto.Tipo_discapacidad__c.contains(temp.getValue())){
                                        tiposDiscapacidadSeleccionados.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                    }
                                }
                                
                                for(Schema.PicklistEntry temp : fieldResult2.getPicklistValues()){
                                    if(String.isEmpty(infoContacto.Origen_discapacidad__c) || (!String.isEmpty(infoContacto.Origen_discapacidad__c) && !infoContacto.Origen_discapacidad__c.contains(temp.getValue()))){
                                        origenesDiscapacidadDisponibles.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                    } else if(!String.isEmpty(infoContacto.Origen_discapacidad__c) && infoContacto.Origen_discapacidad__c.contains(temp.getValue())){
                                        origenesDiscapacidadSeleccionados.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                    }
                                }
                                
                                for(Schema.PicklistEntry temp : fieldResult3.getPicklistValues()){
                                    if(String.isEmpty(infoContacto.Actividades__c) || (!String.isEmpty(infoContacto.Actividades__c) && !infoContacto.Actividades__c.contains(temp.getValue()))){
                                        actividadesBienestarDisponibles.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                    } else if(!String.isEmpty(infoContacto.Actividades__c) && infoContacto.Actividades__c.contains(temp.getValue())){
                                        actividadesBienestarSeleccionados.add(new SelectOption(temp.getValue(),temp.getLabel()));   
                                    }  
                                }
                            }
                            infoContacto.Encuesta_sociodemografica__c = idEncuesta;
                            infoContacto.name = SST_Constantes.INFO_SOCIODEMOGRAFICA_VIGENTE;
                            infoContacto.consentimiento__c = SST_Constantes.ITEM_VACIO_PICKLIST;
                            infoContacto.Datos_modificados__c = '';
                            infoContacto.empresa__c = contactoTemp.sst_empresa__c;
                            if(listaEncuesta.get(0).Fecha_fin__c >= system.today()){
                                infoContacto.Extemporaneo__c = false;
                            } else {
                                infoContacto.Extemporaneo__c = true;
                            }
                            mostrarSeccion = true;
                            mostrarSubseccion1 = false;
                            mostrarSubseccion2 = true;
                        }
                    }
                }
            }
        }
        return null;
    }
    
    //Método para dar inicio o finalización a la encuesta, dependiendo de la autorización inicial
    public pageReference iniciarEncuesta(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        if(infoContacto.Consentimiento__c == null || infoContacto.Consentimiento__c == SST_Constantes.ITEM_VACIO_PICKLIST){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Debe seleccionar una opción'));
        } else if(infoContacto.Consentimiento__c.equals('SI')){
            mostrarSeccion = false;
            mostrarSubseccion1 = false;
            mostrarSubseccion2 = false;
            mostrarSubseccion3 = false;
            mostrarSeccion1 = true;
            mostrarSeccion2 = false;
            mostrarSeccion3 = false;
            mostrarSeccion4 = false;
            mostrarSeccion5 = false;
        } else if(infoContacto.Consentimiento__c.equals('NO')) {
            mostrarSeccion1 = false;
            mostrarSeccion = true;
            mostrarSubseccion1 = false;
            mostrarSubseccion2 = false;
            mostrarSubseccion3 = true;
        }  
        return null; 
    }
    
    //Método para avanzar entre las diferentes páginas de la encuesta
    public pageReference irAdelante(){
        mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El municipio no es válido para el departamento seleccionado'));
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        if(mostrarSeccion1){
            Boolean mcipioCorrecto = false;
            for(SelectOption temp : MapaMunicipios.get(contacto.departamento)) {
                if(temp.getValue().equals(contacto.municipio)){
                    mcipioCorrecto = true;
                    break;
                }
            } 
            if(!mcipioCorrecto){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El municipio no es válido para el departamento seleccionado'));
                mostrarSeccion1 = true;
            } else {
                mostrarSeccion = false;
                mostrarSubseccion1 = false;
                mostrarSubseccion2 = false;
                mostrarSubseccion3 = false;
                mostrarSeccion1 = false;
                mostrarSeccion2 = true;
                mostrarSeccion3 = false;
                mostrarSeccion4 = false;
                mostrarSeccion5 = false;
            }
        } 
        else if(mostrarSeccion2){
            mostrarSeccion = false;
            mostrarSubseccion1 = false;
            mostrarSubseccion2 = false;
            mostrarSubseccion3 = false;
            mostrarSeccion1 = false;
            mostrarSeccion2 = false;
            mostrarSeccion3 = true;
            mostrarSeccion4 = false;
            mostrarSeccion5 = false;
        } 
        else if(mostrarSeccion3){
            if(infoContacto.Discapacidad__c.equals('SI') && (tiposDiscapacidadSeleccionados.size()==0 || origenesDiscapacidadSeleccionados.size()==0)){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Si padece algún tipo de discapacidad, debe indicar el tipo y origen de la misma'));
                mostrarSeccion3 = true;    
            } 
            else if(infoContacto.Discapacidad__c.equals('NO') && (tiposDiscapacidadSeleccionados.size()>0 || origenesDiscapacidadSeleccionados.size()>0)){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Si no padece algún tipo de discapacidad, no seleccione ningún tipo ni origen'));
                mostrarSeccion3 = true;    
            } 
            if(contacto.tieneFamiliares == null){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Debe indicar si desea o no agregar miembros a su grupo familiar'));
                mostrarSeccion3 = true;    
            } 
            if(mensajesPaginaPrincipal.size()==0){
                mostrarSeccion = false;
                mostrarSubseccion1 = false;
                mostrarSubseccion2 = false;
                mostrarSubseccion3 = false;
                mostrarSeccion1 = false;
                mostrarSeccion2 = false;
                mostrarSeccion3 = false;
                if(contacto.tieneFamiliares.equals('SI')){
                    mostrarSeccion4 = true;
                    mostrarSeccion5 = false;
                } else {
                    mostrarSeccion4 = false;
                    mostrarSeccion5 = true;
                }
            }
        }
        else if(mostrarSeccion4){
            for(SST_grupo_familiar__c temp : listaFamiliares){
                if(String.isEmpty(temp.Discapacidad__c)){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Por favor indique si el familiar '+temp.Nombre_completo__c+' padece algún tipo de discapacidad'));
                }
            }
            if(mensajesPaginaPrincipal.size()==0){
                mostrarSeccion = false;
                mostrarSubseccion1 = false;
                mostrarSubseccion2 = false;
                mostrarSubseccion3 = false;
                mostrarSeccion1 = false;
                mostrarSeccion2 = false;
                mostrarSeccion3 = false;
                mostrarSeccion4 = false;
                mostrarSeccion5 = true;
            }
        }
        else if(mostrarSeccion5){
            if(actividadesBienestarSeleccionados.size()==0){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Si no participa o ha participado en alguna actividad de bienestar, seleccione el valor "Ninguna" al final de la lista.'));
            } else {
                guardar(); 
            }
        }
        else if(mostrarSubseccion3){
            guardar();  
        }
        return null; 
    }
    
    //Método para devolverse a las sección anterior a la página que se está visualizando en pantalla
    public pageReference irAtras(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        if(mostrarSubseccion3){
            mostrarSeccion = true;
            mostrarSubseccion1 = false;
            mostrarSubseccion2 = true;
            mostrarSubseccion3 = false;
            mostrarSeccion1 = false;
            mostrarSeccion2 = false;
            mostrarSeccion3 = false;
            mostrarSeccion4 = false;
            mostrarSeccion5 = false;
        }
        else if(mostrarSeccion2){
            mostrarSeccion = false;
            mostrarSubseccion1 = false;
            mostrarSubseccion2 = false;
            mostrarSubseccion3 = false;
            mostrarSeccion1 = true;
            mostrarSeccion2 = false;
            mostrarSeccion3 = false;
            mostrarSeccion4 = false;
            mostrarSeccion5 = false;
        }
        else if(mostrarSeccion3){
            mostrarSeccion = false;
            mostrarSubseccion1 = false;
            mostrarSubseccion2 = false;
            mostrarSubseccion3 = false;
            mostrarSeccion1 = false;
            mostrarSeccion2 = true;
            mostrarSeccion3 = false;
            mostrarSeccion4 = false;
            mostrarSeccion4 = false;
        }
        else if(mostrarSeccion4){
            mostrarSeccion = false;
            mostrarSubseccion1 = false;
            mostrarSubseccion2 = false;
            mostrarSubseccion3 = false;
            mostrarSeccion1 = false;
            mostrarSeccion2 = false;
            mostrarSeccion3 = true;
            mostrarSeccion4 = false;
            mostrarSeccion5 = false;
        }
        else if(mostrarSeccion5){
            mostrarSeccion = false;
            mostrarSubseccion1 = false;
            mostrarSubseccion2 = false;
            mostrarSubseccion3 = false;
            mostrarSeccion1 = false;
            mostrarSeccion2 = false;
            mostrarSeccion5 = false;
            if(contacto.tieneFamiliares.equals('SI')){
                mostrarSeccion3 = false;
                mostrarSeccion4 = true;
            } else {
                mostrarSeccion3 = true;
                mostrarSeccion4 = false;
            }
        }
        return null;
    } 
    
    //Método para persistir en el controlador los datos de los miembros del grupo familiar
    public void obtenerDatosFamiliar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        mensajesModal = new List<SST_MensajesPagina>();   
        familiarDependiente = SST_Constantes.ITEM_VACIO_PICKLIST;
        fechaNacFamiliar = '';
        inicioBeneficioFamiliar = '';
        finBeneficioFamiliar = '';
        discapacidadFamiliarDisp = new List<SelectOption>();
        discapacidadFamiliarSelec = new List<SelectOption>();
        familiar = new SST_grupo_familiar__c();
        Schema.DescribeFieldResult fieldResult = SST_Grupo_familiar__c.Tipo_Discapacidad__c.getDescribe();
        for(Schema.PicklistEntry temp : fieldResult.getPicklistValues()){
            discapacidadFamiliarDisp.add(new SelectOption(temp.getValue(),temp.getLabel()));   
        }
        
        /*si llega el nombre del familiar y su identificación es poruqe ya esta en la lista de familiares*/
        if(!String.isEmpty(nombreFamiliar) && !String.isEmpty(identifFamiliar)){
            for(SST_grupo_familiar__c ttmp : listaFamiliares){
                if(ttmp.Nombre_completo__c.equalsIgnoreCase(nombreFamiliar) && ttmp.Numero_Identificacion__c.equalsIgnoreCase(identifFamiliar)){
                    familiar = ttmp;
                    //se comentan estas lineas, pues si el id llega al igual el ttmp tambien pasa el id, y si no lo tiene queda null desde su instanciación
                    /*if(!String.isEmpty(idFamiliar)){
familiar.id = idFamiliar;    
} else {
familiar.id = null;
}*/
                    
                    fechaNacFamiliar = String.valueOf(familiar.Fecha_Nacimiento__c);
                    if(familiar.Fecha_inicio_beneficio__c <> null){
                        inicioBeneficioFamiliar = String.valueOf(familiar.Fecha_inicio_beneficio__c);    
                    } 
                    if(familiar.Fecha_final_beneficio__c <> null){
                        finBeneficioFamiliar = String.valueOf(familiar.Fecha_final_beneficio__c);    
                    }
                    if(familiar.depende_economicamente__c){
                        familiarDependiente = 'SI';
                    } else {
                        familiarDependiente = 'NO';
                    } 
                    List<SelectOption> temporal = new List<SelectOption>();
                    for(SelectOption t : discapacidadFamiliarDisp){
                        if(String.isEmpty(familiar.Tipo_discapacidad__c) || (!String.isEmpty(familiar.Tipo_discapacidad__c) && !familiar.Tipo_discapacidad__c.contains(t.getValue()))){
                            temporal.add(new SelectOption(t.getValue(),t.getLabel()));   
                        } else if(!String.isEmpty(familiar.Tipo_discapacidad__c) && familiar.Tipo_discapacidad__c.contains(t.getValue())){
                            discapacidadFamiliarSelec.add(new SelectOption(t.getValue(),t.getLabel()));   
                        } 
                    }
                    discapacidadFamiliarDisp = new List<SelectOption>();
                    discapacidadFamiliarDisp = temporal;
                    break;
                }
            } 
        }
        //se comenta estas lineas puesto que no son necesarias y genera conflicto el id con el security review
        /*else {
//familiar = new SST_grupo_familiar__c();
familiar.id = null;
}*/
    }
    
    //Método para persistir en el controlador los datos de los miembros del grupo familiar
    public void agregarFamiliar(){
        if(Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_inicio_beneficio__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_final_beneficio__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_Nacimiento__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.depende_economicamente__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.discapacidad__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.programa_gubernamental__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.Tipo_discapacidad__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.Numero_Identificacion__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.Representante_legal__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.trabajo__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.Escolaridad__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.funcionario__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.parentesco__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.tipo_documento__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.nombre_completo__c.isUpdateable()&&
           Schema.SObjectType.SST_grupo_familiar__c.fields.genero__c.isUpdateable()){
               mensajesModal = new List<SST_MensajesPagina>();
               if(familiar.Discapacidad__c.equals('SI') && discapacidadFamiliarSelec.size()==0){
                   mensajesModal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Si su familiar padece de discapacidad, indique de qué tipo'));
               } else if(familiar.Discapacidad__c.equals('NO') && discapacidadFamiliarSelec.size()>0){
                   mensajesModal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Si su familiar no padece de discapacidad, no seleccione ningún tipo'));
               } else {
                   if(String.isEmpty(identifFamiliar)){
                       for(SST_grupo_familiar__c ttmp : listaFamiliares){
                           if(ttmp.Numero_Identificacion__c.equalsIgnoreCase(familiar.Numero_Identificacion__c)){
                               mensajesModal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ya tiene un familiar registrado con el número de identificación '+familiar.Numero_Identificacion__c));
                               familiar.Numero_Identificacion__c = identifFamiliar;
                           } 
                       }  
                   }
                   else if(!String.isEmpty(identifFamiliar) && !identifFamiliar.equalsIgnoreCase(familiar.Numero_Identificacion__c)){
                       Integer countI = 0;
                       for(SST_grupo_familiar__c ttmp : listaFamiliares){
                           if(ttmp.Numero_Identificacion__c.equalsIgnoreCase(familiar.Numero_Identificacion__c)){
                               countI ++;
                           } 
                       } 
                       if(countI == 2){
                           mensajesModal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ya tiene un familiar registrado con el número de identificación '+familiar.Numero_Identificacion__c));
                           familiar.Numero_Identificacion__c = identifFamiliar;  
                       }
                   }
                   if(!inicioBeneficioFamiliar.equals('') && !finBeneficioFamiliar.equals('') && finBeneficioFamiliar < inicioBeneficioFamiliar){
                       mensajesModal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'La fecha de fin del beneficio debe ser mayor a la fecha de inicio'));
                   }
                   if(mensajesModal.size()==0){  
                       String[] FN = fechaNacFamiliar.split('/');
                       familiar.Fecha_Nacimiento__c = Date.valueOf(FN[2]+'-'+FN[1]+'-'+FN[0]);
                       if(familiarDependiente.equals('SI')){
                           familiar.Depende_economicamente__c = true;
                       } else {
                           familiar.Depende_economicamente__c = false;
                       }
                       if(!String.isEmpty(inicioBeneficioFamiliar)){
                           String[] FI = inicioBeneficioFamiliar.split('/');
                           familiar.Fecha_inicio_beneficio__c = Date.valueOf(FI[2]+'-'+FI[1]+'-'+FI[0]);
                       }
                       if(!String.isEmpty(finBeneficioFamiliar)){
                           String[] FF = finBeneficioFamiliar.split('/');
                           if(FF[0].isNumeric() && FF[1].isNumeric() && FF[2].isNumeric()){
                               familiar.Fecha_final_beneficio__c = Date.valueOf(FF[2]+'-'+FF[1]+'-'+FF[0]);    
                           }
                       }
                       if(discapacidadFamiliarSelec.size()>0){
                           familiar.Tipo_Discapacidad__c = '';
                           for(selectOption t : discapacidadFamiliarSelec){
                               familiar.Tipo_Discapacidad__c = familiar.Tipo_Discapacidad__c + t.getValue()+';';    
                           }
                           familiar.Tipo_Discapacidad__c.removeEnd(';');
                       }
                       if(familiar.discapacidad__c.equals('NO')){
                           if(familiar.Representante_legal__c == SST_Constantes.ITEM_VACIO_PICKLIST){
                               familiar.Representante_legal__c = '';
                           }
                           if(familiar.trabajo__c == SST_Constantes.ITEM_VACIO_PICKLIST){
                               familiar.trabajo__c = '';
                           }
                           if(familiar.Escolaridad__c == SST_Constantes.ITEM_VACIO_PICKLIST){
                               familiar.Escolaridad__c = '';
                           }
                       }
                       if(String.isEmpty(nombreFamiliar) && String.isEmpty(identifFamiliar)){                
                           familiar.funcionario__c = contacto.codigo;
                           //se comenta este id puesto que cuando se creo no lo tenía, y genera conflicto con el security review dejarlo
                           //familiar.id = null;
                           listaFamiliares.add(familiar); 
                           contacto.tieneFamiliares = 'SI';
                       } 
                   }
               }
           }else{
               mensajesModal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para agregar familiares'));
           }
    }
    
    //Método para remover de la lista un miembro del grupo familiar
    public void removerFamiliar(){ 
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        List<SST_grupo_familiar__c> temporal = listaFamiliares;
        List<String> idGrupoFamiliarRemover = new List<String>();
        for(Integer i = 0; i<=temporal.size()-1; i++){
            SST_grupo_familiar__c ttmp = temporal.get(i);
            if(ttmp.Nombre_completo__c.equalsIgnoreCase(nombreFamiliar) && ttmp.Numero_Identificacion__c.equalsIgnoreCase(identifFamiliar)){
                listaFamiliares.remove(i);
                if(!String.isEmpty(ttmp.id)){
                    idGrupoFamiliarRemover.add(idFamiliar);
                }
                break; 
            }
        }
        for(SST_grupo_familiar__c grupoFamiliar : [SELECT id FROM SST_grupo_familiar__c WHERE id in :idGrupoFamiliarRemover]){
            familiaresParaRemover.add(grupoFamiliar);   
        }
        
    }
    
    //Método para guardar los datos de la encuesta
    public void guardar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        try{
            if(Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.name.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.funcionario__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Extemporaneo__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.consentimiento__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Encuesta_Sociodemografica__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Datos_modificados__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.empresa__c.isCreateable() && 
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.name.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.funcionario__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Extemporaneo__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.consentimiento__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Encuesta_Sociodemografica__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Datos_modificados__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.empresa__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Discapacidad_certificada__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Actividades__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.LGTBI__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Origen_discapacidad__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Tipo_discapacidad__c.isCreateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Discapacidad_certificada__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Actividades__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.LGTBI__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Origen_discapacidad__c.isUpdateable()&&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Tipo_discapacidad__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.discapacidad__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Porcentaje_discapacidad__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Tratamiento_discapacidad__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Tipo_vivienda__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Fuma__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Consume_licor__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Deporte__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Cabeza_de_hogar__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Personas_a_cargo__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Antiguedad__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Antiguedad_cargo__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.experiencia__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Grupo_sindical__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Ingresos__c.isCreateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.discapacidad__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Porcentaje_discapacidad__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Tratamiento_discapacidad__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Tipo_vivienda__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Fuma__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Consume_licor__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Deporte__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Cabeza_de_hogar__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Personas_a_cargo__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Antiguedad__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Antiguedad_cargo__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.experiencia__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Grupo_sindical__c.isUpdateable() &&
               Schema.sObjectType.SST_Informacion_sociodemografica__c.fields.Ingresos__c.isUpdateable() &&
               Schema.sObjectType.Contact.fields.SST_Etnia__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_inicio_beneficio__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_final_beneficio__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_Nacimiento__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.depende_economicamente__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.discapacidad__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.programa_gubernamental__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Tipo_discapacidad__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Numero_Identificacion__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Representante_legal__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.trabajo__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Escolaridad__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.funcionario__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.parentesco__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.tipo_documento__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.nombre_completo__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.genero__c.isUpdateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_inicio_beneficio__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_final_beneficio__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Fecha_Nacimiento__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.depende_economicamente__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.discapacidad__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.programa_gubernamental__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Tipo_discapacidad__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Numero_Identificacion__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Representante_legal__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.trabajo__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.Escolaridad__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.funcionario__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.parentesco__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.tipo_documento__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.nombre_completo__c.isCreateable()&&
               Schema.SObjectType.SST_grupo_familiar__c.fields.genero__c.isCreateable()&& 
               Schema.SObjectType.SST_grupo_familiar__c.isDeletable()){
                   if(infoContacto.Consentimiento__c.equals('NO')){
                       SST_Informacion_sociodemografica__c infoContactoNO;
                       if(infoContacto.id != null){
                           infoContactoNO = [SELECT id FROM SST_Informacion_sociodemografica__c WHERE id =:infoContacto.id];
                       }else{
                           infoContactoNO = new SST_Informacion_sociodemografica__c();
                       }
                       infoContactoNo.name = SST_Constantes.INFO_SOCIODEMOGRAFICA_VIGENTE;
                       infoContactoNO.funcionario__c = infoContacto.funcionario__c;
                       infoContactoNO.Extemporaneo__c = infoContacto.Extemporaneo__c;
                       infoContactoNO.consentimiento__c = infoContacto.consentimiento__c;
                       infoContactoNO.Encuesta_sociodemografica__c = idEncuesta;
                       infoContactoNO.Datos_modificados__c = '';
                       infoContactoNO.empresa__c = contactoTemp.sst_empresa__c;
                       upsert infoContactoNO;
                   } else if(infoContacto.Consentimiento__c.equals('SI')){
                       List <String> datosModificadosTemp = new List <String>();
                       if (!contacto.nombre.equalsIgnoreCase(contactoTemp.name)){
                           datosModificadosTemp.add('Nombre correcto: '+contacto.nombre);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Nombre: '+contacto.nombre+'; ';
                       }
                       if (contactoTemp.SST_Tipo_Identificacion__c == null || !contacto.tipoIdentificacion.equalsIgnoreCase(contactoTemp.SST_Tipo_Identificacion__c)){
                           datosModificadosTemp.add('Tipo identificación correcto: '+MapaTipoDoc.get(contacto.tipoIdentificacion));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Tipo identificación: '+contacto.tipoIdentificacion+'; ';
                       }
                       if (contactoTemp.SST_Identificacion__c == null || !contacto.identificacion.equalsIgnoreCase(contactoTemp.SST_Identificacion__c)){
                           datosModificadosTemp.add('Número identificación correcto: '+contacto.identificacion);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Identificación: '+contacto.identificacion+'; ';
                       }
                       if (contactoTemp.birthdate == null || contacto.fechaNacimiento <> contactoTemp.birthdate){
                           datosModificadosTemp.add('Fecha nacimiento correcta: '+String.valueOf(contacto.fechaNacimiento));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Fecha nacimiento: '+String.valueOf(contacto.fechaNacimiento)+'; ';
                       }
                       if (contactoTemp.SST_genero__c == null || !contacto.genero.equalsIgnoreCase(contactoTemp.SST_genero__c)){
                           datosModificadosTemp.add('Género correcto: '+contacto.genero);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Género: '+contacto.genero+'; ';
                       }
                       if (contactoTemp.SST_estado_civil__c == null || !contacto.estadoCivil.equalsIgnoreCase(contactoTemp.SST_estado_civil__c)){
                           datosModificadosTemp.add('Estado civil correcto: '+MapaEstadoCivil.get(contacto.estadoCivil));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Estado civil: '+contacto.estadoCivil+'; ';
                       }
                       if (contactoTemp.SST_Nivel_Escolaridad__c == null || !contacto.Escolaridad.equalsIgnoreCase(contactoTemp.SST_Nivel_Escolaridad__c)){
                           datosModificadosTemp.add('Nivel escolaridad correcto: '+MapaEscolaridad.get(contacto.Escolaridad));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Escolaridad: '+contacto.Escolaridad+'; ';
                       }
                       if (contactoTemp.SST_estrato__c == null || !contacto.estrato.equalsIgnoreCase(contactoTemp.SST_estrato__c)){
                           datosModificadosTemp.add('Estrato correcto: '+contacto.estrato);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Estrato: '+contacto.estrato+'; ';
                       }
                       if (contactoTemp.SST_barrio__c == null || !contacto.barrio.equalsIgnoreCase(contactoTemp.SST_barrio__c)){
                           datosModificadosTemp.add('Barrio correcto: '+contacto.barrio);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Barrio: '+contacto.barrio+'; ';
                       }
                       if (contactoTemp.SST_direccion__c == null || !contacto.direccion.equalsIgnoreCase(contactoTemp.SST_direccion__c)){
                           datosModificadosTemp.add('Dirección correcta: '+contacto.direccion);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Dirección: '+contacto.direccion+'; ';
                       }
                       if (contactoTemp.phone == null || !contacto.telefono.equalsIgnoreCase(contactoTemp.phone)){
                           datosModificadosTemp.add('Número teléfono correcto: '+contacto.telefono);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Teléfono: '+contacto.telefono+'; ';
                       }
                       if (contactoTemp.MobilePhone == null || !contacto.celular.equalsIgnoreCase(contactoTemp.MobilePhone)){
                           datosModificadosTemp.add('Número celular correcto: '+contacto.celular);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Celular: '+contacto.celular+'; ';
                       }
                       if (contactoTemp.SST_Departamento__c == null || !contacto.departamento.equalsIgnoreCase(contactoTemp.SST_Departamento__c)){
                           datosModificadosTemp.add('Departamento correcto: '+MapaDepartamento.get(contacto.departamento));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Departamento: '+contacto.departamento+'; ';
                       }
                       if (contactoTemp.SST_Municipio__c == null || !contacto.municipio.equalsIgnoreCase(contactoTemp.SST_Municipio__c)){
                           datosModificadosTemp.add('Municipio correcto: '+MapaMunic.get(contacto.municipio));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Municipio: '+contacto.municipio+'; ';
                       }
                       if (contactoTemp.SST_Tipo_Contrato__c == null || !contacto.tipoContrato.equalsIgnoreCase(contactoTemp.SST_Tipo_Contrato__c)){
                           datosModificadosTemp.add('Tipo contrato correcto: '+MapaTipoContrato.get(contacto.tipoContrato));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Tipo contrato: '+contacto.tipoContrato+'; ';
                       }
                       String cargo1 = contactoTemp.SST_Cargo__r.name;
                       String cargo2 = contacto.cargo;
                       if(cargo1!= null && cargo1.contains(' ')){
                           cargo1 = cargo1.replaceAll(' ','');
                       }
                       if(cargo2.contains(' ')){
                           cargo2 = cargo2.replaceAll(' ','');
                       }
                       if (contactoTemp.SST_Cargo__c == null || !cargo1.equalsIgnoreCase(cargo2)){
                           datosModificadosTemp.add('Cargo correcto: '+contacto.cargo);
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Cargo: '+contacto.cargo+'; ';
                       }
                       if (contactoTemp.SST_Sede__c == null || !contacto.sede.equals(contactoTemp.SST_Sede__c)){
                           datosModificadosTemp.add('Sede correcta: '+MapaSede.get(contacto.sede));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Sede: '+MapaSede.get(contacto.sede)+'; ';
                       }
                       if (contactoTemp.SST_Area_Trabajo__c == null || !contacto.area.equals(contactoTemp.SST_Area_Trabajo__c)){
                           datosModificadosTemp.add('Área o dependencia correcta: '+MapaArea.get(contacto.area));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Área o dependen: '+MapaArea.get(contacto.area)+'; ';
                       }
                       if (contactoTemp.SST_EPS__c == null || !contacto.eps.equals(contactoTemp.SST_EPS__c)){
                           datosModificadosTemp.add('EPS correcta: '+MapaEPS.get(contacto.eps));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'EPS: '+MapaEPS.get(contacto.eps)+'; ';
                       }
                       if (contactoTemp.SST_Fondo_Pensiones__c == null || !contacto.fondoPensiones.equals(contactoTemp.SST_Fondo_Pensiones__c)){
                           datosModificadosTemp.add('Fondo Pensiones correcto: '+MapaAFP.get(contacto.fondoPensiones));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Fondo pensiones: '+MapaAFP.get(contacto.fondoPensiones)+'; ';
                       }
                       if (contactoTemp.SST_Fondo_Cesantias__c == null || !contacto.fondoCesantias.equals(contactoTemp.SST_Fondo_Cesantias__c)){
                           datosModificadosTemp.add('Fondo Cesantías correcto: '+MapaAFP.get(contacto.fondoCesantias));
                           infoContacto.Datos_modificados__c = infoContacto.Datos_modificados__c + 'Fondo cesantías: '+MapaAFP.get(contacto.fondoCesantias)+'; ';
                       }
                       if(infoContacto.Tratamiento_discapacidad__c.equals(SST_Constantes.ITEM_VACIO_PICKLIST)){
                           infoContacto.Tratamiento_discapacidad__c = '';
                       }
                       if(infoContacto.Discapacidad_certificada__c.equals(SST_Constantes.ITEM_VACIO_PICKLIST)){
                           infoContacto.Discapacidad_certificada__c = '';
                       }
                       infoContacto.Actividades__c = '';
                       for(SelectOption temp : actividadesBienestarSeleccionados){
                           infoContacto.Actividades__c = infoContacto.Actividades__c+temp.getValue()+';';
                       }
                       infoContacto.Actividades__c.removeEnd(';');
                       if(infoContacto.LGTBI__c.equals(SST_Constantes.ITEM_VACIO_PICKLIST)){
                           infoContacto.LGTBI__c = '';
                       }
                       infoContacto.Origen_discapacidad__c = '';
                       if(origenesDiscapacidadSeleccionados.size()>0){
                           for(SelectOption temp : origenesDiscapacidadSeleccionados){
                               infoContacto.Origen_discapacidad__c = infoContacto.Origen_discapacidad__c+temp.getValue()+';';
                           }
                           infoContacto.Origen_discapacidad__c.removeEnd(';');
                       }
                       infoContacto.Tipo_discapacidad__c = '';
                       if(tiposDiscapacidadSeleccionados.size()>0){
                           for(SelectOption temp : tiposDiscapacidadSeleccionados){
                               infoContacto.Tipo_discapacidad__c = infoContacto.Tipo_discapacidad__c+temp.getValue()+';';
                           }
                           infoContacto.Tipo_discapacidad__c.removeEnd(';');
                       }
                       if (contactoTemp.SST_Etnia__c == null || !contacto.etnia.equalsIgnoreCase(contactoTemp.SST_Etnia__c)){
                           contactoTemp.SST_Etnia__c = contacto.etnia;
                           update contactoTemp;
                       }
                       if(datosModificadosTemp.size()>0){
                           datosModificados.add('El funcionario ha solicitado actualizar la siguiente información personal y/o laboral:');
                           datosModificados.addAll(datosModificadosTemp);
                           datosModificadosTemp = new list<String>();
                       }
                       if(listaFamiliares.size()>0){
                           List<id> idGrupo = new List<id>();
                           List<SST_Grupo_familiar__c> familiares = new List<SST_Grupo_familiar__c>();
                           for(SST_Grupo_familiar__c grupoFamiliar  :listaFamiliares){
                               if(grupoFamiliar.id!=null){
                                   idGrupo.add(grupoFamiliar.id);
                               }else{
                                   familiares.add(copiarGrupoFamiliar(grupoFamiliar, null));
                               }
                           }
                           for(SST_Grupo_familiar__c grupoFamiliar : [SELECT id FROM SST_Grupo_familiar__c WHERE id in :idGrupo]){
                               familiares.add(copiarGrupoFamiliar(grupoFamiliar, grupoFamiliar));
                           }
                           upsert familiares;
                       }
                       if(familiaresParaRemover.size()>0){
                           delete familiaresParaRemover;
                       }
                       upsert infoContacto;
                   }  
                   if(datosModificados.size()>0){
                       EnviarNotificacion(datosModificados, contactoTemp.name, contactoTemp.SST_Identificacion__c);
                   }
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'Los datos se han almacenado exitosamente.  Gracias por su participación.'));
                   mostrarSeccion = true;
                   mostrarSubseccion1 = true;
                   mostrarSubseccion2 = false;
                   mostrarSubseccion3 = false;
                   mostrarSeccion1 = false;
                   mostrarSeccion2 = false;
                   mostrarSeccion3 = false;
                   mostrarSeccion4 = false;
                   mostrarSeccion5 = false;
                   inicializarVariables();
               }
        } catch (DmlException e) {
            system.debug('Mensaje error:'+e.getMessage());
            system.debug('Linea error:'+e.getLineNumber());
            system.debug('Causa error:'+e.getCause());
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ha ocurrido un error, por favor intente nuevamente')); 
        }
    }
    /*Método que se encarga de copiar los datos del grupo familiar*/
    private SST_Grupo_Familiar__c copiarGrupoFamiliar(SST_Grupo_Familiar__c grupoFamiliar,SST_Grupo_Familiar__c grupoFamiliarCopiado){
        if(grupoFamiliarCopiado == null){
            grupoFamiliarCopiado = new SST_Grupo_Familiar__c();
        }
        grupoFamiliarCopiado.Fecha_inicio_beneficio__c =grupoFamiliar.Fecha_inicio_beneficio__c;
        grupoFamiliarCopiado.Fecha_final_beneficio__c =grupoFamiliar.Fecha_final_beneficio__c;
        grupoFamiliarCopiado.Fecha_Nacimiento__c= grupoFamiliar.Fecha_Nacimiento__c;
        grupoFamiliarCopiado.depende_economicamente__c=grupoFamiliar.depende_economicamente__c;
        grupoFamiliarCopiado.discapacidad__c =grupoFamiliar.discapacidad__c;
        grupoFamiliarCopiado.programa_gubernamental__c=grupoFamiliar.programa_gubernamental__c;
        if(grupoFamiliar.Tipo_discapacidad__c!= null){
            grupoFamiliarCopiado.Tipo_discapacidad__c=grupoFamiliar.Tipo_discapacidad__c;
        }
        grupoFamiliarCopiado.Numero_Identificacion__c=grupoFamiliar.Numero_Identificacion__c;
        grupoFamiliarCopiado.Representante_legal__c=grupoFamiliar.Representante_legal__c;
        grupoFamiliarCopiado.trabajo__c=grupoFamiliar.trabajo__c;
        grupoFamiliarCopiado.Escolaridad__c=grupoFamiliar.Escolaridad__c;
        grupoFamiliarCopiado.funcionario__c=grupoFamiliar.funcionario__c;
        grupoFamiliarCopiado.parentesco__c=grupoFamiliar.parentesco__c;
        grupoFamiliarCopiado.tipo_documento__c=grupoFamiliar.tipo_documento__c;
        grupoFamiliarCopiado.nombre_completo__c=grupoFamiliar.nombre_completo__c;
        grupoFamiliarCopiado.genero__c=grupoFamiliar.genero__c;
        return grupoFamiliarCopiado;
    }
    //Método para inicializar las variables al volver a la pantalla de inicio
    public pageReference cancelar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        contacto = new DTOContacto();
        return null;
    }
    
    //Método para habilitar el input select para cambiar el departamento de residencia
    public void habilitarDepartamento(){
        soloLecturaDepartamento = soloLecturaDepartamento = false;
        contacto.municipio = SST_Constantes.ITEM_VACIO_PICKLIST;
    }
    
    public void recargar(){
        contacto.departamento = contacto.departamento;
    }
    
    //Método que retorna un select list con las opciones del tipo de documento de identificación
    public List<SelectOption> getTipoDoc(){
        List<SelectOption> tipoDoc = new List<SelectOption>();
        tipoDoc.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        MapaTipoDoc.put(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST);
        Schema.DescribeFieldResult fieldResult = Contact.SST_tipo_identificacion__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            if(!temp.getValue().contains('N') && !temp.getValue().contains('D') && !temp.getValue().contains('F')){
                tipoDoc.add(new SelectOption(temp.getValue(),temp.getLabel()));
                MapaTipoDoc.put(temp.getValue(),temp.getLabel());
            }
        }
        return tipoDoc;
    }
    
    //Método que retorna un select list con las opciones de estado civil
    public List<SelectOption> getEstadoCivil(){
        List<SelectOption> estadoCivil = new List<SelectOption>();
        estadoCivil.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        MapaEstadoCivil.put(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST);
        Schema.DescribeFieldResult fieldResult = Contact.SST_estado_civil__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            estadoCivil.add(new SelectOption(temp.getValue(),temp.getLabel()));
            MapaEstadoCivil.put(temp.getValue(),temp.getLabel());
        }
        return estadoCivil;
    }
    
    //Método que retorna un select list con las opciones de nivel de escolaridad
    public List<SelectOption> getEscolaridad(){
        List<SelectOption> escolaridad = new List<SelectOption>();
        escolaridad.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        MapaEscolaridad.put(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST);
        Schema.DescribeFieldResult fieldResult = Contact.SST_Nivel_Escolaridad__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            escolaridad.add(new SelectOption(temp.getValue(),temp.getLabel()));
            MapaEscolaridad.put(temp.getValue(),temp.getLabel());
        }
        return escolaridad;
    }
    
    //Método que retorna un select list con las opciones de grupo étnico    
    public List<SelectOption> getEtnia(){
        List<SelectOption> etnia = new List<SelectOption>();
        etnia.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        Schema.DescribeFieldResult fieldResult = Contact.SST_Etnia__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            etnia.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return etnia;
    }
    
    //Método que retorna un select list con las opciones de tipo de vivienda
    public List<SelectOption> getTipoVivienda(){
        List<SelectOption> tipoVivienda = new List<SelectOption>();
        tipoVivienda.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        Schema.DescribeFieldResult fieldResult = SST_Informacion_sociodemografica__c.tipo_vivienda__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            tipoVivienda.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return tipoVivienda;
    }
    
    //Método que retorna un select list con las opciones departamento
    public List<SelectOption> getDepartamento(){
        List<SelectOption> departamento = new List<SelectOption>();
        departamento.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        MapaDepartamento.put(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST);
        Schema.DescribeFieldResult fieldResult = Contact.SST_departamento__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            departamento.add(new SelectOption(temp.getValue(),temp.getLabel()));
            MapaDepartamento.put(temp.getValue(),temp.getLabel());
        }
        return departamento;
    }
    
    //Método que retorna un select list con las opciones de municipio
    Map<String,String> getMunicipio(){
        MapaMunic.put(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST);
        Schema.DescribeFieldResult fieldResult = Contact.SST_municipio__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            MapaMunic.put(temp.getValue(),temp.getLabel());
        }
        return MapaMunic;
    }
    
    //Método que retorna un select list con las opciones de estrato socioneconómico
    public List<SelectOption> getEstrato(){
        List<SelectOption> estrato = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.SST_estrato__c.getDescribe();
        estrato.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            estrato.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return estrato;
    }
    
    //Método que retorna un select list con las opciones de tipo de contrato
    public List<SelectOption> getTipoContrato(){
        List<SelectOption> tipoContrato = new List<SelectOption>();
        tipoContrato.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        MapaTipoContrato.put(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST);
        Schema.DescribeFieldResult fieldResult = Contact.SST_Tipo_Contrato__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            tipoContrato.add(new SelectOption(temp.getValue(),temp.getLabel()));
            MapaTipoContrato.put(temp.getValue(),temp.getLabel());
        }
        return tipoContrato;
    }
    
    //Método que retorna un select list con las opciones de periodicidad Fuma
    public List<SelectOption> getPeriodicidadFuma(){
        List<SelectOption> periodicidadFuma = new List<SelectOption>();
        periodicidadFuma.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        Schema.DescribeFieldResult fieldResult = SST_Informacion_sociodemografica__c.fuma__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            periodicidadFuma.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return periodicidadFuma;
    }
    
    //Método que retorna un select list con las opciones de periodicidad Consume licor y Practica deporte
    public List<SelectOption> getPeriodicidad(){
        List<SelectOption> periodicidad = new List<SelectOption>();
        periodicidad.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        Schema.DescribeFieldResult fieldResult = SST_Informacion_sociodemografica__c.consume_licor__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            periodicidad.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return periodicidad;
    }
    
    //Método que retorna un select list con las opciones del número de personas a cargo
    public List<SelectOption> getPsnasACargo(){
        List<SelectOption> psnasACargo = new List<SelectOption>();
        psnasACargo.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        Schema.DescribeFieldResult fieldResult = SST_Informacion_sociodemografica__c.Personas_a_cargo__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            psnasACargo.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return psnasACargo;
    }
    
    //Método que retorna un select list con las opciones de EPS
    public List<SelectOption> getEps(){
        List<SelectOption> eps = new List<SelectOption>();
        eps.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        MapaEPS.put(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST);
        Schema.DescribeFieldResult fieldResult = Contact.SST_EPS__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            eps.add(new SelectOption(temp.getValue(),temp.getLabel()));
            MapaEPS.put(temp.getValue(),temp.getLabel());
        }
        return eps;
    }
    
    //Método que retorna un select list con las opciones de fondos de pensiones y cesantías
    public List<SelectOption> getAfp(){
        List<SelectOption> afp = new List<SelectOption>();
        afp.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        MapaAFP.put(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST);
        Schema.DescribeFieldResult fieldResult = Contact.SST_Fondo_Pensiones__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            afp.add(new SelectOption(temp.getValue(),temp.getLabel()));
            MapaAFP.put(temp.getValue(),temp.getLabel());
        }
        return afp;
    }
    
    //Método que retorna un select list con las opciones de antigüedad para el cargo actual y en la empresa
    public List<SelectOption> getAntiguedad(){
        List<SelectOption> antiguedad = new List<SelectOption>();
        antiguedad.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        Schema.DescribeFieldResult fieldResult = SST_Informacion_sociodemografica__c.Antiguedad__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            antiguedad.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return antiguedad;
    } 
    
    //Método que retorna un select list con las opciones de promedio de ingresos mensuales
    public List<SelectOption> getIngresos(){
        List<SelectOption> ingresos = new List<SelectOption>();
        ingresos.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        Schema.DescribeFieldResult fieldResult = SST_Informacion_sociodemografica__c.Ingresos__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            ingresos.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return ingresos;
    }
    
    //Método que retorna un select list con las opciones de parentescos
    public List<SelectOption> getParentesco(){
        List<SelectOption> parentesco = new List<SelectOption>();
        parentesco.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        Schema.DescribeFieldResult fieldResult = SST_Grupo_familiar__c.Parentesco__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            parentesco.add(new SelectOption(temp.getValue(),temp.getValue()));
        }
        return parentesco;
    } 
    
    //Método que retorna un Mapa cuyas llaves son los departamento, y los value son select list con los municipios correspondientes
    public static Map<String, List<SelectOption>> getMunicipios(){
        Map<String, List<SelectOption>> MapaMunicipios = new Map<String, List<SelectOption>>();      
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Contact');
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        String departamento = '';
        String municipio = '';
        for(String key : fieldMap.keySet()){
            if(key.contains('sst_departamento')){
                departamento = key;        
            }
            if(key.contains('sst_municipio')){
                municipio = key;        
            }
        }
        
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(departamento).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(municipio).getDescribe();
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues){
            List<SelectOption> listaMunicipio = new List<SelectOption>();
            listaMunicipio.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
            MapaMunicipios.put(currControllingValue.getValue(), listaMunicipio);
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues){
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars()){
                Integer val = 0;
                if(curr >= 65){
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }
                if((val & 8) == 8){
                    MapaMunicipios.get(controllingValues[baseCount + 0].getValue()).add(new SelectOption(currDependentValue.getValue(),currDependentValue.getLabel()));
                }
                if((val & 4) == 4){
                    MapaMunicipios.get(controllingValues[baseCount + 1].getValue()).add(new SelectOption(currDependentValue.getValue(),currDependentValue.getLabel()));                    
                }
                if((val & 2) == 2){
                    MapaMunicipios.get(controllingValues[baseCount + 2].getValue()).add(new SelectOption(currDependentValue.getValue(),currDependentValue.getLabel()));                    
                }
                if((val & 1) == 1){
                    MapaMunicipios.get(controllingValues[baseCount + 3].getValue()).add(new SelectOption(currDependentValue.getValue(),currDependentValue.getLabel()));                    
                }
                baseCount += 4;
            }            
        } 
        return MapaMunicipios;
    }
    
    //Inner Class para el método getMunicipios
    class MyPickListInfo{
        public String validFor;
    } 
    
    //Método que envía el correo de notificación sobre las novedades en el diligenciamiento de la encuesta
    private void EnviarNotificacion(List <String> datosModificados, String nombre, String identificacion){
        String correo = SST_Constantes.consultarDatosEmpresa(contactoTemp.sst_empresa__c).SST_Correo_nomina__c;
        List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Novedades en el diligenciamiento de la Encuesta Sociodemográfica número '+consecutivoEncuesta);
        mail.setHtmlBody(mensajeCuerpoCorreo(datosModificados, nombre, identificacion));
        List<String> emailAddressList = new List<String>();
        if(!String.isEmpty(correo)){
            emailAddressList.add(correo);    
            mail.setToAddresses(emailAddressList);
        } else {
            for(User usuario: SST_Constantes.returnUserList()){
                if(!String.isEmpty(usuario.email) || !String.isBlank(usuario.email)){
                    emailAddressList.add(usuario.email);
                }
            }
            mail.setToAddresses(emailAddressList);
        }
        mailsList.add(mail);
        List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
    }
    
    //Método que retorna el contenido del correo de notificación sobre las novedades en el diligenciamiento de la encuesta
    private String mensajeCuerpoCorreo(List <String> datosModificados, String nombre, String identificacion){
        String campos = '<br />';
        for(String datos: datosModificados){
            campos = campos+datos+'<br /><br />';
        }
        String cuerpoMensajes='';
        cuerpoMensajes= '<p>Cordial saludo,</p><br /><p>El &aacute;rea de seguridad y salud en el trabajo se permite informarle que el d&iacute;a de hoy se han presentado las siguientes novedades en el diligenciamiento de la encuesta sociodemogr&aacute;fica por parte del funcionario '+nombre+' con n&uacute;mero de identificaci&oacute;n '+identificacion+' : </p>';
        cuerpoMensajes = cuerpoMensajes+campos+' <p>No olvide gestionar la actualización de datos que el funcionario haya reportado, si aplica.</p><br />';
        cuerpoMensajes = cuerpoMensajes+'<p>Cordialmente, </p><br /><p>'+nombreEmpresa+'</p><br />';
        return cuerpoMensajes;
    } 

    
    //Inner Class para mostrar en pantalla los datos del contacto que se obtienen del objeto Contact
    public class DTOContacto {
        public String identificacion {get;set;}
        public String codigo {get;set;}
        public String tipoIdentificacion {get;set;}
        public String nombre {get;set;}
        public Date fechaNacimiento {get;set;}
        public String genero {get;set;}
        public String estadoCivil {get;set;}
        public String escolaridad {get;set;}
        public String etnia {get;set;}
        public String barrio {get;set;}
        public String direccion {get;set;}
        public String telefono {get;set;}
        public String celular {get;set;}
        public String departamento {get;set;}
        public String municipio {get;set;}
        public String estrato {get;set;}
        public String tipoContrato {get;set;}
        public String cargo {get;set;}
        public String sede {get;set;}
        public String area {get;set;}
        public String eps {get;set;}
        public String fondoPensiones {get;set;}
        public String fondoCesantias {get;set;}
        public String arl {get;set;}
        public String tieneFamiliares {get;set;}
    }
    
}