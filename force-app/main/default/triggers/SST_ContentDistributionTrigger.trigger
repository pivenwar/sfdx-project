/*Trigger para obtener el link público del PDF de la política de tratamiento de datos
* @Marcela Taborda
* @date 16/04/2019
*/

trigger SST_ContentDistributionTrigger on ContentDistribution (after insert, after update) {
    if(trigger.isAfter){
        String url = '';
        //Al crear un link público de un archivo, se verifica si el nombre del documento es el de Política tratamiento datos,
        //y de ser dicho documento se obtiene en link público.
        String nombre = '%'+SST_Constantes.NOMBRE_PDF_POLITICA+'%';
        for(ContentDistribution temp : [select name, DistributionPublicUrl from ContentDistribution where name like: nombre]){
            url = temp.DistributionPublicUrl;
        }
        if(url <> null){
            //El link público obtenido se guarda en el campo SST_url_pdf_politica_datos__c de los usuarios administradores del sistema actualmente activos
            List <User> admins = [Select id, SST_url_pdf_politica_datos__c from User where isActive =: true and profile.UserType = 'Standard' and (profile.name =: SST_Constantes.SYSTEM_ADMINISTRATOR or profile.name =: SST_Constantes.ADMINISTRADOR)];
            for(User temp : admins){
                temp.SST_url_pdf_politica_datos__c = url;
            }
            if(admins.size()>0){
             	update admins;   
            }
        }
    }
}