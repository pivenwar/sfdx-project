/*
* @autor: Marcela Taborda
* @fecha: 05/09/2018
* @version: 1.0
* 
* @autor: Marcela Taborda
* @fecha: 04/02/2019
* @version: 2.0
*
* @autor: Marcela Taborda
* @fecha: 28/02/2019
* @version: 3.0
* 
*** Convenciones generales***
* AT: Accidentes de trabajo
* EL: Enfermedades laborales
* 
*** Convenciones para indicadores***
* ACM: Ausentismo por causa médica
* FA: Frecuencia de accidentalidad		
* IEL: Incidencia de EL   		
* IFA: Índice de frecuencia de ausentismos por causa de salud
* IFAT: Índice de frecuencia de AT						
* IFIAT: Índice de frecuencia de AT con incapacidad	
* ILIAT: Índice de lesiones incapacitantes por AT	
* ISAT: Índice de Severidad de AT						
* MAT: Mortalidad de AT 												
* PEL: Prevalencia de EL	
* PTP: Porcentaje de tiempo perdido por causa de salud										
* SA: Severidad de accidentalidad
*/

public with sharing class SST_IndicadoresResultadoCC {
    //Atributo para obtener la fecha inicial para la consulta del indicador
    public date fechaInicio {get;set;}
    
    //Atributo para obtener la fecha final para la consulta del indicador
    public date fechaFin {get;set;}
    
    
    //Atributo para establecer la fecha máxima disponible para seleccionar en la página
    public String fechaMax {get;set;}
    
    //Atributo para mostrar los mensajes de éxito, confirmación o error en la página
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    //Atributo para obtener el indicador seleccionado en la página
    public String indicadorSelect {get;set;}
    
    //Mapa para obtener la lista de los indicadores de resultado existentes
    Map <String, String> mapaIndicadores {get;set;}
    
    //Atributo para activar o inactivar el botón de guardar en la página
    public Boolean botonActivo {get; set;}
    
    //Atributo para obtener la empresa y la meta del indicador seleccionado
    Account cuenta {get;set;}
    
    //Atributo para mostrar el mensaje con el resultado del indicador calculado
    Public String resultado {get;set;}
    Public String resultado2 {get;set;}
    
    //Atributo para mostrar el indicador calculado
    public Double indicador {get;set;}
    
    //Atributo para mostrar la meta del indicador calculado
    public Double metaIndicador {get;set;}
    
    //Atributo para mostrar la frecuencia de medición del indicador calculado
    public String frecuenciaIndicador {get;set;}
    public String frecuencia {get;set;}
    
    //Atributo para mostrar la unidad de medida del indicador calculado
    public String unidadIndicador {get;set;}
    
    //Atributo para obtener la lista con los nombres completos de los indicadores
    List <String> valuesMapa {get;set;}
    
    //Atributo para mostrar en pantalla el periodo para el cual fue calculado el indicador
    Public String periodo {get;set;}
    
    //Atributo para renderizar el background del indicador calculado, verde si es menor o igual a la meta del indicador, rojo si es mayor a la meta
    Public String bakcgroundIndicador {get;set;}
    
    //Atributo para almacenar el campo Análisis
    public String analisis{get;set;}
    
    //Atributo para almacenar el id del análisis de indicador que se puede modificar en pantalla
    public String idIndicador{get;set;}
    
    /*Atributo para obtener la url del home de la comunidad*/
    public String url {get;set;}
    
    /*Atributo para obtener el nit de la empresa en la que el usuario en sesión está logueado*/
    String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
    
    //Atributo para realizar las diferentes consultas filtrando por el campo empresa
    List<String> empresas {get;set;}
    
    //Atributo que indica si el usuario logueado es administrador
    public Boolean esAdmin {get;set;}
    
    //Atributo que almacena las horas estándar por día de trabajo
    Integer horasDia = SST_Constantes.HORAS_DIA;
    
    //Atributo que almacena los días estándar por mes
    Integer diasMes = SST_Constantes.DIAS_MES;
    // Lista que contiene el record type de funcionario
    List <ID> recordTypeFuncionario;
    // Lista que contiene el record type de las incapacidades según el indicador
    List <ID> recordTypeIncapacidades;
    // Lista que contiene el record type de los accidentes
    List <ID> recordTypeAccidentes;
    // Lista que contiene el record type de los accidentes
    List <ID> recordTypeAusentismos;
    //lista con los funcionarios activos
    List <Contact> funcionariosActivos;
    public List <DTOLista> indicadoresExistentes {get;set;}
    public DTOLista registroSeleccionado {get;set;}
    public String idRegistroSeleccionado {get;set;}
    
    //Controlador
    public SST_IndicadoresResultadoCC(){
        recordTypeFuncionario = new List<ID>();
        recordTypeIncapacidades = new List<ID>();
        recordTypeAusentismos = new List<ID>();
        recordTypeAccidentes = new List<ID>();
        registroSeleccionado = new DTOLista();
        empresas = new List<String>();
        //Si el usuario en sesión es administrador del sistema, se llena la lista empresas con todas las empresas activas del grupo empresarial,
        //en caso contrario sólo se llena la lista con la empresa autenticada del usuario en sesión.
        if(SST_Constantes.returnAdministrador().profileId == userInfo.getProfileId()){
            esAdmin = true;
            for(Account temp : [select id, sst_nit__c from account where type =:SST_Constantes.CLIENTE and sst_estado__c =: SST_Constantes.ACTIVO]){
                empresas.add(String.valueOf(temp.sst_nit__c));
            }
        } else {
            esAdmin = false;
            empresas.add(empresaAutenticada);
        }
        url = SST_Constantes.retornarUrl()+SST_Constantes.PAGINA_DETALLE_INDICADOR;
        botonActivo = false;
        periodo = '';
        Date d = system.today();
        fechaMax = String.valueOf(d);
        fechaFin = system.today();
        cuenta = new Account();
        frecuenciaIndicador = '';
        frecuencia = '';
        resultado = '';
        resultado2 = '';
        bakcgroundIndicador = '';
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
        mapaIndicadores = SST_Constantes.llenarMapaIndicadoresResultado();
        consultarEmpresa();
        valuesMapa = mapaIndicadores.values();
    }
    
    //Método para llamar la consulta respectiva según el indicador seleccionado
    public PageReference consultar(){ 
        indicador = null;
        metaIndicador = null;
        periodo = '';
        unidadIndicador = '';
        resultado = '';
        resultado2 = '';
        frecuencia = '';
        analisis = null;
        idIndicador=null;
        bakcgroundIndicador = '';
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
        consultarParametrosIndicador();
        //Si no se ha seleccionado un indicador, se muestra mensaje de error en la página
        if(mapaIndicadores.get(indicadorSelect) == null){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Debe seleccionar un indicador para consultar'));
        } 
        
        //Si se ha seleccionado un indicador y la fecha de fin es mayor o igual a la fecha de inicio, se consulta el indicador seleccionado
        if(mensajesPaginaPrincipal.size()==0) {
            botonActivo = true;
            indicador = 0;
            Id idRecordTypeFuncionario = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId();
            recordTypeFuncionario.add(idRecordTypeFuncionario);
            if(fechaInicio < fechaFin){
                unidadIndicador = 'Unidad de medida: '+SST_Constantes.llenarMapaUnidadesIndicadoresResultado().get(indicadorSelect);   
            }
            //llamado al método para consultar los análisis existentes para el indicador seleccionado
            consultarAnalisisIndicadores();            
            
            //Llamado al método para generar el indicador ACM
            if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(0))){
                Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeIncapacidades.add(idRecordType);
                indicador = generarACM(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador FA
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(1))){
                Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.ACCIDENTES).getRecordTypeId();
                recordTypeAccidentes.add(idRecordType);              
                indicador = generarFA(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador IEL
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(2))){                
                indicador = generarIEL(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador IFA
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(3))) {
                
                Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeIncapacidades.add(idRecordType);
                
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[1]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);
                
                indicador = generarACM(fechaInicio, fechaFin);
                indicador = generarIFA(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador IFAT
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(4))) {
                Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.ACCIDENTES).getRecordTypeId();
                recordTypeAccidentes.add(idRecordType);
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);            
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[1]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);            
                indicador = generarIFAT(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador IFIAT
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(5))) {
                Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeIncapacidades.add(idRecordType); 
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);            
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[1]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);  
                indicador = generarIFIAT(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador ILIAT
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(6))) {
 				Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeIncapacidades.add(idRecordType); 
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);            
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[1]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);
                
                indicador = generarILIAT(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador ISAT
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(7))) {
                Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeIncapacidades.add(idRecordType); 
				idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);            
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[1]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);
                indicador = generarISAT(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador MAT
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(8))){
                Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.ACCIDENTES).getRecordTypeId();
                recordTypeAccidentes.add(idRecordType);             
                indicador = generarMAT(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador PEL
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(9))){
                indicador = generarPEL(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador PTP
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(10))) {
                Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeIncapacidades.add(idRecordType); 
                idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[1]).getRecordTypeId();
                recordTypeAusentismos.add(idRecordType);
                
                indicador = generarPTP(fechaInicio, fechaFin);
            }
            
            //Llamado al método para generar el indicador SA
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(11))){
				Id idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES[0]).getRecordTypeId();
                recordTypeIncapacidades.add(idRecordType);
 				idRecordType = Schema.SObjectType.SST_Registro_de_novedades__c.getRecordTypeInfosByName().get(SST_Constantes.ACCIDENTES).getRecordTypeId();
                recordTypeAccidentes.add(idRecordType);             
                
                indicador = generarSA(fechaInicio, fechaFin);
            }
        } 
        return null;
    }
    
    //Método que consulta y retorna una variable double con el indicador ACM.  SOLO SUMA LOS DÍAS DE INCAPACIDAD COMPRENDIDOS EN EL PERIODO CONSULTADO
    public Decimal generarACM(Date fechaInicio, Date fechaFin){
        Decimal acm = 0;
        Double diasTrabajados = 0;
        List <SST_Registro_de_Novedades__c> incapacidades = consultarIncapacidades(fechaFin);
        if(incapacidades.size()>0 && fechaInicio < fechaFin){
            
            if(Integer.valueOf(frecuenciaIndicador) == -1 ){
                diasTrabajados = 1;
            } else {
                diasTrabajados = diasMes * Integer.valueOf(frecuenciaIndicador);
            }
            resultado = '( Número de días de incapacidad por enfermedad laboral y común en el periodo / Número total de días comprendidos en el periodo ) * 100 : ';
            Double cantDiasIncapacidades = 0;
            for(SST_Registro_de_Novedades__c temp : incapacidades){
                if(!String.isEmpty(temp.Naturaleza__c) && temp.fecha_final__c >= fechaInicio){
                    Date fechaI = null;
                    Date fechaF = null;
                    if(temp.fecha_inicial__c >= fechaInicio){
                        fechaI = temp.fecha_inicial__c;
                    } else {
                        fechaI = fechaInicio;
                    }
                    if(temp.fecha_final__c <= fechaFin){
                        fechaF = temp.fecha_Final__c;
                    } else {
                        fechaF = fechaFin;
                    }
                    cantDiasIncapacidades = cantDiasIncapacidades + (fechaI.daysBetween(fechaF) + 1);
                }
            }
            Double cantidadFuncionariosActivos = consultarFuncionariosActivos(fechaInicio, fechaFin).size();
            Double diasTrabajoProgramados = diasTrabajados*cantidadFuncionariosActivos;
            resultado2 = '('+cantDiasIncapacidades + ' / '+ diasTrabajoProgramados+') * '+SST_Constantes.CONSTANTE_PORCENTAJE;
            if(cantDiasIncapacidades > 0){
                acm = cantDiasIncapacidades;
                acm = acm / diasTrabajoProgramados * SST_Constantes.CONSTANTE_PORCENTAJE;
                acm = acm.setScale(2);
                if(acm > cuenta.SST_Meta_ACM__c){
                    bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
                } else {
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                }
            } else {
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            }
        } else if(incapacidades.size()==0 && fechaInicio < fechaFin){
            resultado2 = '('+incapacidades.size() + ' / '+ diasTrabajados+') * '+SST_Constantes.CONSTANTE_PORCENTAJE;
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            
        }
        return acm;
    }
    
    //Método que consulta y retorna una variable double con el indicador FA
    public Decimal generarFA(Date fechaInicio, Date fechaFin){
        Decimal fa = 0;
        List <Contact> funcionariosActivos= consultarFuncionariosActivos(fechaInicio, fechaFin);
        if(funcionariosActivos.size()>0 && fechaInicio < fechaFin){
            
            List <SST_Registro_de_novedades__c> accidentesTrabajo = consultarAccidentesTrabajo(fechaInicio, fechaFin);
            Decimal cantidadAccidentesTrabajo = accidentesTrabajo.size();
            resultado = '( Cantidad de accidentes de trabajo en el periodo / Cantidad total de trabajadores activos en el periodo ) * 100 :';
            resultado2 = '('+cantidadAccidentesTrabajo + ' / '+ funcionariosActivos.size()+') * '+SST_Constantes.CONSTANTE_PORCENTAJE;
            if(cantidadAccidentesTrabajo == 0){
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            } else {
                fa = (cantidadAccidentesTrabajo / funcionariosActivos.size() * SST_Constantes.CONSTANTE_PORCENTAJE).setScale(2);
                if(fa > cuenta.SST_Meta_FA__c){
                    bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
                } else {
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                }
            }
        } else if(funcionariosActivos.size()==0 && fechaInicio < fechaFin){
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado'; 
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
        }
        return fa;    
    }
    
    //Método que consulta y retorna una variable double con el indicador IEL. SÓLO SE CUENTA 1 DIAGNÓSTICO POR PERSONA EN EL PERIODO CONSULTADO
    public Decimal generarIEL(Date fechaInicio, Date fechaFin){
        Decimal iel = 0;
        funcionariosActivos = consultarFuncionariosActivos(fechaInicio, fechaFin);
        if(funcionariosActivos.size()>0 && fechaInicio < fechaFin){
            
            Double cantSeguimientosPorEL = 0;
            resultado = '(Número de seguimientos de origen laboral nuevos en el periodo / Número de trabajadores activos en el periodo) * 100.000';
            List <SST_Seguimiento_ELC__c> seguimientosELC = consultarSeguimientosELC(fechaInicio,fechaFin);            
            if(seguimientosELC.size() > 0){
                /*Map <String,String> mapaSeguimientos = new Map <String,String>();
for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : seguimientosELC){
if(temp.Seguimiento_ELC__r.Fecha_dx__c >= fechaInicio && temp.Seguimiento_ELC__r.Fecha_dx__c <= fechaFin){
mapaSeguimientos.put(temp.Seguimiento_ELC__r.Funcionario__c+'-'+temp.Diagnostico_CIE10__c,temp.Seguimiento_ELC__r.Funcionario__c+'-'+temp.Diagnostico_CIE10__c);
}
}*/
                cantSeguimientosPorEL = seguimientosELC.size();
                iel = Decimal.valueOf((cantSeguimientosPorEL / funcionariosActivos.size()) * SST_Constantes.CONSTANTE_IEL_PEL).setScale(2);
                if(iel > cuenta.SST_Meta_IEL__c){
                    bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE; 
                } else {
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                }
                
            } else {
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            }
            resultado2 = '('+cantSeguimientosPorEL + ' / '+funcionariosActivos.size()+')'+' * 100.000 :';
        } 
        else if(funcionariosActivos.size()==0 && fechaInicio < fechaFin){
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
        }
        return iel;
    }
    
    //Método que consulta y retorna una variable double con el indicador IFA.  CUENTA LAS INCAPACIDADES Y AUSENTIMOS QUE SUBSISTAN EN EL PERIODO CALCULADO
    public Decimal generarIFA(Date fechaInicio, Date fechaFin){
        Decimal ifa = 0;
        if(consultarFuncionariosActivos(fechaInicio, fechaFin).size() > 0){
            List <SST_Registro_de_novedades__c> incapacidades = consultarIncapacidades(fechaFin);
            List <SST_Registro_de_novedades__c> ausentismos = consultarAusentismosPorSalud(fechaInicio, fechaFin);
            
            Double cantidadEventos = 0;
            Double horasTrabajo = calcularHorasTrabajo(fechaInicio, fechaFin, horasDia);
            if(incapacidades.size()==0 && ausentismos.size()==0 && fechaInicio < fechaFin){
                resultado = 'No se han registrado ausentismos por causa de salud en la empresa hasta el periodo seleccionado';
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            } else {
                resultado = '( Número de registros de ausentismos por causa de salud * Constante K ) / Horas hombre programadas : '; 
                if(incapacidades.size()>0){
                    for(SST_Registro_de_novedades__c temp : incapacidades){
                        if(temp.fecha_final__c >= fechaInicio){
                            cantidadEventos ++;
                        } 
                    }   
                }
                if(ausentismos.size()>0){
                    for(SST_Registro_de_novedades__c temp : ausentismos){
                        if(temp.fecha_final__c >= fechaInicio){
                            cantidadEventos ++;
                        } 
                    }   
                }
                resultado2 = cantidadEventos + ' * '+SST_Constantes.K_INDICADORES + ' / ' + horasTrabajo;
                if(cantidadEventos == 0){    
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                } else {
                    ifa = Decimal.valueOf((cantidadEventos * SST_Constantes.K_INDICADORES / horasTrabajo)).setScale(2);
                    if(ifa > cuenta.SST_Meta_IFA__c){
                        bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
                    } else {
                        bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                    }
                }
            }
        } else {
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE; 
        }
        return ifa;
    }
    
    //Método que consulta y retorna una variable double con el indicador IFAT
    public Decimal generarIFAT(Date fechaInicio, Date fechaFin){
        Decimal ifat = 0;
        Double horasHombre = calcularHorasHombre(fechaInicio, fechaFin); 
        if(horasHombre>0 && fechaInicio < fechaFin){
            
            List <SST_Registro_de_novedades__c> accidentesTrabajo = consultarAccidentesTrabajo(fechaInicio, fechaFin);
            Double cantAccidentesTrabajo = accidentesTrabajo.size();
            resultado = '( Cantidad de accidentes de trabajo en el periodo / Número de horas hombre trabajadas en el periodo ) * Constante K : ';
            resultado2 = '('+cantAccidentesTrabajo + ' / '+Decimal.valueOf(horasHombre).setScale(2)+') * '+SST_Constantes.K_INDICADORES;
            
            
            if(cantAccidentesTrabajo > 0){
                ifat = cantAccidentesTrabajo * SST_Constantes.K_INDICADORES;
                ifat = ifat / horasHombre;
                ifat = ifat.setScale(2);
                if(ifat > cuenta.SST_Meta_IFAT__c){
                    bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
                } else {
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                }
            } else {
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            }
        } else if(horasHombre==0 && fechaInicio < fechaFin) {
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
        }
        return ifat;
    }
    
    //Método que consulta y retorna una variable double con el indicador IFIAT
    public Decimal generarIFIAT(Date fechaInicio, Date fechaFin){
        Decimal ifiat = 0;
        Double horasHombre = calcularHorasHombre(fechaInicio, fechaFin);
        if(horasHombre>0 && fechaInicio < fechaFin){
            List <SST_Registro_de_novedades__c> incapacidades = consultarIncapacidadesIFIAT(fechaInicio,fechaFin);
            resultado = '( Cantidad de accidentes de trabajo con incapacidad en el periodo / Número de horas hombre trabajadas en el periodo ) * Constante K : ';
            if(incapacidades.size() > 0){
                ifiat = incapacidades.size() * SST_Constantes.K_INDICADORES;
                ifiat = ifiat / horasHombre;
                ifiat = ifiat.setScale(2);
                resultado2 = '('+incapacidades.size() + ' / '+Decimal.valueOf(horasHombre).setScale(2)+') * '+SST_Constantes.K_INDICADORES;
                if(ifiat > cuenta.SST_Meta_IFIAT__c){
                    bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
                } else {
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                }
                
            } else {
                resultado2 = '('+incapacidades.size() + ' / '+Decimal.valueOf(horasHombre).setScale(2)+') * '+SST_Constantes.K_INDICADORES;
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            }
        } else if(horasHombre==0 && fechaInicio < fechaFin){
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
        }
        return ifiat;
    }
    
    //Método que consulta y retorna una variable double con el indicador ILIAT
    public Decimal generarILIAT(Date fechaInicio, Date fechaFin){
        Decimal iliat = null;
        if(fechaInicio < fechaFin){
            iliat = 0;    
            Decimal ifiat = generarIFIAT(fechaInicio, fechaFin);
            Decimal isat = generarISAT(fechaInicio, fechaFin); 
            resultado = '( Indicador IFIAT * Indicador ISAT ) / 1000 : ';
            resultado2 = '('+ifiat + ' * '+isat+') / '+SST_Constantes.DENOMINADOR_INDICADOR_ILIAT;
            iliat = ifiat * isat;
            iliat = iliat / SST_Constantes.DENOMINADOR_INDICADOR_ILIAT;
            iliat = iliat.setScale(2);
            if(iliat > cuenta.SST_Meta_ILIAT__c){
                bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
            } else {
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            }
        }
        return iliat;
    }
    
    //Método que consulta y retorna una variable double con el indicador ISAT.  SE SUMAN EN CADA PERIODO, LOS DÍAS CORRESPONDIENTES
    public Decimal generarISAT(Date fechaInicio, Date fechaFin){
        Decimal isat = 0;
        Double horasHombre = 0;
        horasHombre = calcularHorasHombre(fechaInicio, fechaFin);
        if(horasHombre>0 && fechaInicio < fechaFin){
            List <SST_Registro_de_Novedades__c> incapacidadesPorAT = consultarIncapacidades(fechaFin);
            resultado = '( Número de días de incapacidad por accidentes de trabajo en el periodo / Número de horas hombre trabajadas en el periodo ) * Constante K : ';
            if(incapacidadesPorAT.size()> 0){
                Double cantDiasIncapacidad = 0;
                for(SST_Registro_de_Novedades__c temp : incapacidadesPorAT){
                    if(!string.isEmpty(temp.Naturaleza__c) && temp.Naturaleza__c.equals(SST_Constantes.NATURALEZA_ACCIDENTES) && temp.fecha_final__c >= fechaInicio){
                        Date fechaI = null;
                        Date fechaF = null;
                        if(temp.fecha_inicial__c >= fechaInicio){
                            fechaI = temp.fecha_inicial__c;
                        } else {
                            fechaI = fechaInicio;
                        }
                        if(temp.fecha_final__c <= fechaFin){
                            fechaF = temp.fecha_Final__c;
                        } else {
                            fechaF = fechaFin;
                        }
                        cantDiasIncapacidad = cantDiasIncapacidad + (fechaI.daysBetween(fechaF) + 1);
                    }
                }
                resultado2 = '('+cantDiasIncapacidad + ' / '+Decimal.valueOf(horasHombre).setScale(2)+') * '+SST_Constantes.K_INDICADORES;
                if(cantDiasIncapacidad > 0){
                    isat = cantDiasIncapacidad * SST_Constantes.K_INDICADORES;
                    isat = isat / horasHombre;
                    isat =  isat.setScale(2);                    
                    if(isat > cuenta.SST_Meta_ISAT__c){
                        bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
                    } else {
                        bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                    }
                } else {
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                }
            } else {
                resultado2 = '('+incapacidadesPorAT.size() + ' / '+Decimal.valueOf(horasHombre).setScale(2)+') * '+SST_Constantes.K_INDICADORES;
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            } 
        } else if(horasHombre==0 && fechaInicio < fechaFin){
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
        }
        return isat;
    }
    
    //Método que consulta y retorna una variable double con el indicador MAT
    public Decimal generarMAT(Date fechaInicio, Date fechaFin){
        Decimal mat = 0;
        List <SST_Registro_de_novedades__c> accidentesTrabajo = consultarAccidentesTrabajo(fechaInicio, fechaFin);
        if(accidentesTrabajo.size()>0 && fechaInicio < fechaFin){
            resultado = '( Cantidad de accidentes de trabajo mortales en el periodo / Número total de accidentes de trabajo en el periodo ) * 100 : ';
            Integer count = 0;
            for(SST_Registro_de_novedades__c temp : accidentesTrabajo){
                if(!String.isEmpty(temp.Tipo__c) && temp.Tipo__c.equals(SST_Constantes.TIPO_MORTAL)){
                    count++; 
                }
            }
            resultado2 = '('+count + ' / '+ accidentesTrabajo.size()+') * '+SST_Constantes.CONSTANTE_PORCENTAJE;
            mat = count * SST_Constantes.CONSTANTE_PORCENTAJE;
            mat = mat / accidentesTrabajo.size();
            mat = mat.setScale(2);            
            if(mat > cuenta.SST_Meta_MAT__c){
                bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
            } else {
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            }
        } else if(accidentesTrabajo.size()==0 && fechaInicio < fechaFin){
            resultado = 'No se han registrado accidentes de trabajo en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
        } 
        return mat;
    }
    
    //Método que consulta y retorna una variable double con el indicador PEL.  SÓLO SUMA 1 DIAGNÓSTICO POR EMPLEADO
    public Decimal generarPEL(Date fechaInicio, Date fechaFin){
        Decimal pel = 0;
        funcionariosActivos = consultarFuncionariosActivos(fechaInicio, fechaFin);
        if(funcionariosActivos.size()>0 && fechaInicio < fechaFin){
            
            Double cantSeguimientosPorEL = 0;
            resultado = '(Cantidad de seguimientos de origen laboral antiguos y nuevos en el periodo / Número de trabajadores activos en el periodo) * 100.000 : ';
            List <SST_Seguimiento_ELC__c> seguimientosELC = consultarSeguimientosELC(fechaFin);            
            if(seguimientosELC.size() > 0){
                /*Map <String,String> mapaSeguimientos = new Map <String,String>();
for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : seguimientosELC){
mapaSeguimientos.put(temp.Seguimiento_ELC__r.Funcionario__c+'-'+temp.Diagnostico_CIE10__c,temp.Seguimiento_ELC__r.Funcionario__c+'-'+temp.Diagnostico_CIE10__c);
}*/
                cantSeguimientosPorEL = seguimientosELC.size();
                pel = Decimal.valueOf((cantSeguimientosPorEL / funcionariosActivos.size()) * SST_Constantes.CONSTANTE_IEL_PEL).setScale(2);
                if(pel > cuenta.SST_Meta_PEL__c){
                    bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE; 
                } else {
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                }
                
            } else {
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            }
            resultado2 = '('+cantSeguimientosPorEL + ' / '+funcionariosActivos.size()+')'+' * 100.000';
        } 
        else if(funcionariosActivos.size()==0 && fechaInicio < fechaFin){
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
        }
        return pel;
    }
    
    //Método que consulta y retorna una variable double con el indicador PTP. SE SUMAN LAS HORAS CORRESPONDIENTES AL PERIODO CONSULTADO
    public Decimal generarPTP(Date fechaInicio, Date fechaFin){
        Decimal ptp = 0;
        if(consultarFuncionariosActivos(fechaInicio, fechaFin).size() > 0){
            List <SST_Registro_de_novedades__c> incapacidades = consultarIncapacidades(fechaFin);
            List <SST_Registro_de_novedades__c> ausentismos = consultarAusentismosPorSalud(fechaInicio, fechaFin);
            
            Double horasAusencia = 0;
            Double horasTrabajo = calcularHorasTrabajo(fechaInicio, fechaFin, horasDia);
            if(incapacidades.size()==0 && ausentismos.size()==0 && fechaInicio < fechaFin){
                resultado = 'No se han registrado ausentismos por causa de salud en la empresa hasta el periodo seleccionado';
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            } else {
                resultado = '( Número de horas perdidas en el periodo por causa de salud * 100 ) / Horas hombre programadas : '; 
                if(incapacidades.size()>0 && fechaInicio < fechaFin){
                    for(SST_Registro_de_novedades__c temp : incapacidades){
                        Double horas = 0;
                        if(temp.fecha_final__c >= fechaInicio){
                            Date fechaI = null;
                            Date fechaF = null;
                            if(temp.fecha_inicial__c >= fechaInicio){
                                fechaI = temp.fecha_inicial__c;
                            } else {
                                fechaI = fechaInicio;
                            }
                            if(temp.fecha_final__c <= fechaFin){
                                fechaF = temp.fecha_Final__c;
                            } else {
                                fechaF = fechaFin;
                            }
                            horas = (fechaI.daysBetween(fechaF) + 1) * horasDia;
                        } 
                        horasAusencia = horasAusencia + horas;
                    }
                } 
                if(ausentismos.size()>0 && fechaInicio < fechaFin){
                    for(SST_Registro_de_novedades__c temp : ausentismos){
                        Double horas = 0;
                        if(temp.fecha_final__c >= fechaInicio){
                            Date fechaI = null;
                            Date fechaF = null;
                            Double razonDia = 0;
                            if(temp.fecha_inicial__c == temp.fecha_final__c){
                                horas = temp.Cantidad_Horas__c;    
                            } else {
                                razonDia = (temp.fecha_inicial__c.daysBetween(temp.fecha_final__c) + 1) / temp.Cantidad_Horas__c;
                                if(temp.fecha_inicial__c >= fechaInicio){
                                    fechaI = temp.fecha_inicial__c;
                                } else {
                                    fechaI = fechaInicio;
                                }
                                if(temp.fecha_final__c <= fechaFin){
                                    fechaF = temp.fecha_Final__c;
                                } else {
                                    fechaF = fechaFin;
                                }
                                horas = (fechaI.daysBetween(fechaF) + 1) * razonDia;
                            }
                        } 
                        horasAusencia = horasAusencia + horas;
                    }
                } 
                
                resultado2 = horasAusencia + ' * '+SST_Constantes.CONSTANTE_PORCENTAJE + ' / ' + horasTrabajo;
                if(horasAusencia == 0){    
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                } else {
                    ptp = Decimal.valueOf((horasAusencia * SST_Constantes.CONSTANTE_PORCENTAJE / horasTrabajo)).setScale(2);
                    if(ptp > cuenta.SST_Meta_PTP__c){
                        bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
                    } else {
                        bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                    }
                }
            }
        } else {
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE; 
        }
        return ptp;
    }
    
    //Método que consulta y retorna una variable double con el indicador SA.  SE SUMAN LOS DÍAS QUE SE ABARQUEN EN EL PERIODO
    public Decimal generarSA(Date fechaInicio, Date fechaFin){
        Decimal sa = 0;
        List <Contact> funcionariosActivos= consultarFuncionariosActivos(fechaInicio, fechaFin);
        if(funcionariosActivos.size()>0 && fechaInicio < fechaFin){
            List <SST_Registro_de_Novedades__c> incapacidadesPorAT = consultarIncapacidades(fechaFin);
            resultado = '( Cantidad de días de incapacidad por accidentes de trabajo en el periodo + Cantidad de días cargados en el periodo por accidentes de invalidez o muerte / Cantidad total de trabajadores activos en el periodo ) * 100';
            Double cantDiasIncapacidad = 0;
            if(incapacidadesPorAT.size()> 0){
                for(SST_Registro_de_Novedades__c temp : incapacidadesPorAT){
                    if(!string.isEmpty(temp.Naturaleza__c) && temp.Naturaleza__c.equals(SST_Constantes.NATURALEZA_ACCIDENTES) && temp.fecha_final__c >= fechaInicio){
                        Date fechaI = null;
                        Date fechaF = null;
                        if(temp.fecha_inicial__c >= fechaInicio){
                            fechaI = temp.fecha_inicial__c;
                        } else {
                            fechaI = fechaInicio;
                        }
                        if(temp.fecha_final__c <= fechaFin){
                            fechaF = temp.fecha_Final__c;
                        } else {
                            fechaF = fechaFin;
                        }
                        cantDiasIncapacidad = cantDiasIncapacidad + (fechaI.daysBetween(fechaF) + 1);
                    }
                }
            } 
            List <SST_Registro_de_novedades__c> accidentesTrabajo = consultarAccidentesTrabajo(fechaInicio, fechaFin);
            if(accidentesTrabajo.size()>0 && fechaInicio < fechaFin){
                Integer count = 0;
                for(SST_Registro_de_novedades__c temp : accidentesTrabajo){
                    if(!String.isEmpty(temp.Tipo__c) && temp.Tipo__c.equals(SST_Constantes.TIPO_MORTAL) && temp.Dias_cargados__c<>null){
                        cantDiasIncapacidad = cantDiasIncapacidad + Integer.valueOf(temp.Dias_cargados__c);
                    }
                }
            }
            if(cantDiasIncapacidad>0){
                resultado2 = '('+cantDiasIncapacidad + ' / '+funcionariosActivos.size()+') * '+SST_Constantes.CONSTANTE_PORCENTAJE;
                if(cantDiasIncapacidad > 0){
                    sa = cantDiasIncapacidad * SST_Constantes.CONSTANTE_PORCENTAJE;
                    sa = sa / funcionariosActivos.size();
                    sa =  sa.setScale(2);                    
                    if(sa > cuenta.SST_Meta_SA__c){
                        bakcgroundIndicador = SST_Constantes.COLOR_NO_CUMPLE;
                    } else {
                        bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                    }
                } else {
                    bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
                }
            } else {
                resultado2 = '('+incapacidadesPorAT.size() + ' / '+funcionariosActivos.size()+') * '+SST_Constantes.CONSTANTE_PORCENTAJE;
                bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
            } 
        } else if(funcionariosActivos.size()==0 && fechaInicio < fechaFin){
            resultado = 'No hubo funcionarios activos en la empresa para el periodo seleccionado';
            bakcgroundIndicador = SST_Constantes.COLOR_CUMPLE;
        }
        return sa;
    }
    
    //Método para obtener la cantidad de accidentes de trabajo ocurridos en el periodo seleccionado seleccionado
    public List <SST_Registro_de_novedades__c> consultarAccidentesTrabajo (Date fechaInicio, Date fechaFin){
        List <SST_Registro_de_novedades__c> accidentesTrabajo = new List <SST_Registro_de_novedades__c>();
        accidentesTrabajo = [select id, tipo__c, Dias_cargados__c from SST_Registro_de_novedades__c where funcionario__r.sst_Empresa__c in:empresas and recordTypeId in: recordTypeAccidentes and fecha_inicial__c >=: fechaInicio and fecha_inicial__c <=: fechaFin ];
        return accidentesTrabajo;
    }
    
    //Método para obtener la lista con el total de incapacidades existentes hasta el periodo seleccionado
    public List <SST_Registro_de_Novedades__c> consultarIncapacidades(Date fechaFin){
        List <SST_Registro_de_Novedades__c> incapacidades = new List <SST_Registro_de_Novedades__c>();
        incapacidades = [select id, naturaleza__c, Fecha_Inicial__c, fecha_final__c, numero_dias__c from SST_Registro_de_Novedades__c where funcionario__r.sst_Empresa__c in:empresas and recordTypeId IN : recordTypeIncapacidades and Fecha_Inicial__c <=: fechaFin];
        return incapacidades;
    }
    
    //Método para obtener la lista con el total de incapacidades existentes para el periodo seleccionado que no tengan prorroga y sean accidentes
    public List <SST_Registro_de_Novedades__c> consultarIncapacidadesIFIAT(Date fechaInicio,Date fechaFin){
        List <SST_Registro_de_Novedades__c> incapacidades = new List <SST_Registro_de_Novedades__c>();
        incapacidades = [select id, naturaleza__c, Fecha_Inicial__c, fecha_final__c, numero_dias__c from SST_Registro_de_Novedades__c where funcionario__r.sst_Empresa__c in:empresas and recordTypeId IN : recordTypeIncapacidades and Fecha_Inicial__c >=: fechaInicio and Fecha_Inicial__c <=: fechaFin AND tipo__c !='PRORROGA' AND naturaleza__c=:SST_Constantes.NATURALEZA_ACCIDENTES ];
        return incapacidades;
    }
    
    //Método para obtener la cantidad de ausentismos de tipo Permiso Médico en el periodo seleccionado
    public List <SST_Registro_de_novedades__c> consultarAusentismosPorSalud (Date fechaInicio, Date fechaFin){
        List <SST_Registro_de_novedades__c> ausentismosSalud = new List <SST_Registro_de_novedades__c>();
        ausentismosSalud = [select id, Cantidad_Horas__c, fecha_inicial__c, fecha_final__c from SST_Registro_de_novedades__c where funcionario__r.sst_Empresa__c in:empresas and fecha_inicial__c <=: fechaFin and recordTypeId in: recordTypeAusentismos and Tipo__c =: SST_Constantes.PERMISO_MEDICO];
        return ausentismosSalud;
    }
    
    //Método para obtener la lista con los datos de los funcionarios activos en el periodo seleccionado
    public List <Contact> consultarFuncionariosActivos(Date fechaInicio, Date fechaFin){
        List <Contact> funcionariosActivos= new List <Contact>();
        funcionariosActivos = [select id, name, sst_fecha_ingreso__c, sst_fecha_retiro__c from contact where SST_Empresa__c in:empresas and recordTypeId in: recordTypeFuncionario and sst_fecha_ingreso__c <=: fechafin and (sst_fecha_retiro__c =:null OR sst_fecha_retiro__c >=: fechaInicio)];
        return funcionariosActivos;
    }
    
    //Método para obtener la lista con los seguimientos ELC creados hasta el periodo seleccionado
    public List <SST_Seguimiento_ELC__c> consultarSeguimientosELC(Date fechaFin){
        List <SST_Seguimiento_ELC__c> listaSeguimientosELC = new List <SST_Seguimiento_ELC__c>();
        List <Id> idFuncionarios = new List <Id>();
        for(Contact temp : funcionariosActivos){
            idFuncionarios.add(temp.id);
        }
        listaSeguimientosELC = [select id from SST_Seguimiento_ELC__c where funcionario__c in:idFuncionarios and Origen__c =: SST_Constantes.LABORAL and Fecha_dx__c <=: fechaFin];
        return listaSeguimientosELC;
    }
    //Método para obtener la lista con los seguimientos ELC creados hasta el periodo seleccionado
    public List <SST_Seguimiento_ELC__c> consultarSeguimientosELC(Date fechaInicio,Date fechaFin){
        List <SST_Seguimiento_ELC__c> listaSeguimientosELC = new List <SST_Seguimiento_ELC__c>();
        List <Id> idFuncionarios = new List <Id>();
        for(Contact temp : funcionariosActivos){
            idFuncionarios.add(temp.id);
        }
        listaSeguimientosELC = [select id from SST_Seguimiento_ELC__c where funcionario__c in:idFuncionarios and Origen__c =: SST_Constantes.LABORAL and Fecha_dx__c <=: fechaFin and Fecha_dx__c >=: fechaInicio];
        return listaSeguimientosELC;
    }
    
    //Método para calcular las horas de trabajo en el periodo seleccionado.
    private Double calcularHorasTrabajo(Date fechaInicio, Date fechaFin, Decimal horasDia){
        Double horasTrabajo = 0;
        if(fechaInicio < fechaFin){
            //Consulta para obtener todos los funcionarios que se encontraban activos en el periodo seleccionado
            List <Contact> funcionariosActivos= consultarFuncionariosActivos(fechaInicio, fechaFin);
            
            //Si la frecuencia de medición del indicador es diaria, se multiplica la cantidad de horas por día por el total de funcionarios activos para obtener las horas de trabajo
            if(Integer.valueOf(frecuenciaIndicador) == -1){
                horasTrabajo = funcionariosActivos.size() * horasDia;       
            } else {
                //Se recorre la lista de funcionarios para obtener la cantidad de días laborados por cada uno en el 
                //periodo seleccionado, y se multiplican los días por la cantidad de horas día
                if(funcionariosActivos.size()>0){
                    for(Contact contacto : funcionariosActivos){
                        Date fechaIngresoTemp = null;
                        Date fechaRetiroTemp = null;
                        if(contacto.sst_fecha_ingreso__c <= fechaInicio){
                            fechaIngresoTemp = fechaInicio;
                        } else if(contacto.sst_fecha_ingreso__c > fechaInicio){
                            fechaIngresoTemp = contacto.sst_fecha_ingreso__c;
                        }
                        if(contacto.sst_fecha_retiro__c == null || (contacto.sst_fecha_retiro__c <> null && contacto.sst_fecha_retiro__c >= fechaFin)){
                            fechaRetiroTemp = fechaFin;
                        } else if(contacto.sst_fecha_retiro__c <> null && contacto.sst_fecha_retiro__c < fechaFin){
                            fechaRetiroTemp = contacto.sst_fecha_retiro__c;
                        }
                        horasTrabajo = horasTrabajo + (calcularCantidadDiasEstandar(fechaIngresoTemp,fechaRetiroTemp) * horasDia);
                    } 
                }  
            }
        }
        return horasTrabajo;
    }
    
    //Método para calcular las horas hombre realmente trabajadas en el periodo seleccionado (horas de trabajo, más horas extras, menos ausentismos)
    private Double calcularHorasHombre(Date fechaInicio, Date fechaFin){
        Double horasHombre = calcularHorasTrabajo(fechaInicio, fechaFin, cuenta.SST_horas_habiles__c);
        System.debug('horasHombre'+horasHombre);
        if(horasHombre > 0){
            String mesInicio = String.valueOf(fechaInicio.month());
            String mesFin = String.valueOf(fechaFin.month());
            Integer anioInicio = fechaInicio.year();
            Integer anioFin = fechaFin.year();
            List <String> meses = new List <String>();
            if(mesInicio <> mesFin){
                Integer flag = fechaInicio.month();
                while(flag <= fechaFin.month()){
                    meses.add(String.valueOf(flag));
                    flag = flag+1;
                }
            } else {
                meses.add(mesInicio);
            }
            
            //Consulta para obtener la cantidad de horas extras reportadas para el mes y año seleccionado
            List<AggregateResult>  horasExtras = [SELECT SUM(cantidad_horas__c) total FROM SST_Hora_extra__c WHERE funcionario__r.sst_Empresa__c in:empresas and anio__c >=: anioInicio and anio__c <=: anioFin and mes__c in: meses];
            Double totalHorasExtras = 0;
            if(horasExtras.get(0).get('total') <> null){
                totalHorasExtras = Double.valueOf(horasExtras.get(0).get('total'));
            }  
            Double horasAusentismo = 0;            
            Double horasIncapacidad = 0;
            //Consulta para obtener la cantidad de horas de ausentismos e incapacidades/licencias que subsistend dentro del periodo seleccionado
            for(SST_Registro_de_Novedades__c temp : [select id,funcionario__r.name, Cantidad_Horas__c, fecha_inicial__c, fecha_final__c, naturaleza__c, numero_dias__c from SST_Registro_de_Novedades__c where funcionario__r.sst_Empresa__c in:empresas and recordTypeId IN : recordTypeAusentismos and((fecha_inicial__c <= :fechaInicio AND fecha_final__c>=:fechaFin) OR(fecha_final__c >= :fechaInicio AND fecha_final__c<=:fechaFin)OR(fecha_inicial__c >= :fechaInicio AND fecha_inicial__c<=:fechaFin)) order by funcionario__r.name]){
                Double horas = 0;
                if(temp.naturaleza__c <> null ){
                    Date fechaI = null;
                    Date fechaF = null;
                    if(temp.fecha_inicial__c >= fechaInicio){
                        fechaI = temp.fecha_inicial__c;
                    } else {
                        fechaI = fechaInicio;
                    }
                    if(temp.fecha_final__c <= fechaFin){
                        fechaF = temp.fecha_Final__c;
                    } else {
                        fechaF = fechaFin;
                    }
                    horas = (fechaI.daysBetween(fechaF) + 1) * horasDia;
                    horasIncapacidad +=horas;
                } else {
                    Date fechaI = null;
                    Date fechaF = null;
                    Double razonDia = 0;
                    if(temp.fecha_inicial__c == temp.fecha_final__c){
                        horas = temp.Cantidad_Horas__c;    
                    } else {
                        razonDia = temp.Cantidad_Horas__c/(temp.fecha_inicial__c.daysBetween(temp.fecha_final__c) + 1) ;
                        if(temp.fecha_inicial__c >= fechaInicio){
                            fechaI = temp.fecha_inicial__c;
                        } else {
                            fechaI = fechaInicio;
                        }
                        if(temp.fecha_final__c <= fechaFin){
                            fechaF = temp.fecha_Final__c;
                        } else {
                            fechaF = fechaFin;
                        }
                        horas = (fechaI.daysBetween(fechaF) + 1) * razonDia;
                    }
                    System.debug('horas ausentismo'+temp.id+'-'+horas);
                }
                
                horasAusentismo = horasAusentismo + horas;
            }
            System.debug('horasAusentismo'+horasAusentismo);
            //Al las horas hombre acumuladas se suman las horas extras y se restan las horas de ausentismos
            //para obtener la cantidad total de horas hombre trabajadas en el periodo seleccionado
            horasHombre = horasHombre + totalHorasExtras - horasAusentismo;
        }
        return horasHombre;
    }
    
    //Método para consultar la meta configurada y la frecuencia de medición, y calcular la fecha de inicio para el indicador seleccionado
    public void consultarParametrosIndicador(){
        fechaInicio = null;
        if(indicadorSelect!=null && indicadorSelect <> '0'){
            map <String,String> mapaFrecuencia = new map <String,String>();
            Schema.DescribeFieldResult campoFrecuencia = Account.SST_Frecuencia_IEL__c.getDescribe();
            List<Schema.PicklistEntry> picklistFrecuencia = campoFrecuencia.getPicklistValues();
            for( Schema.PicklistEntry pickItem : picklistFrecuencia){
                mapaFrecuencia.put(pickItem.getValue(),pickItem.getLabel());
            }
            if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(0))){
                if(cuenta.SST_META_ACM__c == null || cuenta.SST_Frecuencia_ACM__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_ACM__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_ACM__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(1))){
                if(cuenta.SST_META_FA__c == null || cuenta.SST_Frecuencia_FA__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_FA__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_FA__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(2))){
                if(cuenta.SST_META_IEL__c == null || cuenta.SST_Frecuencia_IEL__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_IEL__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_IEL__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(3))){
                if(cuenta.SST_META_IFA__c == null || cuenta.SST_Frecuencia_IFA__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_IFA__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_IFA__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(4))){
                if(cuenta.SST_META_IFAT__c == null || cuenta.SST_Frecuencia_IFAT__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_IFAT__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_IFAT__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(5))){
                if(cuenta.SST_META_IFIAT__c == null || cuenta.SST_Frecuencia_IFIAT__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_IFIAT__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_IFIAT__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(6))){
                if(cuenta.SST_META_ILIAT__c == null || cuenta.SST_Frecuencia_ILIAT__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_ILIAT__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_ILIAT__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(7))){
                if(cuenta.SST_META_ISAT__c == null || cuenta.SST_Frecuencia_ISAT__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_ISAT__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_ISAT__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(8))){
                if(cuenta.SST_META_MAT__c == null || cuenta.SST_Frecuencia_MAT__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_MAT__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_MAT__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(9))){
                if(cuenta.SST_META_PEL__c == null || cuenta.SST_Frecuencia_PEL__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_PEL__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_PEL__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(10))){
                if(cuenta.SST_META_PTP__c == null || cuenta.SST_Frecuencia_PTP__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_PTP__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_PTP__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            else if(mapaIndicadores.get(indicadorSelect).equals(valuesMapa.get(11))){
                if(cuenta.SST_META_SA__c == null || cuenta.SST_Frecuencia_SA__c == null){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No se ha configurado una meta o frecuencia de medición para el indicador seleccionado.  Verifique y complete la parametrización de los indicadores de resultado para continuar la consulta'));
                } else {
                    metaIndicador = cuenta.SST_META_SA__c;
                    frecuenciaIndicador = cuenta.SST_Frecuencia_SA__c;
                    frecuencia = 'Frecuencia: '+mapaFrecuencia.get(frecuenciaIndicador);
                }
            }
            
            if(metaIndicador <> null && frecuenciaIndicador <> null){
                //Se verifica si el indicador tiene frecuencia parametrizada diferente a Diaria
                if(!frecuenciaIndicador.equals('-1')){
                    //Se verifica si se ha seleccionado como fecha de fin el último día del mes
                    Date fechaTemp = fechaFin.addMonths(1);
                    fechaTemp = fechaTemp.toStartOfMonth();
                    fechaTemp = fechaTemp.addDays(-1);
                    
                    //Si se ha seleccionado el último día del mes, se resta a la fecha de fin la cantidad de meses según la frecuencia 
                    //de medición parametrizada, y se calcula como fecha de inicio el día 1 del mes correspondiente
                    if(fechaTemp == fechaFin){
                        Integer mes = Integer.valueOf(frecuenciaIndicador) * -1;
                        fechaInicio = fechaFin.addMonths(1);
                        fechaInicio = fechaInicio.toStartOfMonth();
                        fechaInicio = fechaInicio.addMonths(mes);
                    } 
                    //Si no se ha seleccionado el último día del mes, se resta a la fecha de fin la cantidad de meses según la frecuencia 
                    //de medición parametrizada, y se calcula como fecha de inicio en el mes correspondiente el mismo número de día de la fecha de fin
                    else {
                        Integer mes = Integer.valueOf(frecuenciaIndicador) * -1;
                        fechaInicio = fechaFin.addMonths(mes);
                        fechaInicio = fechaInicio.addDays(1);
                    }
                } 
                //Si la frecuencia de medición del indicador es diaria, se resta un día a la fecha de fin para calcular la fecha de inicio
                else {
                    Integer dias = Integer.valueOf(frecuenciaIndicador);
                    fechaInicio = fechaFin.addDays(dias);
                }
                periodo = String.valueOf(fechaInicio) + ' --- ' + String.valueOf(fechaFin);    
            } else {
                fechaInicio = fechaFin;
            }
            
        }
    }
    
    //Método para consultar los datos de la empresa o cuenta principal
    public void consultarEmpresa(){
        if(!esAdmin || SST_Constantes.getCantidadEmpresas() == 1){
            cuenta = SST_Constantes.consultarDatosEmpresa(SST_Constantes.getEmpresaAutenticada()); 
            if(cuenta == null){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No hay ninguna empresa configurada como cuenta principal.  Verifique y complete la configuración de los datos de la empresa para consultar los indicadores'));
                botonActivo = false;
            } 
        } else {
            cuenta = SST_Constantes.consultarDatosMultiempresa();
            if(cuenta == null){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No hay ninguna empresa configurada como cuenta principal o no se ha seleccionado la empresa para el cálculo de indicadores globales.  Verifique y complete la configuración de cuentas necesaria para consultar los indicadores'));
                botonActivo = false;
            } 
        }
    }
    
    //Método que retorna una lista de Id's de recordType de un objeto, dado un SobjectType y una lista con los nombres de los tipos de registro
    private List <RecordType> consultarRecordType(String nameObjeto, List<String> nameRegistro){
        List <RecordType> recordTypeConsultado = [SELECT Id, Name, SobjectType FROM RecordType where SobjectType = :nameObjeto and name in : nameRegistro order by name];
        return recordTypeConsultado;
    }
    
    //Método para llenar el selectOption con la lista de indicadores de resultado disponibles
    public List<SelectOption> getIndicadores(){
        List<SelectOption> indicadores = new List<SelectOption>();
        indicadores.add(new SelectOption('0',SST_Constantes.ITEM_VACIO_PICKLIST));
        for(String key : mapaIndicadores.Keyset()){
            indicadores.add(new SelectOption(key,mapaIndicadores.get(key)));
        }
        return indicadores;
    }
    
    //Método que devuelve la cantidad de días contenidos entre dos fechas, contando cada mes de 30 días,
    //y cada día de 8 horas, y teniendo en cuenta la frecuencia del indicador seleccionado
    private Integer calcularCantidadDiasEstandar (Date fechaInicioConsulta, Date fechaFinConsulta){
        Integer cantidadDias = 0;
        Date finMes = fechaFin.addMonths(1);
        finMes = finMes.toStartOfMonth();
        finMes = finMes.addDays(-1);
        if(fechaInicioConsulta == fechaInicio && (fechaFinConsulta == fechaFin || 
                                                  (fechaFinConsulta <> fechaFin && finMes == fechaFin && (date.daysInMonth(fechaFinConsulta.year(),fechaFinConsulta.month()) > diasMes && fechaFinConsulta.day() == 30)))){
                                                      cantidadDias = Integer.valueOf(frecuenciaIndicador) * diasMes;
                                                  } else {
                                                      Integer diasMesInicio = 0;
                                                      Integer diasMesFin = 0;
                                                      if(fechaInicioConsulta.month() <> fechaFinConsulta.month()){
                                                          //Se verifica si la fecha de inicio a consultar corresponde a un mes con cantidad de días diferente a 30,
                                                          //y de ser así, se verifica si dicha fecha corresponde al último día del ems
                                                          if(date.daysInMonth(fechaInicioConsulta.year(),fechaInicioConsulta.month()) > diasMes && fechaInicioConsulta.day() == 31){
                                                              diasMesInicio = 1;
                                                          } else if(date.daysInMonth(fechaInicioConsulta.year(),fechaInicioConsulta.month()) < diasMes && fechaInicioConsulta.day() == 29){
                                                              diasMesInicio = 2;
                                                          } else {
                                                              diasMesInicio = diasMes - fechaInicioConsulta.day() + 1;
                                                          }
                                                          
                                                          //Se verifica si la fecha de fin a consultar corresponde a un mes con cantidad de días diferente a 30,
                                                          //y de ser así, se verifica si dicha fecha corresponde al último día del mes
                                                          if(date.daysInMonth(fechaFinConsulta.year(),fechaFinConsulta.month()) > diasMes && fechaFinConsulta.day() >= 30){
                                                              diasMesFin = diasMes;
                                                          } else {
                                                              diasMesFin = fechaFinConsulta.day();
                                                          }
                                                          
                                                          if(fechaFinConsulta.month() - fechaInicioConsulta.month() <= 1){
                                                              cantidadDias = diasMesInicio + diasMesFin;
                                                          } else {
                                                              cantidadDias = diasMesInicio + diasMesFin + (diasMes *(fechaFinConsulta.month() - fechaInicioConsulta.month() - 1));
                                                          }
                                                      } else {
                                                          if(fechaFinConsulta == fechaFin && finMes == fechaFin){
                                                              cantidadDias = diasMes - fechaInicioConsulta.day() +1;
                                                          } else {
                                                              cantidadDias = fechaInicioConsulta.daysBetween(fechaFinConsulta) +1;   
                                                          }
                                                      }
                                                  }
        return cantidadDias;
    }
    private void consultarAnalisisIndicadores(){
        indicadoresExistentes = new List <DTOLista>();
        String empresaIndicador = '';
        if(!esAdmin || SST_Constantes.getCantidadEmpresas() == 1){
            empresaIndicador = empresaAutenticada;
        }
        for(SST_Indicador__c indicadorExistente: [SELECT Name, id, Fecha_Inicial__c, Fecha_Final__c, Nombre_Indicador__c, analisis__c, Indicador__c, Meta__c, Calculo__c, Unidad_Indicador__c, Frecuencia__c 
                                                  FROM SST_Indicador__c where Empresa__c =:empresaIndicador
                                                  and ((Nombre_Indicador__c =: mapaIndicadores.get(indicadorSelect))) 
                                                  and ((Fecha_Final__c >=: fechaInicio and Fecha_Final__c <=: fechaFin) or (Fecha_Inicial__c >=: fechaInicio and Fecha_Inicial__c <=: fechaFin))]){
                                                      DTOLista registroIndicador = new DTOLista();
                                                      registroIndicador.identificadorDTO = indicadorExistente.Name; 
                                                      registroIndicador.indicadorDTO = indicadorExistente.Indicador__c; 
                                                      registroIndicador.fInicialDTO = String.valueOf(indicadorExistente.Fecha_Inicial__c); 
                                                      registroIndicador.fFinalDTO = String.valueOf(indicadorExistente.Fecha_Final__c);
                                                      registroIndicador.analisisDTO = indicadorExistente.analisis__c;
                                                      registroIndicador.nombre = indicadorExistente.Nombre_Indicador__c;
                                                      registroIndicador.meta = String.valueOf(indicadorExistente.Meta__c);
                                                      registroIndicador.calculo = indicadorExistente.Calculo__c;
                                                      registroIndicador.unidad = indicadorExistente.Unidad_Indicador__c;
                                                      registroIndicador.frecuencia = indicadorExistente.Frecuencia__c;
                                                      registroIndicador.idDTO = indicadorExistente.id;
                                                      if(indicadorExistente.Fecha_Final__c == fechaFin){
                                                          analisis = indicadorExistente.analisis__c;
                                                          idIndicador = indicadorExistente.id;
                                                      }
                                                      indicadoresExistentes.add(registroIndicador); 
                                                  }
    }
    
    //Método que crea un nuevo registro en el objeto indicador.
    public void guardar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
        try{
            if(Schema.sObjectType.SST_Indicador__c.fields.Nombre_Indicador__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Indicador__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Meta__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Fecha_Inicial__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Fecha_Final__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Calculo__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Frecuencia__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Analisis__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.empresa__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Unidad_Indicador__c.isCreateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Nombre_Indicador__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Indicador__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Meta__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Fecha_Inicial__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Fecha_Final__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Calculo__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Frecuencia__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Analisis__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.empresa__c.isUpdateable()&&
               Schema.sObjectType.SST_Indicador__c.fields.Unidad_Indicador__c.isUpdateable()){
                   
                   SST_Indicador__c indicadores;
                   if(idIndicador!=null){
                       indicadores = [SELECT id FROM SST_Indicador__c WHERE id = :idIndicador];
                   }else{
                       indicadores = new SST_Indicador__c();
                   }	
                   indicadores.Nombre_Indicador__c = mapaIndicadores.get(indicadorSelect);
                   indicadores.Indicador__c = indicador;
                   indicadores.Meta__c = metaIndicador;
                   indicadores.Fecha_Inicial__c = fechaInicio;
                   indicadores.Fecha_Final__c = fechaFin;
                   indicadores.Calculo__c = resultado+resultado2;
                   indicadores.Unidad_Indicador__c = unidadIndicador.substringAfterLast(': ');
                   indicadores.Frecuencia__c = frecuencia.substringAfterLast(': ');
                   indicadores.Analisis__c = analisis;
                   if(!esAdmin || SST_Constantes.getCantidadEmpresas() == 1){
                       indicadores.empresa__c = empresaAutenticada;
                   }
                   
                   upsert indicadores;
                   consultarAnalisisIndicadores();
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'Se ha actualizado el análisis para el indicador seleccionado exitosamente'));
               }else{
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para modificar o registrar el indicador'));
               }
            
        } catch (Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'Ha ocurrido un error, comuníquese con el administrador del sistema'));            
            system.debug('Mensaje error:'+e.getMessage());
            system.debug('Linea error:'+e.getLineNumber());
            system.debug('Causa error:'+e.getCause());
        }    
    }
    
    //Método para mostrar en el modal al administrador del sistema, el detalle del indicador seleccionado
    public pageReference mostrarRegistroSeleccionado(){
        registroSeleccionado = new DTOLista();
        for(DTOLista temp : indicadoresExistentes){
            if(temp.idDTO == idRegistroSeleccionado){
                registroSeleccionado = temp;       
            }                                   
        }
        return null;
    }
    
    public class DTOLista{
        public String idDTO {get;set;}
        public String identificadorDTO {get;set;}
        public double indicadorDTO {get;set;}
        public String fInicialDTO {get;set;}
        public String fFinalDTO {get;set;}
        public String analisisDTO {get;set;}
        public String nombre {get;set;}
        public String meta {get;set;}
        public String calculo {get;set;}
        public String unidad {get;set;}
        public String frecuencia {get;set;}
    }
    
}