/*Clase encargada de generar archivo PDF del informe sobre el accidente previamente seleccionado
* @author Stiven Herrera
* @date 12/06/2019
* @version 1.0
*
*/
public with sharing class SST_FuratPDFCC {
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
   
    /*Registro consultado y adaptado para ser presentado en el pdf*/
    public FuratDTO registroFurat {get;set;}

    
    /*Método constructor de generador PDF furat*/    
    public SST_FuratPDFCC(ApexPages.StandardController stdController){
        try{
        SST_Registro_de_Novedades__c registroSeleccionado= (SST_Registro_de_Novedades__c)stdController.getRecord();
        registroSeleccionado = [SELECT Id,Funcionario__r.Account.name,Funcionario__r.Account.SST_Actividad_Economica__c,
                                Funcionario__r.Account.SST_Direccion__c,Funcionario__r.Account.Phone,Funcionario__r.Phone,
                                Funcionario__r.SST_Correo_Contacto__c,Funcionario__r.Account.SST_Codigo_Actividad__c,           
                                Funcionario__r.Account.SST_Departamento__c,Funcionario__r.firstName,
                                Funcionario__r.lastName,Funcionario__r.SST_Tipo_Identificacion__c,Funcionario__r.Birthdate,
                                Funcionario__r.SST_Genero__c,Funcionario__r.SST_Jornada__c,Funcionario__r.SST_Fecha_Ingreso__c,
                                Funcionario__r.SST_Salario__c,Funcionario__r.SST_Cargo__c,Funcionario__r.Account.SST_Zona__c,
                                Funcionario__r.Account.SST_Municipio__c,Funcionario__r.SST_Direccion__c,
                                Funcionario__r.SST_Departamento__c,Funcionario__r.SST_Municipio__c,
                                Funcionario__r.Account.SST_Nit__c,Funcionario__r.Account.SST_Tipo_Documento__c,
                                Funcionario__r.name,Funcionario__r.SST_Identificacion__c,Funcionario__r.SST_ARL__c,
                                Funcionario__r.SST_EPS__c,Funcionario__r.SST_Fondo_Pensiones__c, Investigacion__c, Tipo__c,
                                numero_dias__c, Fecha_Inicial__c, Consecuencia__c, Parte_Cuerpo_Afectada__c,
                                Agente_accidente__c, Tipo_Lesion__c, Otro_tipo_Lesion__c,
                                Mecanismo_forma_accidente__c, Otro_Mecanismo_forma_del_accidente__c,
                                Descripcion__c,Hora__c, Jornada__c, Labor_habitual__c,
                                Cual_labor__c, Tiempo_laborado__c, Tipo_accidente__c,
                                Causo_muerte__c, Zona__c, Departamento__c, Municipio__c,Sede__r.name,
                                Sede__r.Direccion__c,Sede__r.Telefono__c,Sede__r.Departamento__c,
                                Sede__r.Municipio__c,Jornada_Habitual__c,
                                Persona_responsable__r.name,Persona_responsable__r.SST_Identificacion__c, Nombre_completo_primera_persona__c,Cargo__c,
                                Nombre_completo_segunda_persona__c, Cargo_primer_persona__c,Dia__c,
                                Cargo_segunda_persona__c, Lugar__c,Funcionario__r.Account.Responsable_SST__r.email,
                                Cantidad_Horas__c,Sitio__c,Tipo_contrato__c
                                FROM SST_Registro_de_Novedades__c where id = :registroSeleccionado.Id];
        
        registroFurat = convertirNovedadAFuratDTO(registroSeleccionado);
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error construyendo el objeto, por favor contacte al administrador'));
            System.debug('Error en SST_FuratPDFCC() Linea:'+e.getLineNumber()+' - '+e.getMessage());
        }
    }
    
    /*Método para convertir los datos de la consulta para el generar  PDF furat*/
    private FuratDTO convertirNovedadAFuratDTO(SST_Registro_de_Novedades__c accidente){
        FuratDTO furat = new FuratDTO();

        furat.funcionario = accidente.Funcionario__r.name;
        furat.hora = accidente.Hora__c;
        Datetime fechainicial= accidente.Fecha_Inicial__c;
        furat.fechaInicial = fechainicial.format(SST_Constantes.FORMATO_FECHA);   
        furat.tipo= obtenerValorPicklist(accidente.Tipo__c,SST_Registro_de_Novedades__c.Tipo__c.getDescribe());
        furat.investigacion= obtenerValorPicklist(accidente.Investigacion__c,SST_Registro_de_Novedades__c.Investigacion__c.getDescribe());
        furat.parteCuerpo = obtenerValorPicklist(accidente.Parte_Cuerpo_Afectada__c,SST_Registro_de_Novedades__c.Parte_Cuerpo_Afectada__c.getDescribe());
        furat.tipoLesion = obtenerValorPicklist(accidente.Tipo_Lesion__c,SST_Registro_de_Novedades__c.Tipo_Lesion__c.getDescribe());
        furat.otroTipoLesion = obtenerValorPicklist(accidente.Otro_tipo_Lesion__c,SST_Registro_de_Novedades__c.Otro_tipo_Lesion__c.getDescribe());
        furat.mecanismoAccidente = obtenerValorPicklist(accidente.Mecanismo_forma_accidente__c,SST_Registro_de_Novedades__c.Mecanismo_forma_accidente__c.getDescribe());
        furat.otroMecanismoAccidente = obtenerValorPicklist(accidente.Otro_Mecanismo_forma_del_accidente__c,SST_Registro_de_Novedades__c.Otro_Mecanismo_forma_del_accidente__c.getDescribe());
        furat.jornada = obtenerValorPicklist(accidente.Jornada__c,SST_Registro_de_Novedades__c.Jornada__c.getDescribe());
        furat.laborHabitual = obtenerValorPicklist(accidente.Labor_habitual__c,SST_Registro_de_Novedades__c.Labor_habitual__c.getDescribe());
        furat.tipoAccidente = obtenerValorPicklist(accidente.Tipo_accidente__c,SST_Registro_de_Novedades__c.Tipo_accidente__c.getDescribe());
        furat.causoMuerte = obtenerValorPicklist(accidente.Causo_muerte__c,SST_Registro_de_Novedades__c.Causo_muerte__c.getDescribe());
        furat.zona = obtenerValorPicklist(accidente.Zona__c,SST_Registro_de_Novedades__c.Zona__c.getDescribe());
        furat.departamento = obtenerValorPicklist(accidente.Departamento__c,SST_Registro_de_Novedades__c.Departamento__c.getDescribe());
        furat.municipio = obtenerValorPicklist(accidente.Municipio__c,SST_Registro_de_Novedades__c.Municipio__c.getDescribe());
        furat.lugar = obtenerValorPicklist(accidente.Lugar__c,SST_Registro_de_Novedades__c.Lugar__c.getDescribe());
        furat.sitio = obtenerValorPicklist(accidente.Sitio__c,SST_Registro_de_Novedades__c.Sitio__c.getDescribe());
        furat.personaResponsable = accidente.Persona_responsable__r.name;
        furat.diasCargados = accidente.numero_dias__c;
        furat.consecuencia= accidente.Consecuencia__c;
        furat.agenteAccidente = obtenerValorPicklist(accidente.Agente_accidente__c,SST_Registro_de_Novedades__c.Agente_accidente__c.getDescribe());
        furat.descripcion= accidente.Descripcion__c;
        furat.cualLabor= accidente.Cual_labor__c;
        furat.tiempoLaborado = accidente.Tiempo_laborado__c;
        furat.nombrePersonaUno = accidente.Nombre_completo_primera_persona__c;
        furat.cargoPersonaUno= accidente.Cargo_primer_persona__c;
        furat.nombrePersonaDos = accidente.Nombre_completo_segunda_persona__c;
        furat.cargoPersonaDos= accidente.Cargo_segunda_persona__c;
        furat.cantidadHoras= accidente.Cantidad_Horas__c;
        furat.identificacionFuncionario = accidente.Funcionario__r.SST_Identificacion__c;
        furat.epsFuncionario = obtenerValorPicklist(accidente.Funcionario__r.SST_EPS__c,Contact.SST_EPS__c.getDescribe());
        furat.arlFuncionario = obtenerValorPicklist(accidente.Funcionario__r.SST_ARL__c,Contact.SST_ARL__c.getDescribe());
        furat.afpFuncionario = obtenerValorPicklist(accidente.Funcionario__r.SST_Fondo_Pensiones__c,Contact.SST_Fondo_Pensiones__c.getDescribe());
        furat.nombreEmpresa = accidente.Funcionario__r.Account.name;
        furat.actividadEconomica = accidente.Funcionario__r.Account.SST_Actividad_Economica__c;
        furat.identificacionEmpresa = accidente.Funcionario__r.Account.SST_Nit__c;
        furat.tipoIdentificacionEmpresa = obtenerValorPicklist(accidente.Funcionario__r.Account.SST_Tipo_Documento__c,Account.SST_Nit__c.getDescribe());
        furat.telefonoEmpresa = accidente.Funcionario__r.Account.Phone;
        furat.correoElectronico = accidente.Funcionario__r.Account.Responsable_SST__r.email;
        furat.departamentoEmpresa = obtenerValorPicklist(accidente.Funcionario__r.Account.SST_Departamento__c,Account.SST_Departamento__c.getDescribe());
        furat.municipioEmpresa = obtenerValorPicklist(accidente.Funcionario__r.Account.SST_Municipio__c,Account.SST_Municipio__c.getDescribe());
        furat.direccionEmpresa = accidente.Funcionario__r.Account.SST_Direccion__c;
        furat.direccionEmpleado = accidente.Funcionario__r.SST_Direccion__c;
        furat.telefonoEmpleado = accidente.Funcionario__r.Phone;
        furat.departamentoEmpleado = obtenerValorPicklist(accidente.Funcionario__r.SST_Departamento__c,Contact.SST_Departamento__c.getDescribe());
        furat.municipioEmpleado = obtenerValorPicklist(accidente.Funcionario__r.SST_Municipio__c,Contact.SST_Municipio__c.getDescribe());
        furat.nombreEmpleado = accidente.Funcionario__r.firstName;
        furat.apellidoEmpleado = accidente.Funcionario__r.lastName;
        furat.tipoIdentificacionEmpleado = obtenerValorPicklist(accidente.Funcionario__r.SST_Tipo_Identificacion__c,Contact.SST_Tipo_Identificacion__c.getDescribe());
        furat.identificacionEmpleado = accidente.Funcionario__r.SST_Identificacion__c;      
        Datetime fechaNacimientoEmpleado= accidente.Funcionario__r.Birthdate;
        furat.fechaNacimientoEmpleado = fechaNacimientoEmpleado.format(SST_Constantes.FORMATO_FECHA); 
        furat.genero = obtenerValorPicklist(accidente.Funcionario__r.SST_Genero__c,Contact.SST_Genero__c.getDescribe());
        furat.jornadaHabitual = obtenerValorPicklist(accidente.Funcionario__r.SST_Jornada__c,Contact.SST_Jornada__c.getDescribe());
        furat.jornada = obtenerValorPicklist(accidente.Jornada__c,SST_Registro_de_Novedades__c.Jornada__c.getDescribe());
        furat.cargo = accidente.Cargo__c;
        furat.tiempoLaborado = accidente.Tiempo_laborado__c;
        Datetime fechaIngreso= accidente.Funcionario__r.SST_Fecha_Ingreso__c;
        furat.fechaIngreso = fechaIngreso.format(SST_Constantes.FORMATO_FECHA);
        furat.salario = accidente.Funcionario__r.SST_Salario__c;
        furat.zonaEmpresa = obtenerValorPicklist(accidente.Funcionario__r.Account.SST_Zona__c,Account.SST_Zona__c.getDescribe());
        furat.codigoMunicipioEmpresa = accidente.Funcionario__r.Account.SST_Municipio__c;
        furat.codigoDepartamentoEmpresa = accidente.Funcionario__r.Account.SST_departamento__c;
        furat.codigoDepartamentoEmpleado = accidente.Funcionario__r.SST_Departamento__c;
        furat.codigoMunicipioEmpleado = accidente.Funcionario__r.SST_Municipio__c;
        furat.codigoActividad = accidente.Funcionario__r.Account.SST_Codigo_Actividad__c;
        furat.diaAccidente = accidente.Dia__c;
        furat.sede = accidente.Sede__r.name;
        furat.direccionSede = accidente.Sede__r.Direccion__c;
        furat.departamentoSede = obtenerValorPicklist(accidente.Sede__r.Departamento__c,SST_Sede__c.Departamento__c.getDescribe());
        furat.municipioSede = obtenerValorPicklist(accidente.Sede__r.Municipio__c,SST_Sede__c.Municipio__c.getDescribe());
        furat.telefonoSede = accidente.Sede__r.Telefono__c;
        furat.codigoMunicipioSede = accidente.Sede__r.Municipio__c;
        furat.codigoDepartamentoSede = accidente.Sede__r.Municipio__c;
        furat.epsCodigoFuncionario = accidente.Funcionario__r.SST_EPS__c;
        furat.arlCodigoFuncionario = accidente.Funcionario__r.SST_ARL__c;
        furat.afpCodigoFuncionario = accidente.Funcionario__r.SST_Fondo_Pensiones__c;
        furat.identificacionResponsable = accidente.Persona_responsable__r.SST_Identificacion__c;
        if(accidente.Tipo_contrato__c == 'SST_Constantes.TEMPORAL' || accidente.Tipo_contrato__c == 'SST_Constantes.CONTRATISTA'){
            furat.vinculacionLaboral = 'Contratante'; 
        }else{
            furat.vinculacionLaboral = 'Empleador';
        }
        
        
        if(accidente.Tipo_contrato__c <> 'SST_Constantes.TEMPORAL' && accidente.Tipo_contrato__c <> 'SST_Constantes.CONTRATISTA' && accidente.Tipo_contrato__c <> 'SST_Constantes.APRENDIZ'){
            furat.tipoContrato = 'Planta'; 
        }else if(accidente.Tipo_contrato__c == 'SST_Constantes.TEMPORAL' ){
            furat.tipoContrato = 'MISIÓN';
        }else if(accidente.Tipo_contrato__c == 'SST_Constantes.APRENDIZ_LECTIVO' ||  accidente.Tipo_contrato__c == 'SST_Constantes.APRENDIZ_PRODUCTIVO'){
            furat.tipoContrato = 'COOPERADO, ESTUDIANTE O APRENDIZ';
        }else if(accidente.Tipo_contrato__c == 'SST_Constantes.CONTRATO_CONTRATISTA'){
            furat.tipoContrato = 'INDEPENDIENTE';
        }



        return furat;
    }
    
    
   /*Metodo que obtiene los datos de tipo picklist de la consulta registroSeleccionado para luego convertilos a datos para mostrar en el PDF Furat*/
    private String obtenerValorPicklist(String apiName,Schema.DescribeFieldResult campo){
        for( Schema.PicklistEntry pickItem : campo.getPicklistValues()){
            if(pickItem.getValue().equals(apiName)){
                return pickItem.getLabel();
            }
        } 
        return '';
    }
    
    /*Clase interna DTO que contiene la información de Funcionario, Empresa y resgistro novedad del accidente*/
    public class FuratDTO {
        public String funcionario {get;set;}
        public String fechaInicial {get; set;}
        public String investigacion {get;set;}
        public String tipo {get;set;}
        public Decimal diasCargados {get;set;}
        public String consecuencia {get;set;}
        public String parteCuerpo {get;set;}
        public String agenteAccidente {get;set;}
        public String tipoLesion {get;set;}
        public String otroTipoLesion {get;set;}
        public String mecanismoAccidente {get;set;}
        public String otroMecanismoAccidente {get;set;}
        public String descripcion {get;set;}
        public String jornada {get;set;}
        public String laborHabitual {get;set;}
        public String cualLabor {get;set;}
        public String tiempoLaborado {get;set;}
        public String tipoAccidente {get;set;}
        public String causoMuerte {get;set;}
        public String zona {get;set;}
        public String departamento {get;set;}
        public String municipio {get;set;}
        public String personaResponsable {get;set;}
        public String nombrePersonaUno {get;set;}
        public String cargoPersonaUno {get;set;}
        public String nombrePersonaDos {get;set;}
        public String cargoPersonaDos {get;set;}
        public String lugar {get;set;}
        public Decimal cantidadHoras {get;set;}
        public String sitio {get;set;}
        public String hora {get;set;}
        public String tipoContrato {get;set;}
        public String identificacionFuncionario {get;set;}
        public String epsFuncionario {get;set;}
        public String arlFuncionario {get;set;}
        public String afpFuncionario {get;set;}
        public String vinculacionLaboral {get;set;}
        public String nombreEmpresa {get;set;}
        public String actividadEconomica {get;set;}
        public Decimal identificacionEmpresa {get;set;}
        public String tipoIdentificacionEmpresa {get;set;}
        public String telefonoEmpresa {get;set;}
        public String correoElectronico {get;set;}
        public String departamentoEmpresa {get;set;}
        public String municipioEmpresa {get;set;}
        public String direccionEmpresa {get;set;}
        public String direccionEmpleado {get;set;}
        public String telefonoEmpleado {get;set;}
        public String departamentoEmpleado {get;set;}
        public String municipioEmpleado {get;set;} 
        public String nombreEmpleado {get;set;} 
        public String apellidoEmpleado {get;set;} 
        public String tipoIdentificacionEmpleado {get;set;}
        public String identificacionEmpleado {get;set;}
        public String fechaNacimientoEmpleado {get;set;}
        public String genero {get;set;}
        public String cargo {get;set;}
        public String fechaIngreso {get;set;}
        public Decimal salario {get;set;}
        public String zonaEmpresa {get;set;}
        public String codigoMunicipioEmpresa {get;set;}
        public String codigoDepartamentoEmpresa {get;set;}
        public String codigoDepartamentoEmpleado {get;set;}
        public String codigoMunicipioEmpleado {get;set;} 
        public String codigoActividad {get;set;} 
        public String diaAccidente {get;set;} 
        public String sede {get;set;} 
        public String direccionSede {get;set;} 
        public String telefonoSede {get;set;} 
        public String departamentoSede {get;set;} 
        public String municipioSede {get;set;} 
        public String codigoDepartamentoSede {get;set;} 
        public String codigoMunicipioSede {get;set;} 
        public String epsCodigoFuncionario {get;set;} 
        public String arlCodigoFuncionario {get;set;} 
        public String afpCodigoFuncionario {get;set;} 
        public String identificacionResponsable {get;set;}
        public String jornadaHabitual {get;set;} 



    }    
    
}