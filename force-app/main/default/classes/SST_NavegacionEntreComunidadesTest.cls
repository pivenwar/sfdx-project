@IsTest
public class SST_NavegacionEntreComunidadesTest {
    static testMethod void SST_NavegacionEntreComunidadesTest(){
        String empresa =[SELECT SST_empresa_autenticada__c FROM User WHERE id = :UserInfo.getUserId()].SST_empresa_autenticada__c;        
        
        Account cuenta = new Account();
        cuenta.name = 'SST';
        cuenta.Type = 'Customer';
        cuenta.SST_horas_habiles__c = 9;
        cuenta.SST_nit__c = Decimal.valueOf(empresa);
        cuenta.SST_Cuenta_indicadores_globales__c = true;
        insert cuenta;
        
        
        SST_NavegacionEntreComunidadesCC nav = new SST_NavegacionEntreComunidadesCC();
        nav.comunidad = 'SST';
        nav.actualizarEmpresaAutenticada();
        System.assert('SST'== nav.comunidad);

    }
}