/*Clase que contiene toda la lógica necesaria para la administración de la matriz de peligros de Super polo
* @Yanebi Tamayo
* 14/12/2018
*/
public with sharing class SST_MatrizPeligroSPCC {
    
    /*Mapa para mostrar los peligros que serán evaluados en la página*/
    public Map<String,List<PeligroDTO>> peligros {get;set;}
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en el modal*/
    public List<SST_MensajesPagina> mensajesModal {get;set;}
    
    /*Objeto seleccionado para evualar*/
    public PeligroDTO peligroSeleccionado {get; set;}
    
    /*Listas para el manejo de multiselect del EPP*/
    public List<string> leftEPPSelected{get;set;}
    public List<string> rightEPPSelected{get;set;}
    Set<string> leftEPPValues = new Set<string>();
    Set<string> rightEPPValues = new Set<string>();
    
    /*Listas para el manejo de multiselect de CAPACITACIÓN*/
    public List<string> leftCAPSelected{get;set;}
    public List<string> rightCAPSelected{get;set;}
    Set<string> leftCAPValues = new Set<string>();
    Set<string> rightCAPValues = new Set<string>();
    
    /*Lista para los contactos expuestos*/
    public List<Contact> expuestos {get;set;}
    
    /*Filtro del área*/
    public String area {get; set;}
    
    /*Filtro de la valoracion*/
    public String valoracion{get; set;}
    
    /*Lista con los valores de los estados seleccionados para la busqueda*/
    public List<String> estadosSeleccionados {get; set;}
    
    /*Variable que contiene el id del reporte de la matriz de peligro*/
    public String idReporte {get; set;}
    
    /*Variable con el valor de la url actual*/
    String url;
    
    /*Nombres del label tipo de clasificación*/
    Map<String,String> labelExpuesto = new Map<String,String>();
    
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
    
    /*Método constructor*/
    public SST_MatrizPeligroSPCC(){
        offSet = 0;
        paginaActual = 1;
        peligroSeleccionado = new PeligroDTO();
        try{
            mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
            mensajesModal= new List<SST_MensajesPagina>();
            estadosSeleccionados = new List<String>();
            estadosSeleccionados.add(SST_constantes.ESTADO_IDENTIFICADO);
            estadosSeleccionados.add(SST_constantes.ESTADO_EVALUADO);
            estadosSeleccionados.add(SST_constantes.ESTADO_CONTROLES_ESTABLECIDOS);
            obtenerValoresPicklist();
            url = ApexPages.currentPage().getHeaders().get('Referer');
            consultarPeligros();
            consultarReporte();
            
            
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error construyendo el objeto, por favor contacte al administrador'));
            System.debug('Error en SST_MatrizPeligroSPCC() Linea:'+e.getLineNumber()+' - '+e.getMessage());
            
        }
    }
    /*Método encargado de obtener los valores de los picklist de Expuesto */
    private void obtenerValoresPicklist(){
        Schema.DescribeFieldResult campo = SST_Peligro_SP__c.Expuesto__c.getDescribe();
        List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
        for( Schema.PicklistEntry pickItem : picklist){
            labelExpuesto.put(pickItem.getValue(),pickItem.getLabel());
        }    
    }
    /*Método encargado de consultar el reporte de los peligros*/
    private void consultarReporte(){
        try{
            Report reporte = [SELECT Id FROM Report where developerName ='SST_MatrizPeligrosSP'];
            idReporte = reporte.id;
        }catch(Exception e){
            System.debug('No se encontró un reporte con el nombre Peligro para visualizar:'+e.getLineNumber()+' - '+e.getMessage());
        }
    }
    
    /*Método que se encarga de organizar los peligros que se van a mostrar*/
    private void organizarPeligros(SST_Peligro_SP__c peligro,List<Id> idsResponsabilidades){
        String agrupador = '<b>ÁREA:</b> '+peligro.area__r.name;
        List<PeligroDTO> listaPeligros = peligros.get(agrupador);
        if(listaPeligros== null){
            listaPeligros = new List<PeligroDTO>();
        }
        PeligroDTO peligroDTO = new PeligroDTO();
        peligroDTO = peligroDTO.convertToDTO(peligro,url);
        peligroDTO.expuesto = labelExpuesto.get(peligroDTO.expuesto);
        listaPeligros.add(peligroDTO);
        peligros.put(agrupador, listaPeligros);
        
    }
    /*Método que se encarga de organizar la listas del peligro, como los cargos y el número de expuestos*/
    private void organizarListasPeligros( List<Id> idsResponsabilidades){
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
        
        Map<String,Integer> numeroExpuestos = consultarNumeroExpuestos(cargosRelacionados);
        for(List<PeligroDTO> listaPeligros : peligros.values()){
            for(PeligroDTO peligroDTO :listaPeligros){
                if(peligroDTO.cargos != null && peligroDTO.cargos.size() >0){
                    for(String cargo : peligroDTO.cargos){
                        if(numeroExpuestos.get(cargo)!= null){
                            peligroDTO.numeroTrabajadoresExpuestos += numeroExpuestos.get(cargo);
                        }
                    }
                }
            }
        }
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
            for(Contact contacto :[SELECT name,sst_tipo_contrato__c, sst_cargo__r.name FROM Contact WHERE sst_cargo__c in :peligroSeleccionado.cargos ORDER BY SST_cargo__r.name]){
                expuestos.add(contacto);
            }
            
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error consultando los expuestos, por favor contacte al administrador'));
            System.debug('Error en SST_MatrizPeligroCC.consultarExpuestos()'+e.getLineNumber()+e.getMessage());
        }
    }
    /*Método que se encarga de consultar los peligros por los filtros ingresados*/
    public void consultarPeligros(){
        try{
            if(mensajesPaginaPrincipal.size()>0 && !mensajesPaginaPrincipal.get(0).mensajePage.contains('se ha evaluado')){
                mensajesPaginaPrincipal.clear();     
            }
            
            peligros = new Map<String,List<PeligroDTO>>();
            List<Id> idsResponsabilidades = new List<Id>();
            
            String query = 'SELECT Id,Estado__c,name,area__c,area__r.Name,Rutinaria__c,Expuesto__c,Peligro__c,Fuente_Generadora_Peligro__c,Numero_Trabajadores_Expuestos__c,Tiempo_Exposicion_Aproximado__c,Efectos_Salud_Propiedad__c,Accidentes_Enfermedades_Ocurridas__c,Fuente__c,Medio__c,Trabajador__c,Metodo__c,Metodos_Procedimientos__c,Nivel_Deficiencia__c,Nivel_Exposicion__c,Nivel_Probabilidad__c,Nivel_Consecuencia__c,Riesgo_Cualitativo_Num__c,Riesgo_Cualitativo_Texto__c,Marcador_Riesgo__c,Valor_Comparativo__c,Riesgo_Cuantitativo_Num__c,Riesgo_Cuantitativo_Texto__c,Valoracion_Riesgo__c,Eliminar__c,Sustituir__c,Controles_Ingenieria__c,Controles_Administrativos__c,Capacitacion__c,Senalizacion_Advertencias__c,EPP__c,Observaciones__c FROM SST_Peligro_SP__c ';
            String queryCount = 'SELECT COUNT(ID) FROM SST_Peligro_SP__c ';            
            
            
            if(estadosSeleccionados== null || estadosSeleccionados.size()==0){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Debe seleccionar al menos un estado del peligro'));
            }else{
                List<String> seleccionados = new List<String>();
                for(String estadoSeleccionado : estadosSeleccionados){
                    seleccionados.add('\''+String.escapeSingleQuotes(estadoSeleccionado)+'\'');
                }
                query += 'WHERE  estado__c IN '+seleccionados;
                queryCount += 'WHERE  estado__c IN '+seleccionados;
                
                
                if(area!= '0' && area!= null || (valoracion != '0' && valoracion != null)){
                    if(area!= '0'){
                        query += ' and area__c = \''+String.escapeSingleQuotes(area)+'\'';
                        queryCount += ' and area__c = \''+String.escapeSingleQuotes(area)+'\'';
                    }
                    if(valoracion != '0'){
                        query += ' and Valoracion_Riesgo__c = \''+String.escapeSingleQuotes(valoracion)+'\'';
                        queryCount += ' and Valoracion_Riesgo__c = \''+String.escapeSingleQuotes(valoracion)+'\'';
                    }
                }
                
                List<AggregateResult> cantidad = Database.query(queryCount);
                total =(Integer)cantidad.get(0).get('expr0');
                Decimal division = Decimal.valueOf(total);
                paginas = Integer.valueOf((division/10).round(System.RoundingMode.CEILING));
                
                query += ' LIMIT 10 OFFSET '+offSet;
                for(SST_Peligro_SP__c peligro : Database.query(query)){
                    organizarPeligros(peligro,idsResponsabilidades);
                }
                if(peligros.size()==0){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'No existen peligros asociados a los filtros de búsqueda'));
                }else{
                    organizarListasPeligros(idsResponsabilidades);
                }
            }
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error consultando los peligros, por favor contacte al administrador'));
            System.debug('Error en SST_MatrizPeligroCC.consultarPeligros()'+e.getLineNumber()+e.getMessage());
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
    /*Método que se encarga de consultar el número de expuestos*/
    private Map<String,Integer> consultarNumeroExpuestos(Set<Id> idCargos){
        Map<String,Integer> numeroExpuestos = new Map<String,Integer>();
        for(AggregateResult resultado : [SELECT SST_cargo__c cargo,COUNT(ID)cantidad FROM Contact WHERE SST_Cargo__c in :idCargos GROUP BY SST_cargo__c]){
            numeroExpuestos.put((String)resultado.get('cargo'),(Integer)resultado.get('cantidad'));
        }
        
        return numeroExpuestos;
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
            calcularRiesgoCualitativo(peligroSeleccionado);
            calcularRiesgoCuantitativo(peligroSeleccionado);
            calcularValoracionRiesgo(peligroSeleccionado);
            
            /*se llenan las listas de los epp y capacitaciones*/
            leftEPPSelected = new List<String>();
            rightEPPSelected = new List<String>();
            if(peligroSeleccionado.epps== null){
                peligroSeleccionado.epps = new List<String>();
            }
            rightEPPValues.addAll(peligroSeleccionado.epps);
            for(SST_Elemento_Proteccion_Personal__c epp :[SELECT  id,name FROM SST_Elemento_Proteccion_Personal__c WHERE name not in :peligroSeleccionado.epps]){
                leftEPPValues.add(epp.name);
            }
            if(peligroSeleccionado.capacitacion == null){
                peligroSeleccionado.capacitacion = new List<String>();
            }
            leftCAPSelected = new List<String>();
            rightCAPSelected = new List<String>();
            rightCAPValues.addAll(peligroSeleccionado.capacitacion);
            for(SST_Formacion__c cap :[SELECT  id,name,Nombre__c,RecordType.Name FROM SST_Formacion__c WHERE RecordType.Name =: SST_Constantes.RECORD_TYPE_ENTRENAMIENTOS AND Nombre__c not in :peligroSeleccionado.capacitacion]){
                leftCAPValues.add(cap.Nombre__c);
            }
            
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error seleccionando el peligro, por favor contacte al administrador'));
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
        }else{
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
            if(peligroSeleccionado.nivelProbabilidad >= 2 && peligroSeleccionado.nivelProbabilidad <=4){
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
    
    /*Método que se encarga de obtener la interpretación del nivel de probabilidad*/
    public void obtenerInterpretacion(){
        try{
            obtenerAyudaNivelDeficiencia();
            obtenerAyudaNivelExposicion();
            obtenerAyudaNivelConsecuencia();
            obtenerAyudaNivelProbabilidad();
            calcularInterpretacion(peligroSeleccionado);
            calcularRiesgoCualitativo(peligroSeleccionado);
            calcularRiesgoCuantitativo(peligroSeleccionado);
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la interpretación, por favor contacte al administrador'));
            System.debug('Error en obtenerInterpretacion()'+e.getLineNumber()+e.getMessage());
            
        }
    }
    /*Método que se encarga de obtener la interpretación del riesgo o Riesgo Cualitativo*/
    public void obtenerInterpretacionRiesgo(){
        try{
            calcularRiesgoCualitativo(peligroSeleccionado);
            calcularRiesgoCuantitativo(peligroSeleccionado);
            calcularValoracionRiesgo(peligroSeleccionado);
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la interpretación del riesgo, por favor contacte al administrador'));
            System.debug('Error en obtenerInterpretacionRiesgo()'+e.getLineNumber()+e.getMessage());
            
        }
    }
    /*Método que obtiene el riesgo Cualitativo*/
    private void calcularRiesgoCualitativo(PeligroDTO peligroDTO){
        
        if(peligroDTO.nivelDeficiencia != null && peligroDTO.nivelExposicion != null && peligroDTO.nivelConsecuencia != null
           && peligroDTO.nivelExposicion != 0 && peligroDTO.nivelConsecuencia != 0){
               peligroDTO.riesgoCualitativoNum = peligroDTO.nivelDeficiencia*peligroDTO.nivelExposicion*peligroDTO.nivelConsecuencia;
               if(peligroDTO.riesgoCualitativoNum>=600 && peligroDTO.riesgoCualitativoNum <= 4000){
                   peligroDTO.riesgoCualitativoTexto = SST_Constantes.NIVEL_ALTO;
                   peligroDTO.colorCualitativo = SST_Constantes.COLOR_NO_CUMPLE;
               }else if(peligroDTO.riesgoCualitativoNum>=120 && peligroDTO.riesgoCualitativoNum<=500){
                   peligroDTO.riesgoCualitativoTexto = SST_Constantes.NIVEL_MEDIO;
                   peligroDTO.colorCualitativo = SST_Constantes.COLOR_CUMPLE_PARCIALMENTE;
               }else if (peligroDTO.riesgoCualitativoNum>=20 && peligroDTO.riesgoCualitativoNum<=100){
                   peligroDTO.riesgoCualitativoTexto = SST_Constantes.NIVEL_BAJO;
                   peligroDTO.colorCualitativo = SST_Constantes.COLOR_CUMPLE;
               }else{
                   peligroDTO.riesgoCualitativoTexto = SST_Constantes.NO_APLICA;
                   peligroDTO.colorCualitativo = null;
               }
           }else{
               peligroDTO.riesgoCualitativoTexto = null;
               
           }
        
        
    }
    
    /*Método que obtiene el riesgo Cuantitativo*/
    private void calcularRiesgoCuantitativo(PeligroDTO peligroDTO){
        
        if(peligroDTO.marcadorRiesgo != null && peligroDTO.valorComparativo != null &&
           peligroDTO.marcadorRiesgo != 0 && peligroDTO.valorComparativo != 0){
               peligroDTO.riesgoCuantitativoNum = peligroDTO.marcadorRiesgo/peligroDTO.valorComparativo;
               if(peligroDTO.riesgoCuantitativoNum>=1){
                   peligroDTO.riesgoCuantitativoTexto = SST_Constantes.NIVEL_ALTO;
               }else if(peligroDTO.riesgoCuantitativoNum>=0.5 && peligroDTO.riesgoCuantitativoNum<1){
                   peligroDTO.riesgoCuantitativoTexto = SST_Constantes.NIVEL_MEDIO;
               }else if (peligroDTO.riesgoCuantitativoNum>0 && peligroDTO.riesgoCuantitativoNum<0.5){
                   peligroDTO.riesgoCuantitativoTexto = SST_Constantes.NIVEL_BAJO;
               }else{
                   peligroDTO.riesgoCuantitativoTexto = SST_Constantes.NO_APLICA;
               }
           }else{
               peligroDTO.riesgoCuantitativoTexto = null;
               peligroDTO.valoracionRiesgo = null;
           }
        
    }
    
    /*Método que obtiene la Valoración del Riesgo*/
    private void calcularValoracionRiesgo(PeligroDTO peligroDTO){
        
        if(peligroDTO.riesgoCualitativoTexto != null){
            if(peligroDTO.riesgoCualitativoTexto == SST_Constantes.NIVEL_ALTO){
                peligroDTO.valoracionRiesgo = SST_Constantes.NO_ACEPTABLE;
                peligroDTO.colorRiesgo = SST_Constantes.COLOR_NO_CUMPLE;
            }else if(peligroDTO.riesgoCualitativoTexto == SST_Constantes.NIVEL_MEDIO){
                peligroDTO.valoracionRiesgo = SST_Constantes.ACEPTABLE;
                peligroDTO.colorRiesgo = SST_Constantes.COLOR_CUMPLE;
            }else if(peligroDTO.riesgoCualitativoTexto == SST_Constantes.NIVEL_BAJO){
                peligroDTO.valoracionRiesgo = SST_Constantes.ACEPTABLE;
                peligroDTO.colorRiesgo = SST_Constantes.COLOR_CUMPLE;
            }
            else if(peligroDTO.riesgoCualitativoTexto == SST_Constantes.NO_APLICA){
                if(peligroDTO.riesgoCuantitativoTexto == SST_Constantes.NIVEL_ALTO){
                    peligroDTO.valoracionRiesgo = SST_Constantes.NO_ACEPTABLE;
                    peligroDTO.colorRiesgo = SST_Constantes.COLOR_NO_CUMPLE;
                }
                if(peligroDTO.riesgoCuantitativoTexto == SST_Constantes.NIVEL_MEDIO){
                    peligroDTO.valoracionRiesgo = SST_Constantes.ACEPTABLE;
                    peligroDTO.colorRiesgo = SST_Constantes.COLOR_CUMPLE;
                }
                if(peligroDTO.riesgoCuantitativoTexto == SST_Constantes.NIVEL_BAJO){
                    peligroDTO.valoracionRiesgo = SST_Constantes.ACEPTABLE;
                    peligroDTO.colorRiesgo = SST_Constantes.COLOR_CUMPLE;
                }else{
                    peligroDTO.valoracionRiesgo = SST_Constantes.REALICE_VALORACION;
                } 
            }else{
                peligroDTO.valoracionRiesgo = SST_Constantes.REALICE_VALORACION;
            }
        }
        
    }
    
    /*Método que calcula el nivel de probabilidad*/
    private void calcularInterpretacion(PeligroDTO peligroDTO){
        if(peligroDTO.nivelDeficiencia != null && peligroDTO.nivelExposicion!= null
           &&peligroDTO.nivelDeficiencia != 0 && peligroDTO.nivelExposicion!= 0){
               peligroDTO.nivelProbabilidad = peligroDTO.nivelDeficiencia * peligroDTO.nivelExposicion;
               
           }else if(peligroDTO.nivelDeficiencia == 0){
               peligroDTO.nivelProbabilidad =  0;
           }
        else{
            peligroDTO.nivelProbabilidad = null;
        }
    }
    /*Método que se encarga de guardar el peligro*/
    public void guardarPeligro(){
        try{
            mensajesPaginaPrincipal.clear();
            mensajesModal.clear();
            if(peligroSeleccionado.nivelDeficiencia== null
               ||peligroSeleccionado.nivelExposicion== null || peligroSeleccionado.nivelExposicion==0
               || peligroSeleccionado.nivelConsecuencia== null || peligroSeleccionado.nivelConsecuencia==0 ){
                   mensajesModal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Los niveles de deficiciencia, exposición y consecuencia son obligatorios'));                   
               }else{
                   peligroSeleccionado.epps.clear();
                   peligroSeleccionado.epps.addAll(rightEPPValues);
                   peligroSeleccionado.capacitacion.clear();
                   peligroSeleccionado.capacitacion.addAll(rightCAPValues);
                   
                   calcularRiesgoCualitativo(peligroSeleccionado);
                   calcularRiesgoCuantitativo(peligroSeleccionado);
                   calcularValoracionRiesgo(peligroSeleccionado);
                   
                   SST_Peligro_SP__c peligro= peligroSeleccionado.converToObject(peligroSeleccionado);
                   if(peligro != null ){
                       
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'El riesgo '+'-'+peligroSeleccionado.expuesto +' se ha evaluado'));
                       consultarPeligros();
                   }else{
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para actualizar el peligro'));   
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
            Schema.DescribeFieldResult campo = SST_Peligro_SP__c.Nivel_deficiencia__c.getDescribe();
            
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
            Schema.DescribeFieldResult campo = SST_Peligro_SP__c.Nivel_exposicion__c.getDescribe();
            
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
            Schema.DescribeFieldResult campo = SST_Peligro_SP__c.Nivel_consecuencia__c.getDescribe();
            
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
            Schema.DescribeFieldResult campo = SST_Peligro_SP__c.estado__c.getDescribe();
            
            List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
            List<SelectOption> lista = new List<SelectOption>();
            for( Schema.PicklistEntry pickItem : picklist){
                lista.add(new SelectOption(pickItem.getValue(),pickItem.getLabel()));
            }    
            
            return lista;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista del niveles de consecuencia, por favor contacte al administrador'));
            System.debug('Error en getEstados()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
    /*Método que se encarga de agregar los elementos seleccionados a la lista*/
    public PageReference selectclick(){
        for(String s : leftEPPSelected){
            leftEPPValues.remove(s);
            rightEPPValues.add(s);
        }
        return null;
    }
    
    /*Método que se encarga de quitar los elementos deseleccionados a la lista*/
    public PageReference unselectclick(){
        for(String s : rightEPPSelected){
            rightEPPValues.remove(s);
            leftEPPValues.add(s);
        }
        return null;
    }
    /*Método que se encarga de quitar los elementos deseleccionados a la lista*/
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftEPPValues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
    
    /*Método que se encarga de agrega los elementos seleccionados a la lista*/
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightEPPValues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    public PageReference selectCAPClick(){
        
        for(String s : leftCAPSelected){
            leftCAPValues.remove(s);
            rightCAPValues.add(s);
        }
        return null;
    }
    
    public PageReference unselectCAPclick(){
        
        for(String s : rightCAPSelected){
            rightCAPValues.remove(s);
            leftCAPValues.add(s);
        }
        return null;
    }
    public List<SelectOption> getunSelectedCAPValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftCAPValues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
    /*Método  que se encarga de llenar la lista de select para las CAPACITACIONES*/
    public List<SelectOption> getSelectedCAPValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightCAPValues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    /*Método que se encarga de consultar las areas activas*/
    public List<SelectOption> getAreas(){
        try{
            List<sst_area_trabajo__c> items = [SELECT name,id from SST_area_trabajo__c where estado__c =:SST_Constantes.ACTIVO order by name];
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
    
    /*Método que se encarga de armar la lista de Valoración de Riesgo*/
    public List<SelectOption> getValoresRiesgo(){
        List<SelectOption> lista = new List<SelectOption>();
        lista.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
        lista.add(new SelectOption(SST_Constantes.ACEPTABLE,SST_Constantes.ACEPTABLE));
        lista.add(new SelectOption(SST_Constantes.NO_ACEPTABLE,SST_Constantes.NO_ACEPTABLE));
        lista.add(new SelectOption(SST_Constantes.REALICE_VALORACION,SST_Constantes.REALICE_VALORACION));
        return lista;
    }
    
    
    /*Clase DTO que contiene los datos del objeto peligro en terminos de la pantalla*/
    public class PeligroDTO{
        public Id id {get; set;}
        public String area {get;set;}
        public String idResponsabilidad {get;set;}
        public String responsabilidad {get;set;}
        public Integer nivelDeficiencia {get; set;}
        public Integer nivelExposicion {get;set;}
        public Integer nivelProbabilidad {get;set;}
        public Integer nivelConsecuencia {get;set;}
        public Decimal marcadorRiesgo {get; set;}
        public Decimal valorComparativo {get; set;}
        public Decimal riesgoCuantitativoNum {get;set;}
        public String riesgoCuantitativoTexto {get;set;}
        public String riesgoCualitativoTexto {get; set;}
        public Integer riesgoCualitativoNum {get;set;}
        public String valoracionRiesgo {get; set;}
        public String expuesto {get; set;}
        public String peligro {get; set;} 
        public String fuenteGeneradoraPeligro {get; set;} 
        public Integer tiempoExposicionAproximado {get; set;} 
        public String accidentesEnfermedadesOcurridas {get; set;}
        public Integer numeroTrabajadoresExpuestos {get; set;}
        public String senalizacionAdvertencias {get; set;}
        public Integer numeroExpuestosContratistas {get; set;}
        public boolean rutinaria {get; set;}
        public String eliminar {get; set;}
        public String sustituir {get; set;}
        public String efectosSaludPropiedad{get; set;}
        public String fuente{get; set;}
        public String medio{get; set;}
        public String trabajador{get; set;}
        public String metodo {get; set;}
        public String metodosProcedimientos {get; set;}
        public String url {get; set;}
        public String controlesIngenieria {get; set;}
        public String controlesAdministrativos {get; set;}
        public String observaciones {get; set;}        
        public String estado {get; set;}
        public String colorEstado {get; set;}
        public String colorCualitativo {get; set;}
        public String colorRiesgo {get; set;}
        public List<ID> cargos {get; set;}
        public List<String> epps {get; set;}
        public List<String> capacitacion {get; set;}
        public List<Contact> expuestos {get; set;}
        
        /*Método que convierte de objeto a dto*/
        public PeligroDTO convertToDTO(SST_Peligro_SP__c peligro,String url){
            PeligroDTO peligroDTO = new PeligroDTO();
            
            peligroDTO.numeroTrabajadoresExpuestos = 0;
            peligroDTO.id = peligro.id;
            
            /*se establece la acción del estado y el color del estado */
            if(peligro.estado__c!= null){
                if(peligro.Estado__c==SST_Constantes.ESTADO_IDENTIFICADO){
                    peligroDTO.estado = SST_Constantes.ACCION_BOTON_IDENTIFICADO;
                    peligroDTO.colorEstado = SST_Constantes.COLOR_NO_CUMPLE;
                } else if(peligro.Estado__c==SST_Constantes.ESTADO_EVALUADO){
                    peligroDTO.estado = SST_Constantes.ACCION_BOTON_EVALUADO;
                    peligroDTO.colorEstado = SST_Constantes.COLOR_AMARILLO;
                }else if(peligro.Estado__c==SST_Constantes.ESTADO_CONTROLES_ESTABLECIDOS){
                    peligroDTO.estado = SST_Constantes.ACCION_BOTON_INTERVENIDO;
                    peligroDTO.colorEstado = SST_Constantes.COLOR_AZUL;
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
            
            peligroDTO.marcadorRiesgo = Integer.valueOf(peligro.Marcador_Riesgo__c);
            peligroDTO.valorComparativo = Integer.valueOf(peligro.Valor_Comparativo__c);
            peligroDTO.riesgoCuantitativoTexto = peligro.Riesgo_Cuantitativo_Texto__c;
            peligroDTO.riesgoCuantitativoNum = Integer.valueOf(peligro.Riesgo_Cuantitativo_Num__c);
            peligroDTO.riesgoCualitativoTexto = peligro.Riesgo_Cualitativo_Texto__c;
            peligroDTO.riesgoCualitativoNum = Integer.valueOf(peligro.Riesgo_Cualitativo_Num__c);
            peligroDTO.valoracionRiesgo = peligro.Valoracion_Riesgo__c;
            peligroDTO.expuesto = peligro.Expuesto__c;
            //   peligroDTO.idResponsabilidad = peligro.Actividad__c;
            //   peligroDTO.responsabilidad = peligro.Actividad__r.nombre__c;
            peligroDTO.url = url +'/'+peligro.id+'/'+peligro.name;
            peligroDTO.rutinaria = peligro.Rutinaria__c;
            peligroDTO.eliminar = peligro.Eliminar__c;
            peligroDTO.sustituir = peligro.Sustituir__c;
            peligroDTO.fuente = peligro.Fuente__c;
            peligroDTO.efectosSaludPropiedad = peligro.Efectos_Salud_Propiedad__c;
            peligroDTO.peligro = peligro.Peligro__c;
            peligroDTO.fuenteGeneradoraPeligro = peligro.Fuente_Generadora_Peligro__c;
            peligroDTO.tiempoExposicionAproximado = Integer.valueOf(peligro.Tiempo_Exposicion_Aproximado__c);
            peligroDTO.accidentesEnfermedadesOcurridas = peligro.Accidentes_Enfermedades_Ocurridas__c;
            peligroDTO.trabajador = peligro.Trabajador__c;
            peligroDTO.medio = peligro.Medio__c;
            peligroDTO.metodo = peligro.Metodo__c;
            peligroDTO.metodosProcedimientos = peligro.Metodos_Procedimientos__c;
            peligroDTO.senalizacionAdvertencias = peligro.Senalizacion_Advertencias__c;
            if(peligro.EPP__c!= null){
                peligroDTO.epps = peligro.EPP__c.split(';');
            }
            if(peligro.Capacitacion__c!= null){
                peligroDTO.capacitacion = peligro.Capacitacion__c.split(';');
            }
            peligroDTO.controlesAdministrativos = peligro.Controles_administrativos__c;
            peligroDTO.controlesIngenieria = peligro.Controles_ingenieria__c;
            peligroDTO.observaciones = peligro.Observaciones__c;
            peligroDTO.area = peligro.area__c;
            
            return peligroDTO;
        }
        
        
        /*Método que convierte de dto a objeto*/
        public SST_Peligro_SP__c converToObject(PeligroDTO peligroDTO){
            if(Schema.sObjectType.SST_Peligro_SP__c.fields.nivel_deficiencia__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Nivel_consecuencia__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Nivel_exposicion__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Fuente__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Medio__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Trabajador__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Metodo__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Metodos_Procedimientos__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Marcador_Riesgo__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Valor_Comparativo__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Controles_administrativos__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Senalizacion_Advertencias__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Controles_ingenieria__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Observaciones__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Riesgo_Cuantitativo_Num__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Riesgo_Cuantitativo_Texto__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Riesgo_Cualitativo_Num__c .isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Riesgo_Cualitativo_Texto__c .isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Nivel_probabilidad__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Valoracion_Riesgo__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Eliminar__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Sustituir__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.epp__c.isUpdateable()&&
               Schema.sObjectType.SST_Peligro_SP__c.fields.Capacitacion__c.isUpdateable()){
                   
                   SST_Peligro_SP__c peligro = [SELECT id FROM SST_Peligro_SP__c WHERE id = :peligroDTO.id];
                   peligro.nivel_deficiencia__c = peligroDTO.nivelDeficiencia!= null?peligroDTO.nivelDeficiencia+'':null ;
                   peligro.Nivel_consecuencia__c = peligroDTO.nivelConsecuencia!= null?peligroDTO.nivelConsecuencia+'':null ;
                   peligro.Nivel_exposicion__c = peligroDTO.nivelExposicion!= null?peligroDTO.nivelExposicion+'':null ;
                   peligro.Fuente__c = peligroDTO.fuente;
                   peligro.Medio__c = peligroDTO.medio;
                   peligro.Trabajador__c = peligroDTO.trabajador;
                   peligro.Metodo__c = peligroDTO.metodo;
                   peligro.Metodos_Procedimientos__c = peligroDTO.metodosProcedimientos;
                   peligro.Marcador_Riesgo__c = peligroDTO.marcadorRiesgo;
                   peligro.Valor_Comparativo__c = peligroDTO.valorComparativo;
                   peligro.Controles_administrativos__c = peligroDTO.controlesAdministrativos;
                   peligro.Senalizacion_Advertencias__c = peligroDTO.senalizacionAdvertencias;
                   peligro.Controles_ingenieria__c = peligroDTO.controlesIngenieria;
                   peligro.Observaciones__c = peligroDTO.observaciones;
                   peligro.Riesgo_Cuantitativo_Num__c = peligroDTO.riesgoCuantitativoNum;
                   peligro.Riesgo_Cuantitativo_Texto__c = peligroDTO.riesgoCuantitativoTexto;
                   peligro.Nivel_probabilidad__c = peligroDTO.nivelProbabilidad;
                   peligro.Riesgo_Cualitativo_Num__c = peligroDTO.riesgoCualitativoNum;
                   peligro.Riesgo_Cualitativo_Texto__c = peligroDTO.riesgoCualitativoTexto;
                   peligro.Valoracion_Riesgo__c = peligroDTO.valoracionRiesgo;
                   peligro.Eliminar__c = peligroDTO.eliminar;
                   peligro.Sustituir__c = peligroDTO.sustituir;
                   
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
                   }
                   if(peligroDTO.capacitacion != null && peligroDTO.capacitacion.size()>0){
                       peligro.Capacitacion__c = '';
                       for(String capa :peligroDTO.capacitacion){
                           if(peligro.Capacitacion__c==''){
                               peligro.Capacitacion__c += capa;        
                           }else{
                               peligro.Capacitacion__c += ';'+capa;    
                           }    
                       }
                   }
                   update(peligro);
                   return peligro;
               }else{
                   return null;
               }
        }
    }
    
}