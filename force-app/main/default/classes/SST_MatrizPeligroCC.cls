/*
* Clase que se encarga de gestionar la matriz de peligros de una empresa.
* @autor: Angélica Toro
* @fecha: 27/08/2018
* @version: 1.0
*/
public with sharing class SST_MatrizPeligroCC {
    
    /*Mapa para mostrar los peligros que serán evaluados en la página*/
    public Map<String,List<PeligroDTO>> peligros {get;set;}
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en el modal*/
    public List<SST_MensajesPagina> mensajesModal {get;set;}
    
    /*Objeto seleccionado para evualar*/
    public PeligroDTO peligroSeleccionado {get; set;}
    
    /*Listas para el manejo de multiselect del EPP*/
    public List<SelectOption> leftEPPValues {get;set;}
    public List<SelectOption> rightEPPValues {get;set;}
    
    /*Listas para el manejo de multiselect de normatividades*/
    public List<SelectOption> leftLegalValues {get;set;}
    public List<SelectOption> rightLegalValues {get;set;}
    
    /*Lista para los contactos expuestos*/
    public List<Contact> expuestos {get;set;}
    
    /*Filtro del área*/
    public String area {get; set;}
    
    /*Filtro del proceso*/
    public String proceso {get; set;}
    
    /*Filtro de la sede*/
    public String sede{get; set;}
    
    /*Filtro de la aceptabilidad*/
    public String aceptabilidad{get; set;}
    
    /*Lista con los valores de los estados seleccionados para la busqueda*/
    public List<String> estadosSeleccionados {get; set;}
    
    /*Variable que contiene el id del reporte de la matriz de peligro*/
    public String idReporte {get; set;}
    
    /*Variable con el valor de la url actual*/
    String url;
    
    /*Nombres del label tipo de clasificación*/
    Map<String,String> labelTipoClasificacion = new Map<String,String>();
    
    /*Nombres del label clasificación*/
    Map<String,String> labelClasificacion = new Map<String,String>();
    
    /*Variables con las ayudas de los niveles de deficiencia, exposición, probabilidad y consecuencia*/
    public String ayudaNivelDeficiencia {get; set;}
    public String ayudaNivelExposicion {get; set;}
    public String ayudaNivelProbabilidad {get; set;}
    public String ayudaNivelConsecuencia {get; set;}
    
    /*Variables para el manejo de la paginacion*/
    public Integer offSet{get;set;}
    public Integer total{get;set;}
    public Integer paginas{get;set;}
    public Integer paginaActual{get;set;}
    
    String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
    
    /*Método constructor*/
    public SST_MatrizPeligroCC(){
        
        offSet = 0;
        paginaActual = 1;
        peligroSeleccionado = new PeligroDTO();
        try{
            mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
            mensajesModal= new List<SST_MensajesPagina>();
            estadosSeleccionados = new List<String>{SST_constantes.ESTADO_IDENTIFICADO,SST_constantes.ESTADO_EVALUADO,SST_constantes.ESTADO_CONTROLES_ESTABLECIDOS};
                obtenerValoresPicklist();
            url = ApexPages.currentPage().getHeaders().get('Referer');
            consultarPeligros();
            consultarReporte();
            
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error construyendo el objeto, por favor contacte al administrador'));
            System.debug('Error en SST_MatrizPeligroCC() Linea:'+e.getLineNumber()+' - '+e.getMessage());
            
        }
    }
    /*Método encargado de obtener los valores de los picklist de tipo de clasificacion */
    private void obtenerValoresPicklist(){
        Schema.DescribeFieldResult campo = SST_peligro__c.tipo_clasificacion__c.getDescribe();
        List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
        for( Schema.PicklistEntry pickItem : picklist){
            labelTipoClasificacion.put(pickItem.getValue(),pickItem.getLabel());
        }    
        
        campo = SST_peligro__c.Clasificacion_peligro__c.getDescribe();
        picklist = campo.getPicklistValues();
        for( Schema.PicklistEntry pickItem : picklist){
            labelClasificacion.put(pickItem.getValue(),pickItem.getLabel());
        }   
        
    }
    
    /*Método encargado de consultar el reporte de los peligros*/
    private void consultarReporte(){
        try{
            Integer cantidadEmpresa = SST_Constantes.getCantidadEmpresas();
            String nombreReporte = 'SST_Peligro';
            if(cantidadEmpresa > 1){
                nombreReporte = nombreReporte + '_'+ empresaAutenticada;
            }
            
            Report reporte = [SELECT Id FROM Report where developerName =: nombreReporte];
            idReporte = reporte.id;
        }catch(Exception e){
            System.debug('No se encontró un reporte con el nombre Peligro para visualizar:'+e.getLineNumber()+' - '+e.getMessage());
        }
    }
    
    /*Método que se encarga de organizar los peligros que se van a mostrar*/
    private void organizarPeligros(SST_Peligro__c peligro,List<Id> idsResponsabilidades){
        String agrupador;
        if(peligro.area__r != null){
            agrupador = 'ÁREA: '+peligro.area__r.name+ ' - SEDE: '+peligro.Sede__r.name+' - PROCESO: '+peligro.Proceso__r.name;    
        }else{
            agrupador = 'SEDE: '+peligro.Sede__r.name+' - PROCESO: '+peligro.Proceso__r.name;    
        }
        
        List<PeligroDTO> listaPeligros = peligros.get(agrupador);
        if(listaPeligros== null){
            listaPeligros = new List<PeligroDTO>();
        }
        PeligroDTO peligroDTO = new PeligroDTO();
        peligroDTO = peligroDTO.convertToDTO(peligro,url);
        peligroDTO.tipoClasificacion = labelTipoClasificacion.get(peligroDTO.tipoClasificacion);
        peligroDTO.clasificacionPeligro = labelClasificacion.get(peligroDTO.clasificacionPeligro);
        listaPeligros.add(peligroDTO);
        idsResponsabilidades.add(peligro.Responsabilidad_cargo__c);
        peligros.put(agrupador, listaPeligros);
        
    }
    
    /*Método que se encarga de realizar la consulta de los expuestos*/
    public void consultarExpuestos(){
        try{
            mensajesPaginaPrincipal.clear();
            peligroSeleccionado = new PeligroDTO();
            /*se busca el peligro seleccionado*/
            String idPeligro = System.currentPagereference().getParameters().get('idPeligro');
            for(String key : peligros.keySet()){
                for(PeligroDTO peligroDTO :peligros.get(key)){
                    if(peligroDTO.id == idPeligro ){
                        peligroSeleccionado = peligroDTO;
                        break;
                    }
                }
            }
            expuestos = new List<Contact>();
            for(Contact contacto :[SELECT name, sst_tipo_contrato__c, sst_cargo__r.name FROM Contact WHERE SST_Empresa__c=:empresaAutenticada and sst_cargo__c in :peligroSeleccionado.cargos AND sst_sede__c= :peligroseleccionado.sede ORDER BY SST_cargo__r.name]){
                expuestos.add(contacto);
            }
            
            
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error consultando los expuestos, por favor contacte al administrador'));
            System.debug('Error en SST_MatrizPeligroCC.consultarExpuestos()'+e.getLineNumber()+e.getMessage());
        }
    }
    
    /*Método que se encarga de organizar la listas del peligro, como los cargos y el número de expuestos*/
    private void organizarListasPeligros(List<Id> idsResponsabilidades){
        Set<ID> cargosRelacionados = new Set<ID>();
        /*Se consultan los cargos asociados a las responsabilidades*/
        Map<String,Set<ID>> idCargos = consultarCargosResponsabilidad(idsResponsabilidades);
        for(List<PeligroDTO> listaPeligros : peligros.values()){
            for(PeligroDTO peligroDTO :listaPeligros){
                if(idCargos.get(peligroDTO.responsabilidad)!= null){
                    peligroDTO.cargos = new List<ID>();
                    peligroDTO.cargos.addAll(idCargos.get(peligroDTO.responsabilidad));
                    cargosRelacionados.addAll(peligroDTO.cargos);
                }
            }
        }  
    }
    
    /*Método que se encarga de consultar los cargos asociados a una responsabilidad*/
    private Map<String,Set<Id>> consultarCargosResponsabilidad(List<ID> idsResponsabilidades){
        Map<String,SEt<Id>> cargos = new Map<String,SEt<Id>>();
        for(SST_Formacion_cargo__c responsabilidadCargo :[SELECT cargo__c,formacion__r.Nombre__c FROM SST_Formacion_cargo__c WHERE Formacion__c in :idsResponsabilidades]){
            Set<Id> idCargos = cargos.get(responsabilidadCargo.formacion__r.Nombre__c);
            if(idCargos == null){ 
                idCargos = new Set<ID>();
            }
            idCargos.add(responsabilidadCargo.cargo__c);
            cargos.put(responsabilidadCargo.formacion__r.Nombre__c,idCargos);
        }
        return cargos;     
    }
    
    /*Método que se encarga de consultar los peligros por los filtros ingresados*/
    public void consultarPeligros(){
        try{
            mensajesPaginaPrincipal.clear(); 
            if(estadosSeleccionados== null || estadosSeleccionados.size()==0){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Debe seleccionar al menos un estado del peligro'));
            }else{
                peligros = new Map<String,List<PeligroDTO>>();
                List<String> campos = new List<String>{'Id','numero_expuestos_planta__c','estado__c','horas_exposicion__c','aceptabilidad_riesgo__c','interpretacion_riesgo__c','interpretacion__c','nivel_probabilidad__c','nivel_riesgo__c','name','area__c','area__r.Name','Sede__c','Sede__r.name','Proceso__r.name','Proceso__c','Responsabilidad_cargo__c','Responsabilidad_cargo__r.nombre__c','Rutinaria__c','Clasificacion_peligro__c','Tipo_clasificacion__c','Fuente__c','Medio__c','Individuo__c','Nivel_deficiencia__c','Nivel_exposicion__c','Nivel_consecuencia__c','Peor_consecuencia__c','Accion__c','Controles_ingenieria__c','Controles_administrativos__c','Observaciones__c','EPP__c','numero_expuestos_contratistas__c','Normatividad__c','detalle__c'};
                    List<String> camposTotal = new List<String>{'COUNT(ID)'};
                        List<String> filtros = new List<String>();
                
                List<String> seleccionados = new List<String>();
                for(String estadoSeleccionado : estadosSeleccionados){
                    seleccionados.add('\''+String.escapeSingleQuotes(estadoSeleccionado)+'\'');
                }
                filtros.add('estado__c IN '+seleccionados);
                filtros.add('empresa__c=\''+String.escapeSingleQuotes(empresaAutenticada)+'\'');
                
                if((area!= '0' && area!= null) || (sede != '0' && sede!= null) || (proceso != '0'&& proceso!= null) || (aceptabilidad != '0' && aceptabilidad!= null)){
                    if(area!= '0'){
                        filtros.add('area__c=\''+String.escapeSingleQuotes(area)+'\'');
                    }
                    if(sede != '0'){
                        filtros.add('sede__c=\''+String.escapeSingleQuotes(sede)+'\'');
                    }
                    if(proceso != '0'){
                        filtros.add('proceso__c=\''+String.escapeSingleQuotes(proceso)+'\'');
                    }
                    if(aceptabilidad != '0'){
                        filtros.add('aceptabilidad_riesgo__c=\''+String.escapeSingleQuotes(aceptabilidad)+'\'');
                    }
                }
                
                
                String query = 'SELECT ' + string.join(camposTotal, ',')+' FROM SST_peligro__c' ;
                
                boolean primerFiltro = true;
                
                for (String filtro : filtros) { //loop through the filters
                    String conector = (primerFiltro) ? ' WHERE ' : ' AND '; //get the right clause
                    filtro = filtro.trim();
                    filtro = filtro.replaceAll('(\\s+)', ' ');  //remove white space
                    //filtro = String.escapeSingleQuotes(filtro);
                    query += conector + filtro;  //add the filter to the query
                    primerFiltro = false;  //changes the filter clause
                }
                
                
                
                List<AggregateResult> cantidad = database.query(query);
                
                total =(Integer)cantidad.get(0).get('expr0');
                Decimal division = Decimal.valueOf(total);
                paginas = Integer.valueOf((division/10).round(System.RoundingMode.CEILING)); 
                
                
                List<Id> idsResponsabilidades = new List<Id>();
                query = 'SELECT ' + string.join(campos, ',')+' FROM SST_peligro__c' ;
                
                primerFiltro = true;
                for (String filtro : filtros) { //loop through the filters
                    String conector = (primerFiltro) ? ' WHERE ' : ' AND '; //get the right clause
                    filtro = filtro.trim();
                    filtro = filtro.replaceAll('(\\s+)', ' ');  //remove white space
                    //filtro = String.escapeSingleQuotes(filtro);
                    query += conector + filtro;  //add the filter to the query
                    primerFiltro = false;  //changes the filter clause
                }
                
                
                query += ' ORDER BY sede__r.name LIMIT 10 OFFSET '+ offSet;
                
                List<SST_Peligro__c> peligros  = database.query(query);
                
                
                if(peligros == null || peligros.size()==0){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'No existen peligros asociados a los filtros de búsqueda'));
                }else{
                    for(SST_peligro__c peligro : peligros){
                        organizarPeligros(peligro,idsResponsabilidades);
                    }
                    organizarListasPeligros(idsResponsabilidades);
                }
            }
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error consultando los peligros, por favor contacte al administrador'));
            System.debug('Error en SST_MatrizPeligroCC.consultarPeligros()- En la linea:'+e.getLineNumber()+' -Causa:'+e.getMessage());
        }
    }
    
    /*Método que selecciona el peligro y llena las lista de EPP y normatividades*/
    public void seleccionarPeligroEvaluacion(){
        try{
            mensajesPaginaPrincipal.clear();
            peligroSeleccionado = new PeligroDTO();
            /*se busca el peligro seleccionado*/
            String idPeligro = System.currentPagereference().getParameters().get('idPeligro');
            for(String key : peligros.keySet()){
                for(PeligroDTO peligroDTO :peligros.get(key)){
                    if(peligroDTO.id == idPeligro ){
                        peligroSeleccionado = peligroDTO;
                        break;
                    }
                }
            }
            
            obtenerAyudaNivelDeficiencia();
            obtenerAyudaNivelExposicion();
            obtenerAyudaNivelConsecuencia();
            obtenerAyudaNivelProbabilidad();
            
            /*se llenan las listas de los epp y las normatividadades*/
            
            if(peligroSeleccionado.epps== null){
                peligroSeleccionado.epps = new List<String>();
            }
            rightEPPValues = new List<SelectOption>();
            for(String epp :peligroSeleccionado.epps){
                rightEPPValues.add(new SelectOption(epp,epp));    
            }
            leftEPPValues = new List<SelectOption>();
            for(SST_Elemento_proteccion_personal__c epp :[SELECT name FROM SST_Elemento_Proteccion_Personal__c WHERE estado__c =:SST_Constantes.ACTIVO]){
                leftEPPValues.add(new SelectOption(epp.name,epp.name));
            }
            if(peligroSeleccionado.normatividades== null){
                peligroSeleccionado.normatividades = new List<String>();
            }
            rightLegalValues = new List<SelectOption>();
            for(String normatividad :peligroSeleccionado.normatividades){
                rightLegalValues.add(new SelectOption(normatividad,normatividad));    
            }
            leftLegalValues = new List<SelectOption>();
            for(SST_Normatividad__c legal :[SELECT  id,name FROM SST_Normatividad__c WHERE Empresa__c=:empresaAutenticada and name not in :peligroSeleccionado.normatividades]){
                leftLegalValues.add(new SelectOption(legal.name,legal.name));
            }
            
            
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error seleccionando el peliegro, por favor contacte al administrador'));
            System.debug('Error en SST_MatrizPeligroCC()'+e.getLineNumber()+e.getMessage());
            
        }
    }
    /*Método que obtiene la ayuda del nivel de deficiencia*/
    private void obtenerAyudaNivelDeficiencia(){
        if(peligroSeleccionado.nivelDeficiencia ==10){
            ayudaNivelDeficiencia = SST_Constantes.ND_MUY_ALTO;
        }else if(peligroSeleccionado.nivelDeficiencia == 6){
            ayudaNivelDeficiencia = SST_Constantes.ND_ALTO;
        }else if(peligroSeleccionado.nivelDeficiencia == 2){
            ayudaNivelDeficiencia = SST_Constantes.ND_MEDIO;
        }else if(peligroSeleccionado.nivelDeficiencia == 0){
            ayudaNivelDeficiencia = SST_Constantes.ND_NO_SE_ASIGNA_VALOR;
        }
    }
    /*Método que obtiene la ayuda del nivel de exposicion*/
    private void obtenerAyudaNivelExposicion(){
        if(peligroSeleccionado.nivelExposicion ==4){
            ayudaNivelExposicion = SST_Constantes.NE_CONTINUA;
        }else if(peligroSeleccionado.nivelExposicion == 3){
            ayudaNivelExposicion = SST_Constantes.NE_FRECUENTE;
        }else if(peligroSeleccionado.nivelExposicion == 2){
            ayudaNivelExposicion = SST_Constantes.NE_OCASIONAL;
        }else{
            ayudaNivelExposicion = SST_Constantes.NE_ESPORADICA;
        }        
    }
    /*Método que obtiene la ayuda del nivel de consecuencia*/
    private void obtenerAyudaNivelConsecuencia(){
        if(peligroSeleccionado.nivelConsecuencia ==100){
            ayudaNivelConsecuencia = SST_Constantes.NC_MORTAL_CATASTROFICO;
        }else if(peligroSeleccionado.nivelConsecuencia == 60){
            ayudaNivelConsecuencia = SST_Constantes.NC_MUY_GRAVE;
        }else if(peligroSeleccionado.nivelConsecuencia == 25){
            ayudaNivelConsecuencia = SST_Constantes.NC_GRAVE;
        }else{
            ayudaNivelConsecuencia = SST_Constantes.NC_LEVE;
        }        
    }
    /*Método que obtiene la ayuda del nivel de probabilidad*/
    private void obtenerAyudaNivelProbabilidad(){
        if(peligroSeleccionado.nivelProbabilidad>0){
            if(peligroSeleccionado.nivelProbabilidad >= 0 && peligroSeleccionado.nivelProbabilidad <=4){
                ayudaNivelProbabilidad = SST_Constantes.NP_BAJO;
            }
            if(peligroSeleccionado.nivelProbabilidad >= 6 && peligroSeleccionado.nivelProbabilidad <=8){
                ayudaNivelProbabilidad = SST_Constantes.NP_MEDIO;
            }
            if(peligroSeleccionado.nivelProbabilidad >= 10 && peligroSeleccionado.nivelProbabilidad <=20){
                ayudaNivelProbabilidad = SST_Constantes.NP_ALTO;
            }
            if(peligroSeleccionado.nivelProbabilidad >= 24 && peligroSeleccionado.nivelProbabilidad <=40){
                ayudaNivelProbabilidad = SST_Constantes.NP_MUY_ALTO;
            }
        }
    }
    
    /*Método que se encarga de obtener la interpretación del nivel d probabilidad*/
    public void obtenerInterpretacion(){
        try{
            obtenerAyudaNivelDeficiencia();
            obtenerAyudaNivelExposicion();
            obtenerAyudaNivelConsecuencia();
            obtenerAyudaNivelProbabilidad();
            calcularInterpretacion(peligroSeleccionado);
            calcularInterpretacionRiesgo(peligroSeleccionado);
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la interpretación, por favor contacte al administrador'));
            System.debug('Error en obtenerInterpretacion()'+e.getLineNumber()+e.getMessage());
            
        }
    }
    /*Método que se encarga de obtener la interpretación del riesgo*/
    public void obtenerInterpretacionRiesgo(){
        try{
            calcularInterpretacionRiesgo(peligroSeleccionado);
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la interpretación del riesgo, por favor contacte al administrador'));
            System.debug('Error en obtenerInterpretacionRiesgo()'+e.getLineNumber()+e.getMessage());
            
        }
    }
    /*Método que obitne la interpretación, nivel y aceptabilidad del riesgo*/
    private void calcularInterpretacionRiesgo(PeligroDTO peligroDTO){
        
        if(peligroDTO.nivelProbabilidad != null && peligroDTO.nivelConsecuencia != null &&
           peligroDTO.nivelConsecuencia != 0){
               peligroDTO.nivelRiesgo = peligroDTO.nivelProbabilidad*peligroDTO.nivelConsecuencia;
               if(peligroDTO.nivelRiesgo>=600){
                   peligroDTO.interpretacionRiesgo = SST_Constantes.NIVEL_RIESGO_I;
                   peligroDTO.aceptabilidadRiesgo = SST_Constantes.NO_ACEPTABLE;
               }else if(peligroDTO.nivelRiesgo>=150 && peligroDTO.nivelRiesgo<600){
                   peligroDTO.interpretacionRiesgo = SST_Constantes.NIVEL_RIESGO_II;
                   peligroDTO.aceptabilidadRiesgo = SST_Constantes.NO_ACEPTABLE;
               }else if (peligroDTO.nivelRiesgo>=40 && peligroDTO.nivelRiesgo<150){
                   peligroDTO.interpretacionRiesgo = SST_Constantes.NIVEL_RIESGO_III;
                   peligroDTO.aceptabilidadRiesgo = SST_Constantes.ACEPTABLE;
               }else{
                   peligroDTO.aceptabilidadRiesgo = SST_Constantes.ACEPTABLE;
                   peligroDTO.interpretacionRiesgo = SST_Constantes.NIVEL_RIESGO_IV;
               }
           }else{
               peligroDTO.nivelRiesgo = null;
               peligroDTO.interpretacionRiesgo = null;
               peligroDTO.aceptabilidadRiesgo = null;
           }
    }
    /*Método que calcula el nivel de probabilidad y la interpretación*/
    private void calcularInterpretacion(PeligroDTO peligroDTO){
        if( peligroDTO.nivelExposicion!= null
           && peligroDTO.nivelExposicion!= 0 &&  peligroDTO.nivelDeficiencia!= null
           && peligroDTO.nivelDeficiencia!= -1){
               peligroDTO.nivelProbabilidad = peligroDTO.nivelDeficiencia * peligroDTO.nivelExposicion;
               if(peligroDTO.nivelProbabilidad >= 0 && peligroDTO.nivelProbabilidad <=4){
                   peligroDTO.interpretacion =SST_Constantes.NIVEL_BAJO; 
               }
               if(peligroDTO.nivelProbabilidad >= 6 && peligroDTO.nivelProbabilidad <=8){
                   peligroDTO.interpretacion=SST_Constantes.NIVEL_MEDIO;  
               }
               if(peligroDTO.nivelProbabilidad >= 10 && peligroDTO.nivelProbabilidad <=20){
                   peligroDTO.interpretacion = SST_Constantes.NIVEL_ALTO;  
               }
               if(peligroDTO.nivelProbabilidad >= 24 && peligroDTO.nivelProbabilidad <=40){
                   peligroDTO.interpretacion =SST_Constantes.NIVEL_MUY_ALTO;
               }
           }else{
               peligroDTO.interpretacion = null;
               peligroDTO.nivelProbabilidad = null;
           }
    }
    /*Método que se encarga de guardar el peligro*/
    public void guardarPeligro(){
        try{
            mensajesPaginaPrincipal.clear();
            mensajesModal.clear();
            
            if(peligroSeleccionado.nivelDeficiencia== null || peligroSeleccionado.nivelDeficiencia==-1
               ||peligroSeleccionado.nivelExposicion== null || peligroSeleccionado.nivelExposicion==0
               || peligroSeleccionado.nivelConsecuencia== null || peligroSeleccionado.nivelConsecuencia==0){
                   mensajesModal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Los niveles de deficiciencia, exposición y consecuencia son obligatorios'));                   
               }else{
                   peligroSeleccionado.epps.clear();
                   for(SelectOption eppSeleccionado :rightEPPValues){
                       peligroSeleccionado.epps.add(eppSeleccionado.getLabel());    
                   }
                   
                   peligroSeleccionado.normatividades.clear();
                   for(SelectOption normatividadSeleccionada :rightLegalValues){
                       peligroSeleccionado.normatividades.add(normatividadSeleccionada.getLabel());    
                   }
                   SST_Peligro__c peligro= peligroSeleccionado.converToObject(peligroSeleccionado);
                   
                   if(peligro!=null){
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'El riesgo '+peligroSeleccionado.ClasificacionPeligro +'-'+peligroSeleccionado.tipoClasificacion +' se ha evaluado'));
                       consultarPeligros();
                   }else{
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para registrar o modificar los peligros'));           
                   }
               }
            
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error guardando los datos del peligro, por favor contacte al administrador'));
            System.debug('Error en guardarPeligro()'+e.getLineNumber()+e.getMessage());
            
        }
        
    }
    /*Método que se encarga de consultar la siguiente pagina*/
    public void verSiguiente(){
        offSet +=10;
        paginaActual +=1;
        consultarPeligros();
    }
    /*Método que se encarga de consultar la pagina anterior*/
    public void verAnterior(){
        offSet -=10;
        paginaActual -=1;
        consultarPeligros();
    }
    /*Método que se encarga de consultar la primera página*/
    public void verInicio(){
        offSet = 10;
        paginaActual = 1;
        consultarPeligros();
    }
    /*Método que se encarga de consultar la ultima página*/
    public void verFinal(){
        Integer modulo = Math.mod(total,10);
        offSet = total-modulo;
        paginaActual = paginas;
        consultarPeligros();
    }    
    /**Método que se encarga de obtener la lista de selección para el cumplimiento del estándar.*/
    public List<SelectOption> getNivelesDeficiencia(){
        try{
            Schema.DescribeFieldResult campo = SST_peligro__c.Nivel_deficiencia__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('-1',SST_Constantes.ITEM_VACIO_PICKLIST));
            for( Schema.PicklistEntry pickItem : picklist){
                lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
            }   
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista del niveles de deficiencia, por favor contacte al administrador'));
            System.debug('Error en getNivelesDeficiencia()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /**Método que se encarga de obtener la lista de selección para el cumplimiento del estándar.*/
    public List<SelectOption> getAcciones(){
        try{
            Schema.DescribeFieldResult campo = SST_peligro__c.Accion__c.getDescribe();
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
            for( Schema.PicklistEntry pickItem : picklist){
                lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
            }   
            
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista del niveles de deficiencia, por favor contacte al administrador'));
            System.debug('Error en getNivelesDeficiencia()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    
    /**Método que se encarga de obtener la lista de selección para el cumplimiento del estándar.*/
    public List<SelectOption> getNivelesExposicion(){
        try{
            Schema.DescribeFieldResult campo = SST_peligro__c.Nivel_exposicion__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
            for( Schema.PicklistEntry pickItem : picklist){
                lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
            }  
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista del niveles de exposición, por favor contacte al administrador'));
            System.debug('Error en getNivelesExposicion()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /**Método que se encarga de obtener la lista de selección para el cumplimiento del estándar.*/
    public List<SelectOption> getNivelesConsecuencia(){
        try{
            Schema.DescribeFieldResult campo = SST_peligro__c.Nivel_consecuencia__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
            for( Schema.PicklistEntry pickItem : picklist){
                lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
            }    
            
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista del niveles de consecuencia, por favor contacte al administrador'));
            System.debug('Error en getNivelesConsecuencia()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /**Método que se encarga de obtener la lista de selección para el cumplimiento del estándar.*/
    public List<SelectOption> getEstados(){
        try{
            Schema.DescribeFieldResult campo = SST_peligro__c.estado__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            for( Schema.PicklistEntry pickItem : picklist){
                if(pickItem.getLabel() != SST_Constantes.ESTADO_INACTIVO){
                    lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
                }
            }    
            
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista del niveles de consecuencia, por favor contacte al administrador'));
            System.debug('Error en getEstados()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    
    
    /*Método que se encarga de consultar las areas activas*/
    public List<SelectOption> getAreas(){
        try{
            List<sst_area_trabajo__c> items = [SELECT name,id from SST_area_trabajo__c where Empresa__c=:empresaAutenticada and estado__c =:SST_Constantes.ACTIVO order by name];
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
            for(sst_area_trabajo__c item : items){
                lista.add(new SelectOption(item.id,item.name));
            }    
            
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo al obtenera las áreas, por favor contacte al administrador'));
            System.debug('Error en getAreas()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /*Método que se encarga de consultar los procesos*/
    public List<SelectOption> getProcesos(){
        try{
            List<SST_Proceso__c> items = [SELECT name,id from SST_Proceso__c WHERE Empresa__c=:empresaAutenticada and estado__c=:SST_Constantes.ACTIVO  order by name];
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
            for(SST_Proceso__c item : items){
                lista.add(new SelectOption(item.id,item.name));
            }    
            
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo al obtenera las áreas, por favor contacte al administrador'));
            System.debug('Error en getProcesos()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /*Método que se encarga de consultar las sedes*/
    public List<SelectOption> getSedes(){
        try{
            List<SST_Sede__c> items = [SELECT name,id from SST_Sede__c where Empresa__c=:empresaAutenticada order by name];
            List<SelectOption> lista = new List<SelectOption>();
            lista.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
            for(SST_Sede__c item : items){
                lista.add(new SelectOption(item.id,item.name));
            }    
            
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo al obtenera los procesos, por favor contacte al administrador'));
            System.debug('Error en getSedes()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /*Método que se encarga de armar la lista de aceptabilidad*/
    public List<SelectOption> getValoresAceptabilidad(){
        List<SelectOption> lista = new List<SelectOption>();
        lista.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
        lista.add(new SelectOption(SST_Constantes.ACEPTABLE,SST_Constantes.ACEPTABLE));
        lista.add(new SelectOption(SST_Constantes.NO_ACEPTABLE,SST_Constantes.NO_ACEPTABLE));
        return lista;
    }
    
    
    /*Clase DTO que contiene los datos del objeto peligro en terminos de la pantalla*/
    public class PeligroDTO{
        public Id id {get; set;}
        public String area {get;set;}
        public String sede {get;set;}
        public String idResponsabilidad {get;set;}
        public String responsabilidad {get;set;}
        public Integer nivelDeficiencia {get; set;}
        public Integer nivelExposicion {get;set;}
        public Integer nivelProbabilidad {get;set;}
        public Integer nivelConsecuencia {get;set;}
        public Integer nivelRiesgo {get;set;}
        public String interpretacion {get; set;}
        public String interpretacionRiesgo {get; set;}
        public String aceptabilidadRiesgo {get; set;}
        public String clasificacionPeligro {get; set;}
        public String tipoClasificacion {get; set;}
        public Integer numeroExpuestosPlanta {get; set;}
        public Integer numeroExpuestosContratistas {get; set;}
        public Integer horasExposicion {get;set;}
        public String peorConsecuencia {get; set;}
        public boolean rutinaria {get; set;}
        public String accion {get; set;}
        public String fuente{get; set;}
        public String medio{get; set;}
        public String individuo{get; set;}
        public String url {get; set;}
        public String controlesIngenieria {get; set;}
        public String controlesAdministrativos {get; set;}
        public String observaciones {get; set;}        
        public String estado {get; set;}
        public String colorEstado {get; set;}
        public List<ID> cargos {get; set;}
        public List<String> epps {get; set;}
        public List<String> normatividades {get; set;}
        public List<Contact> expuestos {get; set;}
        public String detalle {get;set;}
    
    /*Método que convierte de objeto a dto*/
    public PeligroDTO convertToDTO(SST_Peligro__c peligro,String url){
        PeligroDTO peligroDTO = new PeligroDTO();
        
        peligroDTO.numeroExpuestosPlanta = 0;
        peligroDTO.id = peligro.id;
        
        /*se establece la acción del estado y el color del estado */
        if(peligro.estado__c!= null){
            if(peligro.Estado__c==SST_Constantes.ESTADO_IDENTIFICADO){
                peligroDTO.estado = SST_Constantes.ACCION_BOTON_IDENTIFICADO;
                peligroDTO.colorEstado = SST_Constantes.COLOR_NO_CUMPLE;
            } else if(peligro.Estado__c==SST_Constantes.ESTADO_EVALUADO){
                peligroDTO.estado = SST_Constantes.ACCION_BOTON_CONTROLADO;
                peligroDTO.colorEstado = SST_Constantes.COLOR_AMARILLO;
            }else if(peligro.Estado__c==SST_Constantes.ESTADO_INTERVENIDO){
                peligroDTO.estado = SST_Constantes.ACCION_BOTON_INTERVENIDO;
                if(peligro.accion__c==SST_Constantes.ACCION_ELIMINAR){
                    peligroDTO.colorEstado = SST_Constantes.COLOR_CUMPLE;
                }
            } 
        }
        if(peligro.Nivel_deficiencia__c != null){
            peligroDTO.nivelDeficiencia = Integer.valueOf(peligro.Nivel_deficiencia__c);
        }
        if(peligro.Nivel_exposicion__c != null){
            peligroDTO.nivelExposicion = Integer.valueOf(peligro.Nivel_exposicion__c);
        }
        if(peligro.Nivel_consecuencia__c != null){
            peligroDTO.nivelConsecuencia = Integer.valueOf(peligro.Nivel_consecuencia__c);
        }
        if(peligro.Nivel_probabilidad__c!= null){
            peligroDTO.nivelProbabilidad = (Integer)peligro.Nivel_probabilidad__c;
        }
        if(peligro.Nivel_riesgo__c != null){
            peligroDTO.nivelRiesgo = (Integer)peligro.Nivel_riesgo__c;
        }
        peligroDTO.interpretacion = peligro.Interpretacion__c;
        peligroDTO.interpretacionRiesgo = peligro.interpretacion_riesgo__c;
        peligroDTO.aceptabilidadRiesgo = peligro.aceptabilidad_riesgo__c;
        peligroDTO.tipoClasificacion = peligro.Tipo_clasificacion__c;
        peligroDTO.clasificacionPeligro = peligro.Clasificacion_peligro__c;
        peligroDTO.idResponsabilidad = peligro.Responsabilidad_cargo__c;
        peligroDTO.responsabilidad = peligro.Responsabilidad_cargo__r.nombre__c;
        peligroDTO.url = url +'/'+peligro.id+'/'+peligro.name;
        peligroDTO.rutinaria = peligro.Rutinaria__c;
        peligroDTO.fuente = peligro.Fuente__c;
        peligroDTO.individuo = peligro.Individuo__c;
        peligroDTO.medio = peligro.Medio__c;
        if(peligro.EPP__c!= null){
            peligroDTO.epps = peligro.EPP__c.split(';');
        }
        if(peligro.Normatividad__c!= null){
            peligroDTO.normatividades = peligro.Normatividad__c.split(';');
        }
        peligroDTO.numeroExpuestosContratistas = (Integer) peligro.numero_expuestos_contratistas__c;
        peligroDTO.numeroExpuestosPlanta = (Integer) peligro.numero_expuestos_planta__c;
        peligroDTO.horasExposicion = (Integer) peligro.horas_exposicion__c;
        peligroDTO.peorConsecuencia = peligro.peor_consecuencia__c;
        peligroDTO.controlesAdministrativos = peligro.Controles_administrativos__c;
        peligroDTO.controlesIngenieria = peligro.Controles_ingenieria__c;
        peligroDTO.observaciones = peligro.Observaciones__c;
        peligroDTO.area = peligro.area__c;
        peligroDTO.sede = peligro.Sede__c;
        peligroDTO.accion = peligro.Accion__c;
        peligroDTO.detalle = peligro.detalle__c;
        return peligroDTO;
    }
    
    
    /*Método que convierte de dto a objeto*/
    public SST_Peligro__c converToObject(PeligroDTO peligroDTO){
        if(Schema.sObjectType.SST_Peligro__c.fields.nivel_deficiencia__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Nivel_consecuencia__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Nivel_exposicion__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Numero_expuestos_contratistas__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Numero_expuestos_planta__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Horas_exposicion__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.peor_consecuencia__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Controles_administrativos__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Controles_ingenieria__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Observaciones__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Nivel_riesgo__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Nivel_probabilidad__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.Interpretacion__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.interpretacion_riesgo__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.aceptabilidad_riesgo__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.detalle__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.accion__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.EPP__c.isUpdateable()&&
           Schema.sObjectType.SST_Peligro__c.fields.normatividad__c.isUpdateable()){
               
               SST_Peligro__c peligro = [SELECT id FROM SST_Peligro__c WHERE id = :peligroDTO.id];
               peligro.nivel_deficiencia__c = peligroDTO.nivelDeficiencia!= null?peligroDTO.nivelDeficiencia+'':null ;
               peligro.Nivel_consecuencia__c = peligroDTO.nivelConsecuencia!= null?peligroDTO.nivelConsecuencia+'':null ;
               peligro.Nivel_exposicion__c = peligroDTO.nivelExposicion!= null?peligroDTO.nivelExposicion+'':null ;
               peligro.Numero_expuestos_contratistas__c = peligroDTO.numeroExpuestosContratistas;
               peligro.Numero_expuestos_planta__c = peligroDTO.numeroExpuestosPlanta;
               peligro.Horas_exposicion__c = peligroDTO.horasExposicion;
               peligro.peor_consecuencia__c = peligroDTO.peorConsecuencia;
               peligro.Controles_administrativos__c = peligroDTO.controlesAdministrativos;
               peligro.Controles_ingenieria__c = peligroDTO.controlesIngenieria;
               peligro.Observaciones__c = peligroDTO.observaciones;
               peligro.Nivel_riesgo__c = peligroDTO.nivelRiesgo;
               peligro.Nivel_probabilidad__c = peligroDTO.nivelProbabilidad;
               peligro.Interpretacion__c = peligroDTO.interpretacion;
               peligro.interpretacion_riesgo__c = peligroDTO.interpretacionRiesgo;
               peligro.aceptabilidad_riesgo__c = peligroDTO.aceptabilidadRiesgo;
               peligro.detalle__c = peligroDTO.detalle;
               
               if(peligroDTO.accion != null && peligroDTO.accion!='0'){
                   peligro.accion__c = peligroDTO.accion.toUpperCase();
               }
               /*se ajustan las listas en un area de texto para no crear mas relaciones ni objetos*/
               if(peligroDTO.epps != null && peligroDTO.epps.size()>0){
                   peligro.EPP__c = '';
                   for(String epp :peligroDTO.epps){
                       if(peligro.epp__c==''){
                           peligro.epp__c += epp;        
                       }else{
                           peligro.epp__c += ';'+epp;    
                       }    
                   }
               }else{
                   peligro.epp__c = null;
               }
               if(peligroDTO.normatividades != null && peligroDTO.normatividades.size()>0){
                   peligro.normatividad__c = '';
                   for(String normatividad :peligroDTO.normatividades){
                       if(peligro.Normatividad__c==''){
                           peligro.normatividad__c += normatividad;        
                       }else{
                           peligro.normatividad__c += ';'+normatividad;    
                       }
                       
                   }
               }else{
                   peligro.normatividad__c = null;              
               }
               update(peligro);
               return peligro;
           }else{
               return null;
           }
    }
    }
    
}