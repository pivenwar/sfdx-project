({
     initHelper : function(component, event, helper) {
          helper.utilSetMarkers(component, event, helper);
     },
     utilSetMarkers : function(component, event, helper) {
          let action = component.get("c.getAllSitios");
          action.setCallback(this, function(response) {
               const data = response.getReturnValue();
               const dataSize = data.length;
               let markers = [];
               for(let i=0; i < dataSize; i += 1) {
                    const Sitio = data[i];
                    markers.push({
                        'location': {
                             'Latitude' : Sitio.Ubicacion__Latitude__s,
                             'Longitude' : Sitio.Ubicacion__Longitude__s
                        },
                        'icon': 'utility:Sitio',
                        'title' : Sitio.Name,
                        'description' : 'Tel: '+Sitio.Telefono__c+' - Email: '+Sitio.email_sede__c
                   });
               }
               component.set('v.markersTitle', 'Ubicación sedes de la compañía');
               component.set('v.mapMarkers', markers);
          });
          $A.enqueueAction(action);
     }
})