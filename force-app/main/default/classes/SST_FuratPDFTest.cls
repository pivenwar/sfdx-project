/**
* Clase test que da cubrimiento a SST_FuratPDFCC
* @date 12/06/2019
*/
@IsTest

public class SST_FuratPDFTest {
       /*Metodo que se encarga de evaluar si ahi datos en el registro furat*/
       static testMethod void SST_FuratPDFTest(){
             String empresa = SST_TestDataFactory.returnEmpresa();
             Account cuenta = SST_TestDataFactory.crearCuenta(empresa);
             SST_Cargo__c cargo = SST_TestDataFactory.crearCargoFuncionario();
             Contact funcionario = SST_TestDataFactory.crearFuncionario(cuenta, cargo);
             
             SST_Registro_de_Novedades__c accidente = SST_TestDataFactory.crearRegistroAccidente(funcionario.Id);
             ApexPages.StandardController sc = new ApexPages.StandardController(accidente);
             SST_FuratPDFCC furat = new SST_FuratPDFCC(sc);
             System.assert(furat.registroFurat<>null);

       }

}