public with sharing class SST_Constantes {
    /*Valores picklist cumplimiento*/
    /*Constante con el valor Cumple*/
    public static final string CUMPLE = 'CUMPLE';
    /*Constante con el valor No cumple*/
    public static final string NO_CUMPLE = 'NO_CUMPLE';
    /*Constante con el valor No aplica*/
    public static final String NO_APLICA = 'NO_APLICA';
    /*Constante con el valor de No aplica a la empresa*/
    public static final String NO_APLICA_EMPRESA = 'No aplica a la empresa';

    /*Constante con el valor Cumple parcialmente*/
    public static final String CUMPLE_PARCIALMENTE = 'CUMPLE_PARCIALMENTE';
    /*Constante que contiene el color cuando cumple */
    public static final string COLOR_CUMPLE = '#317F43';
    /*Constante que contiene el color cuando cumple */
    public static final string COLOR_NO_CUMPLE = '#CC0605';
    /*Constante que contiene el color cuando cumple parcialmente */
    public static final string COLOR_CUMPLE_PARCIALMENTE = '#f7f71d';
    /*Constante que contiene sin color */
    public static final string SIN_COLOR = '#FF0000';
    /*Constantes que contienen el nivel de riesgo de la empresa */
    public static final string RIESGO_5 = 'Riesgo 5';
    public static final string RIESGO_4 = 'Riesgo 4';
    public static final string RIESGO_3 = 'Riesgo 3';
    public static final string RIESGO_2 = 'Riesgo 2';
    public static final string RIESGO_1 = 'Riesgo 1';
    /*Constantes que contienen el tipo de empresa */
    public static final string EMPRESA_PEQUENA = 'Pequena';
    public static final string EMPRESA_MEDIANA = 'Mediana';
    public static final string EMPRESA_GRANDE = 'Grande';

    
    /*Constante con el color de una tabla a nivel 1*/
    public static final String COLOR_PRIMER_NIVEL= '#A4A4A4';    
    /*Constante con el color de una tabla a nivel 1*/
    public static final String COLOR_SEGUNDO_NIVEL= '#c3c3c3';    
    /*Constante con el color de una tabla a nivel 1*/
    public static final String COLOR_TERCER_NIVEL= '#e7e7e5';    
    /*Constante con el color gris, neutral para indicadores de resultado*/
    public static final String COLOR_NEUTRAL = '#bdbbb1';
    
    
    /*Constante con el formato de fecha y hora en formato 12 horas*/
    public static final String FORMATO_FECHA_REPORTE = 'dd/MMM/yyyy - hh:mm aa';
    /*Constante con el formato de fecha en formato 12 horas*/
    public static final String FORMATO_FECHA_SIN_HORA_REPORTE = 'dd/MMM/yyyy - hh:mm aa zzz';
    
     /*Constante con el formato de fecha */
    public static final String FORMATO_FECHA = 'dd/MM/yyyy';
    
    /*Constante para lista de strings con recordType Ausentismos, Incapacidades/Licencias*/
    public static final String[] LISTA_RECORD_TYPES_REGISTRO_NOVEDADES = new String[]{'Incapacidades/Licencias','Ausentismos'};
        
    /*Constantes para estados*/
    public static final String ACTIVO = 'ACTIVO';
    public static final String INACTIVO = 'INACTIVO';
    
    
    /*Constantes para parentescos en objeto SST_Grupo_familiar__c*/
    public static final String MADRE = 'MADRE';
    public static final String PADRE = 'PADRE';
    
    
    /*Constantes para tipo de documento en objeto SST_Gestion_documentos__c*/
    public static final String CONTRATO = 'CONTRATO';
    public static final String SEGURIDAD_SOCIAL = 'SEGURIDAD SOCIAL';
    
    
    /*Constantes para perfiles de la org*/
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String ADMINISTRADOR = 'Administrador del sistema';
    public static final String GESTOR_SST = 'GESTOR SST';
    
    /*Constantes para objeto SST_Comites__c*/
    /*Constate para titularidad*/
    public static final String PRINCIPAL = 'Principal';
    /*Constate para Representante de*/
    public static final String EMPLEADOR = 'Empleador';
    public static final String TRABAJADORES = 'Trabajadores';
    
    
    /*Constantes para nombres de las páginas de reportes*/
    /*Reporte estatus 1072*/
    public static final String REPORTE_ESTATUS_1072 = 'reporte-estatus-1072';
    /*Reporte estándares mínimos*/
    public static final String REPORTE_ESTANDARES_MINIMOS = 'reporte-estandares-minimos';
    /*Reporte matriz legal*/
    public static final String REPORTE_MATRIZ_LEGAL = 'reporte-matriz-legal';
    
    /*Página detalle normatividad*/
    public static final String PAGINA_DETALLE_NORMATIVIDAD = 'sst-normatividad';
    /*Página detalle cargo*/
    public static final String PAGINA_DETALLE_CARGO = 'sst-cargo';
    /*Página detalle Seguimiento*/
    public static final String PAGINA_DETALLE_SEGUIMIENTO = 'sst-seguimiento';
    /*Página detalle Seguimiento Enfermedad Laboral y Común*/
    public static final String PAGINA_DETALLE_SEGUIMIENTO_ELC = 'sst-seguimiento-elc';
    /*Constante con el origen laboral para los seguimientos por enfermedad laboral y común */
    public static final String LABORAL = 'Laboral';
    /*Página detalle Indicador*/
    public static final String PAGINA_DETALLE_INDICADOR = 'sst-indicador';
    
    /*Página detalle Peligro SP*/
    public static final String PAGINA_DETALLE_PELIGRO_SP = 'sst-peligro-sp';
    
    /*Perfil lider SST*/
    public static final String PERFIL_LIDER_SST = 'SST Community Plus';
    /*Interpretaciones del nível de riesgo*/
    /*Interpretación nivel riesgo I*/
    public static final String NIVEL_RIESGO_I ='I Situación crítica.  Suspender actividades hasta que el riesgo esté bajo control.  Intervención urgente.';
    /*Interpretación nivel riesgo I*/
    public static final String NIVEL_RIESGO_II ='II Corregir y adoptar medidas de control inmediato.  Sin embargo, suspenda actividades si el nivel de consecuencia está por encima de 60.';
    /*Interpretación nivel riesgo I*/
    public static final String NIVEL_RIESGO_III ='III Mejorar si es posible.  Sería conveniente justificar la intervención y su rentabilidad.';
    /*Interpretación nivel riesgo I*/
    public static final String NIVEL_RIESGO_IV ='IV Mantener las medidas de control existentes, pero se deberían considerar soluciones o mejoras y se deben hacer comprobaciones periódicas para asegurar que el riesgo aún es tolerable.';
    /*Aceptable*/
    public static final String ACEPTABLE ='Aceptable';
    /*No aceptable*/
    public static final String NO_ACEPTABLE ='No aceptable';
    /*Supervisión Periódica*/
    public static final String SUPERVISION_PERIODICA ='Supervisión periódica';
    /*Monitoreo continuo*/
    public static final String MONITOREO_CONTINUO ='Monitoreo continuo';
    /*Acción oportuna*/
    public static final String ACCION_OPORTUNA ='Acción oportuna';
    /*Gestión inmediata*/
    public static final String GESTION_INMEDIATA ='Gestión inmediata';
    /*Realice Valoración*/
    public static final String REALICE_VALORACION ='Realice Valoración';
    
    /*Nombre del ciclo PLANEAR*/
    public static final String CICLO_PLANEAR = 'PLANEAR';
    /*Nombre del ciclo ACTUAR*/
    public static final String CICLO_ACTUAR = 'ACTUAR';
    /*Nombre del ciclo HACER*/
    public static final String CICLO_HACER = 'HACER';
    /*Nombre del ciclo VERIFICAR*/
    public static final String CICLO_VERIFICAR = 'VERIFICAR';
    /*Nombre del record type formaciones:RESPONSABILIDADES*/
    public static final String RECORD_TYPE_RESPONSABILIDADES = 'Responsabilidades cargos';
    /*Nombre del record type formaciones:RESPONSABILIDADES*/
    public static final String RECORD_TYPE_RESPONSABILIDADES_COMITE = 'Responsabilidades comités';
    /*Nombre del record type formaciones:ENTRENAMIENTOS*/
    public static final String RECORD_TYPE_ENTRENAMIENTOS = 'Entrenamientos';
    /*Nombre del record type formaciones:COMPETENCIAS*/
    public static final String RECORD_TYPE_COMPETENCIAS = 'Competencias';
    
    /*Nombre del record type Seguimientos:PLANES Y PROGRAMAS*/
    public static final String RECORD_TYPE_PLANES_PROGRAMAS = 'Planes y Programas';
    
    /*Nombre en singular del record type responsabilidad cargo*/
    public static final String RESPONSABILIDAD_CARGO = 'Responsabilidad cargo';
    
    /*Nombre en singular del record type responsabilidad comité*/
    public static final String RESPONSABILIDAD_COMITE = 'Responsabilidad comité';
    
    /*Nombre en singular del record type entrenamiento*/
    public static final String ENTRENAMIENTO = 'Entrenamiento';
    
    /*Nombre en singular del record type competencia*/
    public static final String COMPETENCIA = 'Competencia';
    
    /*Nombre del color amarillo*/
    public static final String COLOR_AMARILLO = '#FFA420';
    /*Nombre del color azul*/
    public static final String COLOR_AZUL = 'rgb(0, 95, 178)';
    /*Nombre del colora naranja*/
    public static final String COLOR_NARANJA = '#F54021';
    /*Nombre del estado intervenido*/
    public static final String ESTADO_INTERVENIDO = 'INTERVENIDO';
    /*Nombre del estado controles establecidos*/
    public static final String ESTADO_CONTROLES_ESTABLECIDOS = 'CONTROLADO';
    /*Nombre del estado evaluado*/
    public static final String ESTADO_EVALUADO = 'EVALUADO';
    /*Nombre del estado identificado*/
    public static final String ESTADO_IDENTIFICADO = 'IDENTIFICADO';
    /*Nombre del estado Valorado*/
    public static final String ESTADO_VALORADO = 'VALORADO';
    /*Nombre del estado Inactivo*/
    public static final String ESTADO_INACTIVO = 'INACTIVO';
    /*Nombre del nivel bajo*/
    public static final String NIVEL_BAJO = 'BAJO';
    /*Nombre del nivel medio*/
    public static final String NIVEL_MEDIO = 'MEDIO';
    /*Nombre del nivel medio alto*/
    public static final String NIVEL_MUY_ALTO = 'MUY ALTO';
    /*Nombre del nivel alto*/
    public static final String NIVEL_ALTO = 'ALTO';
    /*Nombre de la ccción eliminar*/
    public static final String ACCION_ELIMINAR = 'Eliminar';
    /*Nombre de la ccción sustituir*/
    public static final String ACCION_SUSTITUIR = 'Sustituir';
    /*Nombre de la acción del botón cuando el estado es identificado*/
    public static final String ACCION_BOTON_IDENTIFICADO ='Evaluar';
    /*Nombre de la acción del botón cuando el estado es evaluado*/
    public static final String ACCION_BOTON_EVALUADO ='Controlar';
    /*Nombre de la acción del botón cuando el estado es identificado*/
    public static final String ACCION_BOTON_VALORADO ='Valorar';
    /*Nombre de la acción del botón cuando el estado es controlado*/
    public static final String ACCION_BOTON_CONTROLADO ='Intervenir';
    /*Nombre de la acción del botón cuando el estado es intervenido*/
    public static final String ACCION_BOTON_INTERVENIDO ='Ver/ Modificar';
    /*Valor a mostrar para un picklist sin valor*/
    public static final String ITEM_VACIO_PICKLIST  = '-- Seleccione --';
    
    /*Descripción del Nivel de Deficiencia Muy Alto*/
    public static final String ND_MUY_ALTO = '10 Muy Alto: Se ha(n) detectado peligro(s) que determina(n) como posible la generación de incidentes, o la eficacia del conjunto de medidas preventivas existentes respecto al riesgo es nula o no existentes o ambas.';
    /*Descripción del Nivel de Deficiencia Alto*/
    public static final String ND_ALTO ='6 Alto: Se ha(n) detectado algún(os) peligro(s) que pueden dar lugar  a incidentes poco significativo(s), o a la eficacia del conjunto de medidas preventivas existentes es baja o ambos.';
    /*Descripción del Nivel de Deficiencia Medio*/
    public static final String ND_MEDIO = '2 Medio: Se han detectado peligros que pueden dar lugar a incidentes poco significativos o de menor importancia, o la deficiencia del conjunto de las medidas preventivas existentes es moderada o ambos.';
    /*Descripción del Nivel de Deficiencia No se asigna valor*/
    public static final String ND_NO_SE_ASIGNA_VALOR='No se ha detectado peligro o la deficiencia del conjunto de medidas preventivas es alta o ambos. El riesgo esta controlado. Estos peligros se clasifican directamente en el nivel de riesgo y de intervención cuatro (IV) véase la tabla 8.';
    /*Descripción del Nivel de Exposición Continua*/
    public static final String NE_CONTINUA=' La situación de exposición se presenta sin interrupción o varias veces con tiempo prolongado durante la jornada laboral.';
    /*Descripción del Nivel de Exposición Frecuente*/
    public static final String NE_FRECUENTE='La situación de exposición se presenta varias veces durante la jornada laboral por tiempos cortos.';
    /*Descripción del Nivel de Exposición Ocasional*/
    public static final String NE_OCASIONAL= 'La situación de exposición se presenta alguna vez durante la jornada laboral y por un periodo de tiempo corto.';
    /*Descripción del Nivel de Exposición Esporádica*/
    public static final String NE_ESPORADICA= ' La situación de exposición se presenta de manera eventual.';    
    /*Descripción del Nivel de Probabilidad Muy Alto*/
    public static final String NP_MUY_ALTO='Situación deficiente con exposición continua, o muy deficiente con exposición frecuente.  Normalmente la materialización del riesgo. ocurre con frecuencia.';    
    /*Descripción del Nivel de Probabilidad Alto*/
    public static final String NP_ALTO= 'Situación deficiente con exposición frecuente u ocasional, o bien situación muy deficiente con exposición ocasional o esporádica.  La materialización del riesgo es posible que suceda varias veces en la vida laboral.';    
    /*Descripción del Nivel de Probabilidad Medio*/
    public static final String NP_MEDIO= 'Situación deficiente con exposición esporádica, o bien situación mejorable con exposición continuada o frecuente.  Es posible que suceda el daño alguna vez.';   
    /*Descripción del Nivel de Probabilidad Bajo*/
    public static final String NP_BAJO= 'Situación mejorable con exposición ocasional o esporádica, o situación sin anomalía destacable con cualquier nivel de exposición. No es esperable que se materialice el riesgo, aunque puede ser concebible. ';    
    /*Descripción del Nivel de Consecuencia Mortal o Catastrófico*/
    public static final String NC_MORTAL_CATASTROFICO='Muerte (s).';
    /*Descripción del Nivel de Consecuencia Muy grave*/
    public static final String NC_MUY_GRAVE='Lesiones  o enfermedades graves irreparables (Incapacidad permanente parcial o invalidez).';
    /*Descripción del Nivel de Consecuencia Grave*/
    public static final String NC_GRAVE= 'Lesiones o enfermedades con incapacidad laboral temporal (ILT).';
    /*Descripción del Nivel de Consecuencia Leve*/
    public static final String NC_LEVE='Lesiones o enfermedades que no requieren incapacidad.';
    
    /*Name del seguimiento tipo Plan Anual de Trabajo*/
    public static final String TIPO_PLAN_ANUAL_TRABAJO='PL_002';
    
    /*Name del seguimiento tipo PROGRAMA ANUAL DE MONITOREO MEDIOAMBIENTAL*/
    public static final String PROGRAMA_ANUAL_MONITOREO_MEDIOAMBIENTAL='PL_008';
    
    /*Name del record type funcionario en el objeto Contact*/
    public static final String FUNCIONARIO = 'Funcionarios';
    
    /*Name del record type Contratista en el objeto Contact*/
    public static final String CONTRATISTA = 'Contratistas SST';
    
    /*Name del record type Proveedor en el objeto Contact*/
    public static final String PROVEEDOR = 'Proveedores SST';
    
    /*Name del record type contacto proveedor en el objeto Contact*/
    public static final String CONTACTO_PROVEEDOR = 'Contactos Proveedor';
    
    /*Constante para lista de strings con nombres de los tipos de Contactos*/
    public static final String[] TIPOS_CONTACTO = new String[]{'Contratista','Funcionario','Proveedor', 'Contacto de proveedor o contratista'};
        
        /*Name del tipo de cuenta que se asocia a la empresa o cuenta principal*/
        public static final String CLIENTE = 'Customer';
    
    /*Name del tipo de registro de novedades para los accidentes de trabajo*/
    public static final String ACCIDENTES = 'Accidentes';
    
    /*Constante para el cálculo del índice de frecuencia de accidentes de trabajo*/
    public static final Integer K_INDICADORES = 240000;
    
    /*Número para cálculo del indicador IEL*/
    public static final Integer CONSTANTE_IEL_PEL = 100000;
    
    /*Número para cálculo del indicador ILIAT*/
    public static final Integer DENOMINADOR_INDICADOR_ILIAT = 1000;
    
    /*Constante para multiplicar un valor y convertirlo en porcentaje*/
    public static final Integer CONSTANTE_PORCENTAJE = 100;
    
    /*Constante del número cero*/
    public static final Integer CONSTANTE_CERO = 0;
    
    /*Name de la naturaleza Accidentes de trabajo en Incapacidades*/
    public static final String NATURALEZA_ACCIDENTES = 'ACCIDENTE_TRABAJO';
    
    /*Name de la naturaleza Enfermedad Laboral en Incapacidades*/
    public static final String NATURALEZA_ENFERMEDAD_LABORAL = 'ENFERMEDAD_PROFESIONAL';
    
    /*Name del tipo Mortal para Accidentes de trabajo en Incapacidades*/
    public static final string TIPO_MORTAL = 'MORTAL';
    
    /*Constante para lista de strings con tipo de reporte para Acto y Condición inseguras*/
    public static final String[] ACTO_Y_CONDICION_INSEGURA = new String[]{'ACTO_INSEGURO','CONDICION_INSEGURA'};
        
        /*Api Name del tipo de exámen ocupacional de ingreso*/
        public static final string INGRESO = 'INGRESO';
    
    /*Api Name del tipo de exámen ocupacional periódico*/
    public static final string PERIODICO = 'PERIODICO';
    
    /*Api Name de las posibles calificaciones para un contratista o proveedor*/
    public static final string APROBADO = 'Aprobado';
    public static final string CONDICIONAL = 'Condicional';
    public static final string NO_APROBADO = 'No aprobado';
    
    /*Api Name de las interpretaciones de las calificaciones para un contratista o proveedor*/
    public static final string INTERPRETACION_APROBADO = '% - El proveedor o contratista se encuentra en mejoramiento continuo';
    public static final string INTERPRETACION_CONDICIONAL = '% - El proveedor o contratista deberá presentar plan de mejora de los aspectos débiles.  Si no cumple, será rechazado';
    public static final string INTERPRETACION_NO_APROBADO = '% - El proveedor o contratista no cumple';
    
    /*Strings con los posibles estados de los registros en el objeto Gestión de Documentos*/
    public static final String VIGENTE = 'Vigente';
    public static final String POR_ACTUALIZAR = 'Por_actualizar';
    
    /*Strings con los nombres de los templates de las plantillas de correo electrónico */
    public static final String TEMPLATE_SST = 'Notificación a SST';
    public static final String TEMPLATE_CONTACTO = 'Notificación a proveedores';
    public static final String TEMPLATE_ACTIVACION_PROVEEDOR = 'Notificación activación a proveedores';
    public static final String TEMPLATE_ENCUESTA_SOCIODEMOGRAFICA = 'Notificación encuesta sociodemográfica';
    
    /*Strings con la url de la comunidad -- para instalaciones habilitar sólo la url de la org destino*/
    public static String LINK_SST = null;
    public static String LINK_PORTAL_SST = null;
    
    /*Constante con el valor del municipio OTRO*/
    public static final String CODIGO_MUNICIPIO_OTRO='99878';
    
    /*Constantes con los estados de la información sociodemográfica de los funcionarios*/
    public static final String INFO_SOCIODEMOGRAFICA_VIGENTE='Vigente';
    public static final String INFO_SOCIODEMOGRAFICA_CADUCADO='Caducado';
    
    /*Constantes para designar la acción a realizar con los contactos de los proveedores*/
    public static final String RETIRAR ='RETIRAR';
    public static final String INACTIVAR ='INACTIVAR';
    public static final String ACTIVAR ='ACTIVAR';
    
    //Constante con el valor de tipo de ausentismo permiso médico
    public static final String PERMISO_MEDICO = 'PERMISO_MEDICO';
    
    //Constante con la cantidad de días estándar por mes para el cálculo de los indicadores de resultado
    public static final Integer DIAS_MES = 30;
    
    //Constante con la cantidad de horas estándar por día para el cálculo de los indicadores de resultado
    public static final Integer HORAS_DIA = 8;
    
    //Constante con el nombre del pdf que contiene el texto de política de tratamiento de datos para el módulo de gestión documental de proveedores
    public static final String NOMBRE_PDF_POLITICA = 'Política tratamiento datos';
  
    //Constante con el valor de TEMPORAL para el Tipo contrato y Tipo vinculacion de Tipo de vinculacion o contrato de Contact
    public static final String TEMPORAL = 'TEMPORAL';
    
    //Constante con el valor de APRENDIZ para el Tipo contrato de Tipo de vinculacion de Contact
    public static final String APRENDIZ = 'APRENDIZ';
    
    //Constante con el valor de APRENDIZ LECTIVO para el Tipo contrato de Tipo de vinculacion de Contact
    public static final String APRENDIZ_LECTIVO = 'APRENDIZ_LECTIVO';
    
    //Constante con el valor de APRENDIZ_PRODUCTIVO para el Tipo contrato de Tipo de vinculacion de Contact
    public static final String APRENDIZ_PRODUCTIVO = 'APRENDIZ_PRODUCTIVO';
    
    //Constante con el valor de CONTRATISTA para el Tipo contrato  y Tipo vinculacion de Tipo de vinculacion o contrato  de Contact
    public static final String CONTRATO_CONTRATISTA = 'CONTRATISTA';
    
    //Constante con el valor de la ruta donde quedan las fotos del perfil
    public static final String RUTA_FOTO ='/sfc/servlet.shepherd/version/download/';
    
    //Constante con el valor de la ruta donde quedan las fotos del perfil
    public static final String NOMBRE_FOTO_PERFIL ='FotoPerfil.png';    
    
    static{
        List<Site> site = [SELECT Subdomain FROM Site WHERE SiteType='ChatterNetwork' AND Name='SST'];
        if(site!= null && !site.isEmpty() && site.get(0).Subdomain!= null){
            LINK_SST  = 'https://'+site.get(0).get('subdomain')+'.force.com';
        }
        
        List<Site> sitePortal = [SELECT Subdomain FROM Site WHERE SiteType='Visualforce' AND Name='Modulos_SST'];
        if(sitePortal!= null && !sitePortal.isEmpty() && sitePortal.get(0).Subdomain!= null){
            LINK_PORTAL_SST  = 'http://'+sitePortal.get(0).get('subdomain')+'.force.com';
        }
    }
    
    /*Método que retorna la URL del home de la comunidad*/
    public static String retornarUrl(){
        String cadena = '';
        cadena = ApexPages.currentPage().getHeaders().get('Referer');    
        if(cadena != null){
            List <String> dir = cadena.split('/', 6);
            cadena = 'https:'+cadena.substringBetween(dir.get(0), dir.get(dir.size()-1));
        }
        return cadena;
    }
    
    /*Método que cambia las iniciales de los meses de inglés a español*/
    public static String cambiarNombreMes(String fecha){
        if(fecha.containsIgnoreCase('Jan')){
            fecha = fecha.replace('Jan', 'Ene');
        } else if(fecha.containsIgnoreCase('Apr')){
            fecha = fecha.replace('Apr', 'Abr');
        } else if(fecha.containsIgnoreCase('Aug')){
            fecha = fecha.replace('Aug', 'Ago');
        } else if(fecha.containsIgnoreCase('Dec')){
            fecha = fecha.replace('Dec', 'Dic');
        }
        return fecha;
    }
    
    /*Método que cambia un número a letra, usado en los reportes PDF para el ordenamiento de los mapas*/
    public static string cambiarNumeros(Integer numero){
        if(numero==1){
            return 'A:';
        }
        if(numero==2){
            return 'B:';
        }
        if(numero==3){
            return 'C:';
        }
        if(numero==4){
            return 'D:';
        }
        if(numero==5){
            return 'E:';
        }
        if(numero==6){
            return 'F:';
        }
        if(numero==7){
            return 'G:';
        }
        if(numero==8){
            return 'H:';
        }
        if(numero==9){
            return 'I:';
        }
        if(numero==10){
            return 'J:';
        }
        if(numero==11){
            return 'K:';
        }
        if(numero==12){
            return 'L:';
        }
        return null;
    }
    
    /*Método que consulta y retorna los datos de la empresa.  En caso que no haya sido configurada aún, retorna nulo */
    public static account consultarDatosEmpresa(String nit){
        Account cuentaPrincipal = new Account();
        List <Account >cuentas = [select id, name, SST_grupo_empresarial__c, SST_Correo_nomina__c, sst_nit__c, 
                                  SST_Periodicidad_examen_ocupacional__c, SST_Plazo_encuesta_sociodemografica__c,
                                  sst_periodo_notificacion__c, sst_horas_habiles__c, SST_Meta_IEL__c, SST_Frecuencia_IEL__c,
                                  SST_Meta_IFAT__c, SST_Frecuencia_IFAT__c, SST_Meta_IFIAT__c, SST_Frecuencia_IFIAT__c,
                                  SST_Meta_ILIAT__c, SST_Frecuencia_ILIAT__c, SST_Meta_ISAT__c, SST_Frecuencia_ISAT__c,
                                  SST_Meta_MAT__c, SST_Frecuencia_MAT__c, SST_Meta_ACM__c, SST_Frecuencia_ACM__c,
                                  SST_Meta_PEL__c, SST_Frecuencia_PEL__c, SST_Meta_FA__c, SST_Frecuencia_FA__c, 
                                  SST_Meta_IFA__c, SST_Frecuencia_IFA__c, SST_Meta_PTP__c, SST_Frecuencia_PTP__c,
                                  SST_META_SA__c, SST_Frecuencia_SA__c from account 
                                  where type =:SST_Constantes.CLIENTE and sst_estado__c =: SST_Constantes.ACTIVO and sst_nit__c =: Decimal.valueOf(nit)];
        if(cuentas.size() == 0){
            cuentaPrincipal = null;
        } else {
            cuentaPrincipal = cuentas.get(0);
        }
        return cuentaPrincipal;
    }
    
    /*Método que consulta y retorna los datos de la empresa que el usuario haya seleccionado para indicadores globales.  En caso que no haya sido configurada aún, retorna nulo */
    public static account consultarDatosMultiempresa(){
        Account cuentaPrincipal = new Account();
        List <Account >cuentas = [select id, name, SST_grupo_empresarial__c, SST_Correo_nomina__c, SST_Periodicidad_examen_ocupacional__c, 
                                  sst_periodo_notificacion__c, sst_horas_habiles__c, SST_Meta_IEL__c, SST_Frecuencia_IEL__c,
                                  SST_Meta_IFAT__c, SST_Frecuencia_IFAT__c, SST_Meta_IFIAT__c, SST_Frecuencia_IFIAT__c,
                                  SST_Meta_ILIAT__c, SST_Frecuencia_ILIAT__c, SST_Meta_ISAT__c, SST_Frecuencia_ISAT__c,
                                  SST_Meta_MAT__c, SST_Frecuencia_MAT__c, SST_Meta_ACM__c, SST_Frecuencia_ACM__c,
                                  SST_Meta_PEL__c, SST_Frecuencia_PEL__c, SST_Meta_FA__c, SST_Frecuencia_FA__c, 
                                  SST_Meta_IFA__c, SST_Frecuencia_IFA__c, SST_Meta_PTP__c, SST_Frecuencia_PTP__c,
                                  SST_META_SA__c, SST_Frecuencia_SA__c from account 
                                  where type =:SST_Constantes.CLIENTE and sst_estado__c =: SST_Constantes.ACTIVO and SST_Cuenta_indicadores_globales__c =: true];
        if(cuentas.size() == 0){
            cuentaPrincipal = null;
        } else {
            cuentaPrincipal = cuentas.get(0);
        }
        return cuentaPrincipal;
    }
    
    //Método que retorna el usuario Administrador del sistema
    public static User returnAdministrador(){
        User userAdmin = [Select id, name, profileId from User where isActive =: true and profile.UserType = 'Standard' and (profile.name =: SST_Constantes.SYSTEM_ADMINISTRATOR or profile.name =: SST_Constantes.ADMINISTRADOR) limit 1];
        return userAdmin;
    }
    
    //Método para obtener una lista con los usuarios activos con perfil admin y gestor
    public static List<User> returnUserList(){ 
        List<User> userList = [SELECT email  FROM  user where isActive =: true and ((profile.name =: SST_Constantes.GESTOR_SST) or (profile.UserType = 'Standard' and (profile.name =: SST_Constantes.SYSTEM_ADMINISTRATOR or profile.name =: SST_Constantes.ADMINISTRADOR)))];  
        return userList;
    }  
    
    /*Método que retorna un mapa con los nombres de los indicadores de resultado*/
    public static Map<String,String> llenarMapaIndicadoresResultado(){
        Map <String,String> mapaIndicadoresResultado = new Map <String,String>();
        mapaIndicadoresResultado.put('ACM','Ausentismo por causa médica');
        mapaIndicadoresResultado.put('FA','Frecuencia de accidentalidad');
        mapaIndicadoresResultado.put('IEL','Incidencia de enfermedades laborales'); 
        mapaIndicadoresResultado.put('IFA','Índice de frecuencia de ausentismos por causa de salud');
        mapaIndicadoresResultado.put('IFAT','Índice de frecuencia de accidentes de trabajo');
        mapaIndicadoresResultado.put('IFIAT','Índice de frecuencia de accidentes de trabajo con incapacidad');
        mapaIndicadoresResultado.put('ILIAT','Índice de lesiones incapacitantes por accidentes de trabajo');
        mapaIndicadoresResultado.put('ISAT','Índice de Severidad de accidentes de trabajo');
        mapaIndicadoresResultado.put('MAT','Mortalidad de los accidentes de trabajo');
        mapaIndicadoresResultado.put('PEL','Prevalencia de enfermedades laborales');
        mapaIndicadoresResultado.put('PTP','Porcentaje de tiempo perdido por causa de salud');
        mapaIndicadoresResultado.put('SA','Severidad de accidentalidad');
        return mapaIndicadoresResultado;
    }
    
    /*Método que retorna un mapa con las unidades de medida de los indicadores de resultado*/
    public static Map<String,String> llenarMapaUnidadesIndicadoresResultado(){
        Map <String,String> mapaUnidadesIndicadoresResultado = new Map <String,String>();
        mapaUnidadesIndicadoresResultado.put('ACM','Porcentaje');
        mapaUnidadesIndicadoresResultado.put('FA','Porcentaje');
        mapaUnidadesIndicadoresResultado.put('IEL','Número'); 
        mapaUnidadesIndicadoresResultado.put('IFA','Número');
        mapaUnidadesIndicadoresResultado.put('IFAT','Número');
        mapaUnidadesIndicadoresResultado.put('IFIAT','Número');
        mapaUnidadesIndicadoresResultado.put('ILIAT','No aplica');
        mapaUnidadesIndicadoresResultado.put('ISAT','Días');
        mapaUnidadesIndicadoresResultado.put('MAT','Porcentaje');
        mapaUnidadesIndicadoresResultado.put('PEL','Número');
        mapaUnidadesIndicadoresResultado.put('PTP','Porcentaje');
        mapaUnidadesIndicadoresResultado.put('SA','Porcentaje');
        return mapaUnidadesIndicadoresResultado;
    }
    
    //Método que retorna envía el correo de notificación de inactivación de funcionarios a los usuarios administrador y gestor
    public static void EnviarNotificacionFuncionariosInactivos(List <String> listaRegistros, String nit){
        Set<String> mailsEnviarSet = new Set<String>();
        
        for(User usuario: [SELECT email  FROM  user where isActive =: true and (profile.name =: SYSTEM_ADMINISTRATOR or profile.name =: ADMINISTRADOR or profile.name =: GESTOR_SST)]){
            if(!String.isEmpty(usuario.email) || !String.isBlank(usuario.email)){
                mailsEnviarSet.add(usuario.email);
            }
        }
        if(mailsEnviarSet.size()!=0){
            List<String> emailAddressList = new List<String>();
            for(String mail : mailsEnviarSet){  
                emailAddressList.add(mail);    
            }
            List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailAddressList);
            mail.setSubject('Inactivación de funcionarios');
            mail.setHtmlBody(mensajeCuerpoCorreoFuncionariosInactivos(listaRegistros, nit));
            mailsList.add(mail);
            List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
        }
    }
    
    //Método que retorna el contenido del correo de notificación de inactivación de funcionarios
    private static String mensajeCuerpoCorreoFuncionariosInactivos(List <String> listaRegistros, String nit){
        Account cuenta = ConsultarDatosEmpresa(nit);
        String campos = '<br />';
        for(String registros: listaRegistros){
            campos = campos+registros+'<br /><br />';
        }
        String cuerpoMensajes='';
        cuerpoMensajes= '<p>Cordial saludo,</p><br /><p>El &aacute;rea de seguridad y salud en el trabajo se permite informarle que el d&iacute;a de hoy se ha realizado la inactivaci&oacute;n de los siguientes funcionarios en el sistema, y se han inactivado las asociaciones en comit&eacute;s, y las desasociaciones en normatividades y como responsables SST de las empresas que a continuaci&oacute;n se indican : </p>';
        cuerpoMensajes = cuerpoMensajes+campos+' <p>Recuerde modificar las tareas y eventos aqu&iacute; relacionados para desasociar los funcionarios que fueron inactivados, as&iacute; mismo nombrar nuevos miembros para los comit&eacute;s en reemplazo de los que fueron inactivados, y designar nuevos responsables en la matriz legal para las normatividades relacionadas y un nuevo responsable SST para la empresa.</p><br />';
        cuerpoMensajes = cuerpoMensajes+'<p>Cordialmente, </p><br /><p>'+cuenta.SST_grupo_empresarial__c+'</p><br />';
        return cuerpoMensajes;
    }  
    
    /**Método que se encarga de obtener la empresa autenticada.*/
    public static String getEmpresaAutenticada(){
        String nombreEmpresa = '';
        try{
            nombreEmpresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;
        }catch(Exception e){
            System.debug('Error en getNombresEmpresa()'+e.getLineNumber()+e.getMessage());
        } 
        return nombreEmpresa;
    } 
    
    //Método que retorna la cantidad de empresas activas del grupo empresarial
    public static Integer getCantidadEmpresas(){
        List <Account >cuentas = [select id, name from account where type =:SST_Constantes.CLIENTE and sst_estado__c =: SST_Constantes.ACTIVO];
        Integer cantEmpresas = cuentas.size();
        return cantEmpresas;
    }
    
    /**Método que retorna el texto de la autorización para tratamiento de datos*/
    public static String returnTextoTratamiendoDatos(String nombreEmpresa){
        String textoPolitica = '';
        textoPolitica = 'De conformidad con lo dispuesto en la Ley Estatutaria 1581 de 2012, autorizo a ';
        textoPolitica = textoPolitica + nombreEmpresa + ' para el tratamiento y manejo de mis datos personales el cual consiste en recolectar, almacenar, depurar, usar, analizar, actualizar y cruzar información propia, con el fin de contribuir a la caracterización de la población al servicio de la entidad la cual servirá para definir planes y programas en pro del bienestar y calidad de vida en un ambiente laboral adecuado.';
        textoPolitica = textoPolitica +'\n';
        textoPolitica = textoPolitica +'\n';
        textoPolitica = textoPolitica + 'Lo anterior atendiendo lo dispuesto en las la Resolución 2646 de 2008 artículo 8, Resolución 2346 de 2007 artículos 8, 15 y 18 y Decreto 1072 de 2015 artículos 2.2.4.2.2.18, 2.2.4.6.12, 2.2.4.6.13 y 2.2.4.6.16.';
        textoPolitica = textoPolitica +'\n';
        textoPolitica = textoPolitica +'\n';
        textoPolitica = textoPolitica + 'Soy consciente que este proceso no atenta contra mi derecho fundamental a la intimidad personal y laboral, por el contrario busca promover un programa para prevenir situaciones que puedan afectar mi salud física, emocional y mental, o de igual forma impactar en mi desempeño laboral.';
        return textoPolitica;
    }
    
    /*Método que se encarga de actualizar la cantidad de expuestos de planta en los peligros
este método es invocada al: 
1. Crear o modificar sede y responsabilidad de un peligro.
2. Crear o modificar sede y cargo de un contacot.
3. Asociar o desasociar responsabilidades de un cargo */
    public static List<Object> actualizarExpuestosPeligros(List<SST_peligro__c> peligros,Set<String> empresas){
        List<Id> idResponsabilidades = new List<Id>();
        List<Id> idSedes = new List<Id>();
        List<Id> idProcesos = new List<Id>();      
        Map <String,String> mapaRegistros = new Map <String,String>();
        List<SST_peligro__c> peligrosActualizar = new List<SST_peligro__c>();
        if(peligros == null){
            for(SST_peligro__c registro : [SELECT proceso__c,Responsabilidad_cargo__c,sede__c,empresa__c FROM SST_Peligro__c WHERE empresa__c in:empresas AND estado__c <> :SST_Constantes.INACTIVO]){
                peligrosActualizar.add(registro);
                idResponsabilidades.add(registro.Responsabilidad_cargo__c);
                idSedes.add(registro.sede__c);
                idProcesos.add(registro.proceso__c);
                mapaRegistros.put(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c,registro.sede__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c);
            }
        }else{
            for(SST_peligro__c registro : peligros){
                idResponsabilidades.add(registro.Responsabilidad_cargo__c);
                idSedes.add(registro.sede__c);
                idProcesos.add(registro.proceso__c);
                mapaRegistros.put(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c,registro.sede__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c);
            }
        }
        /*para calcular la cantidad de expuestos en un peligro se consultan los cargos asociados a las responsabilidades y de ahi se consultan
la cantidad de funcionarios que tienen dichos cargos*/
        Map<ID,List<ID>> idCargos = new Map<ID,List<ID>>();
        for(SST_Formacion_cargo__c formacionCargo : [select id, cargo__c,Formacion__c from SST_Formacion_cargo__c where Formacion__c in: idResponsabilidades]){
            List<ID> responsabilidades = idCargos.get(formacionCargo.cargo__c);
            if(responsabilidades == null){
                responsabilidades = new List<ID>();
            }
            responsabilidades.add(formacionCargo.Formacion__c);
            idCargos.put(formacionCargo.cargo__c,responsabilidades);
        }
        Map <String,Integer> mapaCantContactos = new map <String,Integer>();
        /*se consultan los contactos que coinciden con los cargos de la responsabilidad y con las areas*/
        Map<String,Set<String>> mapaCargosExpuestos =  new Map<String,Set<String>>();
        for(Contact contacto :[SELECT id, sst_cargo__c,sst_cargo__r.name, sst_sede__c FROM Contact WHERE sst_cargo__c in : idCargos.keySet() AND sst_sede__c in: idSedes]){
            for(String key : mapaRegistros.keySet()){
                List <String> cargoSede = mapaRegistros.get(key).split('/');
                /*si el cargo del contacto esta en la lista de cargos, y el cargo del del contacto tiene la responsabilidad del peligro, y  la sede es la misma del peligro*/
                if(idCargos.get(contacto.sst_cargo__c) != null 
                   && idCargos.get(contacto.sst_cargo__c).contains(cargoSede.get(1))
                   && contacto.sst_sede__c == cargoSede.get(0)){
                       Integer cantidad = mapaCantContactos.get(key);
                       if(cantidad == null){
                           cantidad = 0;
                       }
                       Set<String> cargos = mapaCargosExpuestos.get(key);
                       if(cargos == null){
                           cargos = new Set<String>();
                       }
                       cargos.add(contacto.sst_cargo__r.name);
                       mapaCargosExpuestos.put(key,cargos);
                       mapaCantContactos.put(key,++cantidad);
                   }
            }
        }
        if(peligros == null){
            for(SST_peligro__c registro : peligrosActualizar){
                if(mapaCantContactos.get(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c)!= null){
                    registro.Numero_expuestos_planta__c = mapaCantContactos.get(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c);
                }else{
                    registro.Numero_expuestos_planta__c = 0;
                }
                
                String cargosExpuestos='';
                if(mapaCargosExpuestos.get(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c)!= null){
                    for(String cargo : mapaCargosExpuestos.get(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c)){
                        
                        cargosExpuestos +=  cargo+'; ';
                    }
                    registro.cargos__c = cargosExpuestos.substring(0,cargosExpuestos.length()-2);
                }
            }
            update(peligrosActualizar);
        }
        List<Object> mapaResultados = new List<Object>();
        mapaResultados.add(mapaCantContactos);
        mapaResultados.add(mapaCargosExpuestos);
        
        return mapaResultados;
    }
    
    /*Método que se encarga de validar si los municipios ingresados estan en la lista de salesforce 
de no ser así se actualiza con el valor OTRO*/
    public static Contact validarMunicipiosContacto(Contact nuevoRegistro,Map<String,String> listaMunicipios){
        if(nuevoRegistro.sst_codigo_dane_municipio__c != null){
            if(listaMunicipios.get(nuevoRegistro.sst_codigo_dane_municipio__c)== null){
                nuevoRegistro.sst_municipio__c = SST_Constantes.CODIGO_MUNICIPIO_OTRO;
            }else{
                nuevoRegistro.sst_municipio__c = nuevoRegistro.sst_codigo_dane_municipio__c;
            }
        }
        if(nuevoRegistro.SST_Codigo_DANE_Nacimiento__c != null){
            if(listaMunicipios.get(nuevoRegistro.SST_Codigo_DANE_Nacimiento__c)== null){
                nuevoRegistro.SST_Lugar_nacimiento__c = SST_Constantes.CODIGO_MUNICIPIO_OTRO;
            }else{
                nuevoRegistro.SST_Lugar_nacimiento__c = nuevoRegistro.SST_Codigo_DANE_Nacimiento__c;
            }
        }
        return nuevoRegistro;
    }
    
    /*Método que se encarga de enviar alertas cuando se inactiva un funcionario*/
    public static void enviarAlertasInactivacionContactos(Map <Id, contact> mapaContactos,String nit){
        
        List <String> datosRegistros = new List <String>();
        Set <Id> idContactos = mapaContactos.keySet();
        List <EventWhoRelation> eventosContactos = [select id, relationId, relation.name, EventId, event.EndDateTime, event.what.name, event.Subject from EventWhoRelation where relationId in : idContactos and event.EndDateTime >=: system.now()];
        List <TaskWhoRelation> tareasFuncionarios = [select id, relationId, TaskId, relation.name, Task.what.name, Task.Subject, Task.ActivityDate from TaskWhoRelation where relationId in : idContactos and Task.ActivityDate >= : system.today()];
        List <SST_Funcionarios_Comites__c> comitesFuncionarios = [select id, funcionario__c, funcionario__r.name, cargo_comite__r.name, titularidad__c, representante_de__c, comite__c, comite__r.nombre_comite__c, comite__r.fecha_fin__c from SST_Funcionarios_Comites__c where funcionario__c in : idContactos and estado__c =: SST_Constantes.ACTIVO];
        List <SST_Normatividad__c> normatividadesFuncionarios = [select id, name, funcionario__c, funcionario__r.name, fecha_expedicion__c from SST_Normatividad__c where funcionario__c<>null and funcionario__c in : idContactos];
        List <Account> cuentaFuncionarios = [select id, name,Responsable_SST__c, Responsable_SST__r.name from account where Responsable_SST__c <>null and Responsable_SST__c in: idContactos];
        if(eventosContactos.size()>0){
            for(EventWhoRelation temp : eventosContactos){
                if(mapaContactos.get(temp.relationId) <> null && !temp.event.subject.startsWith('Email:')){
                    String cadena = '<b>Funcionario: </b>'+temp.relation.name+'<b> - Evento: </b>'+temp.event.Subject+' - <b>Asociado a: </b>'+temp.event.what.name+' - <b>Fecha y hora de terminación del evento: </b>'+String.valueOf(temp.event.EndDateTime);
                    datosRegistros.add(cadena);
                }
            }
            
        }
        if(tareasFuncionarios.size()>0){
            List <TaskWhoRelation> tareasEliminar = new List <TaskWhoRelation>();
            for(TaskWhoRelation temp : tareasFuncionarios){
                if(mapaContactos.get(temp.relationId) <> null && !temp.task.subject.startsWith('Email:')){
                    String cadena = '<b>Funcionario: </b>'+temp.relation.name+'<b> - Tarea: </b>'+temp.task.Subject+' - <b>Asociada a: </b>'+temp.task.what.name+' - <b>Fecha de terminación de la tarea: </b>'+String.valueOf(temp.task.ActivityDate);
                    datosRegistros.add(cadena);
                }
            }
        }
        if(comitesFuncionarios.size()>0){
            /*validación de permisosde actualización sobre el campo fecha terminación*/
            if (Schema.sObjectType.SST_Funcionarios_Comites__c.fields.fecha_terminacion__c.isUpdateable()){
                List <SST_Funcionarios_Comites__c> miembrosComitesInactivar = new List <SST_Funcionarios_Comites__c>();
                for(SST_Funcionarios_Comites__c temp : comitesFuncionarios){
                    Contact contactoTemp = mapaContactos.get(temp.Funcionario__c);
                    if(contactoTemp <> null){
                        temp.fecha_terminacion__c = contactoTemp.SST_Fecha_Retiro__c;
                        miembrosComitesInactivar.add(temp);
                        String cadena = '<b>Funcionario: </b>'+temp.funcionario__r.name+'<b> - Comité: </b>'+temp.comite__r.nombre_comite__c+' - <b>Cargo: </b>'+temp.cargo_comite__r.name+' - <b>Titularidad: </b>'+temp.titularidad__c+' - <b>Fecha de terminación del comité: </b>'+String.valueOf(temp.comite__r.fecha_fin__c);
                        datosRegistros.add(cadena);
                    }
                }
                try{
                    
                    if(miembrosComitesInactivar.size()>0){
                        update miembrosComitesInactivar;
                    }
                    
                    
                } catch(Exception e) {
                    System.debug('---------------- Error al actualizar funcionarios comités: ' + e.getStackTraceString()+'Mensaje error:'+e.getMessage());
                }
            }else{
                datosRegistros.add('Permisos insuficientes para asignar fecha de terminación de los miembros de los comités');
            }
        }
        if(normatividadesFuncionarios.size()>0){
            if (Schema.sObjectType.SST_Normatividad__c.fields.Funcionario__c.isUpdateable()){
                List <SST_Normatividad__c> normatividadesDesasociar = new List <SST_Normatividad__c>(); 
                for(SST_Normatividad__c temp : normatividadesFuncionarios){
                    Contact contactoTemp = mapaContactos.get(temp.Funcionario__c);
                    if(contactoTemp <> null){
                        temp.Funcionario__c = null;
                        normatividadesDesasociar.add(temp);
                        String cadena = '<b>Funcionario: </b>'+temp.funcionario__r.name+'<b> - Normatividad: </b>'+temp.name+' - <b>Fecha de expedición de la normatividad: </b>'+String.valueOf(temp.fecha_expedicion__c);
                        datosRegistros.add(cadena);
                    }
                }
                try{
                    if(normatividadesFuncionarios.size()>0){
                        update normatividadesFuncionarios;
                    }
                } catch(Exception e) {
                    System.debug('---------------- Error al actualizar normatividades: ' + e.getStackTraceString()+'Mensaje error:'+e.getMessage());
                }
            }else{
                datosRegistros.add('Permisos insuficientes para desasociar funcionarios retirados responsables de la normatividad');
            }
        }  
        if(cuentaFuncionarios.size()>0){
            if (Schema.sObjectType.Account.fields.responsable_SST__c.isUpdateable()){
                
                List<Account> cuentaActualizar = new List<Account>();
                for(Account temp : cuentaFuncionarios){
                    Contact contactoTemp = mapaContactos.get(temp.responsable_SST__c);
                    if(contactoTemp <> null){
                        temp.responsable_SST__c = null;
                        cuentaActualizar.add(temp);
                        String cadena = '<b>Funcionario: </b>'+temp.responsable_SST__r.name+'<b> - Responsable SST para el cliente: </b>'+temp.name;
                        datosRegistros.add(cadena);
                    }
                }
                try{
                    if(cuentaActualizar.size()>0){
                        update cuentaActualizar;
                    }
                } catch(Exception e) {
                    System.debug('---------------- Error al actualizar la cuenta: ' + e.getStackTraceString()+'Mensaje error:'+e.getMessage());
                }
            }else{
                datosRegistros.add('Permisos insuficientes para desasociar funcionarios retirados como responsables SST en la cuenta');
            }
        }
        try{
            if(datosRegistros.size()>0){
                datosRegistros.sort();
                SST_Constantes.EnviarNotificacionFuncionariosInactivos(datosRegistros, nit);
            }
            
        } catch(Exception e) {
            System.debug('---------------- Error al enviar correo de notificación : ' + e.getStackTraceString()+'Mensaje error:'+e.getMessage());
        }
    }
    
    
    /*Método que se encarga de actualizar el estado de los peligros que se inactivan */
    public static void inactivarPeligros(List <Id> idSede, List <Id> idArea, List <Id> idProceso){
        if (Schema.sObjectType.SST_peligro__c.fields.Estado__c.isUpdateable()){
            String empresaAutenticada = getEmpresaAutenticada();
            List<SST_peligro__c> peligrosInactivos = new List<SST_peligro__c>();
            
            
            if(idArea <> null){
                for(SST_peligro__c peligro : [SELECT Id FROM SST_peligro__c Where area__c =: idArea and Empresa__c=: empresaAutenticada]){
                    peligro.Estado__c = 'INACTIVO';
                    peligrosInactivos.add(peligro);
                }        
            }
            if(idSede <> null){
                for(SST_peligro__c peligro : [SELECT Id FROM SST_peligro__c Where Sede__c =: idSede and Empresa__c=: empresaAutenticada]){
                    peligro.Estado__c = 'INACTIVO';
                    peligrosInactivos.add(peligro);
                }        
            }
            if(idProceso <> null){
                for(SST_peligro__c peligro : [SELECT Id FROM SST_peligro__c Where Proceso__c =: idProceso and Empresa__c=: empresaAutenticada]){
                    peligro.Estado__c = 'INACTIVO';
                    peligrosInactivos.add(peligro);
                }        
            }
            
            update peligrosInactivos;
        }  else{
            throw new ApplicationException('Permisos insuficientes para inactivar un peligro cuando un área, sede o proceso se inactiva');
        }      
        
    } 
    
    /*Método que se encarga de actualizar el estado de los contactos de los proveedores que se activar, inactivan o retiran*/
    public static void actualizarContactosProveedor(Map<Id,String> idProveedores){
        if (Schema.sObjectType.Contact.fields.SST_isActive__c.isUpdateable()&&
            Schema.sObjectType.Contact.fields.sst_retirado__c.isUpdateable()){
                ID idContactoProveedor = Schema.SObjectType.contact.getRecordTypeInfosByName().get(CONTACTO_PROVEEDOR).getRecordTypeId();
                List<Contact> contactos = new List<Contact>();
                for(Contact contacto : [SELECT id, SST_Proveedor__c, sst_retirado__c, SST_isActive__c FROM Contact WHERE recordTypeId = :idContactoProveedor AND SST_Proveedor__c in :idProveedores.keySet() and sst_retirado__c =: false]){
                    if(idProveedores.get(contacto.SST_Proveedor__c).equals(SST_Constantes.RETIRAR)){
                        contacto.SST_isActive__c = 'false';
                        contacto.sst_retirado__c = true;
                    } else if(idProveedores.get(contacto.SST_Proveedor__c).equals(SST_Constantes.INACTIVAR)){
                        contacto.SST_isActive__c = 'false';
                    } else if(idProveedores.get(contacto.SST_Proveedor__c).equals(SST_Constantes.ACTIVAR)){
                        contacto.SST_isActive__c = 'true';
                    }
                    contactos.add(contacto);
                }
                update contactos;
            }else{
                throw new ApplicationException('Permisos insuficientes para inactivar o retirar un contacto');
            }  
    }
    /*Clase exception*/
    public class ApplicationException extends Exception {}   
    
}